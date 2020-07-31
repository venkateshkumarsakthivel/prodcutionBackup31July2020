/**
 * Batch for P2P DVD App Client execution
 * There should be no more than 'n' such batches executing parallely
 * Each batch will execute off one DVD_Query_Group and complete it
 * If there are slots in the semaphore(n), the next batch may be instantiated
 */

//@TODO
public class P2PDVDAppClientBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    public Enum DVDEntityType {DRIVER, VEHICLE}
    public static final Map<String, String> fleetTypeVsStatusField = new Map<String, String> {'Driver' => 'Licence_Check__c', 'Vehicle' => 'Vehicle_Check__c'};
        
    /**Query for selection of the DVD_Entity Records */
    private final String query;
    private DVD_Query_Group__c queryGroup;
    private Integer retryCount = 0;
    private List<DVD_Query__c> failedQueries = new List<DVD_Query__c>();
    private Boolean retryBatch = false;

    public P2PDVDAppClientBatch(DVD_Query_Group__c queryGroup){
        this.queryGroup = queryGroup;
        System.debug(LoggingLevel.INFO, 'Query Group record: ' + queryGroup);
        this.query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, '
                    + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, '
                    + ' Authorised_Service_Provider__c, DVD_Entity__r.RecordType.Name, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c,'
                    + ' Requester_Id__c, Organisation_Code__c, Query_Started_At__c, '
                    + ' DVD_Query_For__c, Query_Status__c, DVD_Query_Group__c, DVD_Entity__c, '
                    + ' Service_Provider_Code__c '
            + ' From DVD_Query__c '
            + ' WHERE DVD_Query_Group__c = \'' + queryGroup.Id + '\''
            + ' AND Query_Status__c = \'Queued\'';
    }
    
    /**
     * Use this constructor to retry the failed queries
     */
    public P2PDVDAppClientBatch(List<DVD_Query__c> queries, DVD_Query_Group__c queryGroup, Integer retryCount){
        this.queryGroup = queryGroup;
        this.failedQueries = queries;
        System.debug(LoggingLevel.INFO, 'Query Group record: ' + queryGroup);
        this.query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, '
                    + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, '
                    + ' Authorised_Service_Provider__c, DVD_Entity__r.RecordType.Name, DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c,'
                    + ' Requester_Id__c, Organisation_Code__c, Query_Started_At__c, '
                    + ' DVD_Query_For__c, Query_Status__c, DVD_Query_Group__c, DVD_Entity__c, '
                    + ' Service_Provider_Code__c '
            + ' From DVD_Query__c '
            + ' WHERE Id IN :failedQueries';       
        this.retryCount = retryCount;
    }
    
    // changes for batch callout optimization 
    // we need to pass the query as well that will be limited by sequence number data i.e. 1 to 1000, 1001 - 3000 etc.
    // this is for breaking the query group records in to multiple batches for processing.
    public P2PDVDAppClientBatch(DVD_Query_Group__c queryGroup, String query){
        System.debug(LoggingLevel.INFO, 'Query Group record: ' + queryGroup);
        System.debug(LoggingLevel.INFO, 'Query : ' + query);
        this.queryGroup = queryGroup;
        this.query = query;        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Starting DVD App Client Batch for :' + queryGroup.Name);
        return Database.getQueryLocator(query);
    }
    
    /**
     * Callout using client one-by-one for each object in scope
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug(LoggingLevel.INFO, 'Executing DVD App Client Batch for :' + queryGroup.Name);
        try {
            P2PDVDAppClient dvdApp = new P2PDVDAppClient();
            P2PDVDAppClient.P2PDVDAppResponseParserVisitor dvdVisitor = new P2PDVDAppClient.P2PDVDAppResponseParserVisitor(retryCount > 0);
            
            P2PSDOAppClient sdoApp = new P2PSDOAppClient();
            P2PSDOAppClient.P2PSDOAppResponseParserVisitor sdoVisitor = new P2PSDOAppClient.P2PSDOAppResponseParserVisitor(retryCount > 0);            
            
            String QUERY_TYPE_ELIGIBILITY = 'Driver';
            for(Object o: scope) {
                DVD_Query__c queryParam = (DVD_Query__c)o; 
                
                if(queryParam.DVD_Query_For__c == QUERY_TYPE_ELIGIBILITY) {
                    sdoApp.callSDOApp(queryParam, sdoVisitor);
                } else {
                    dvdApp.callDVDApp(queryParam, dvdVisitor);
                }
            }
            //bulk update the queries and the entities
            dvdVisitor.updateResponses();      
            sdoVisitor.updateResponses();
        } catch(Exception e){
            Integer retryConfigValue = Integer.valueOf(Label.RMS_DVD_Check_Number_of_Retries);
            if(retryConfigValue > 0 && retryCount < retryConfigValue){
                retryBatch = true;
                failedQueries.addAll((List<DVD_Query__c>)scope);
            } else { 
                handleError(scope);
            }
        }
        
    }
    public void finish(Database.BatchableContext BC){
        System.debug(LoggingLevel.INFO, 'Finished DVD App Client Batch for :' + queryGroup.Name);
        if(retryBatch){
            P2PDVDAppClientBatch dvdBatch = new P2PDVDAppClientBatch(failedQueries, queryGroup, ++retryCount);
            System.debug(LoggingLevel.INFO, 'Retrying failed queries [' + failedQueries.size() + ']. Retry Attempt [' + retryCount + '].');
            Id ctxBatchId = Database.executeBatch(dvdBatch, 1);
            FlexQueue.moveJobToFront(ctxBatchId);
        }
        
        //Update the query Group status to Completed
        DVD_QUery_Group__c dvdQueryGroup = [SELECT Id, Status__c, Eligibility_Check_Total_Count__c, Total__c FROM DVD_Query_Group__c WHERE Id = :queryGroup.Id];
        if(dvdQueryGroup.Eligibility_Check_Total_Count__c == dvdQueryGroup.Total__c) {
            dvdQueryGroup.Status__c = 'Completed';
            update dvdQueryGroup;
        }
    }
    
    private void handleError(List<sObject> scope){
        //catch for system/unexpected errors during processing.
        List<DVD_Entity__c> fleets = new List<DVD_Entity__c>();
        List<DVD_Query__c> erroredQueries = new List<DVD_Query__c>();
        for(Object o: scope){
            DVD_Query__c queryParam = (DVD_Query__c)o;
            queryParam.Overall_Result__c = 'ERROR';
            erroredQueries.add(queryParam);
            
            DVD_Entity__c fleet = new DVD_Entity__c();
            fleet.put('Id', queryParam.DVD_Entity__c);
            fleet.put('DVD_Status__c','Error');
            fleet.put(fleetTypeVsStatusField.get(queryParam.DVD_Entity__r.RecordType.Name), 'Unknown');
            fleets.add(fleet);
        }
        Database.update(fleets,false);
        Database.update(erroredQueries, false);
    }
}