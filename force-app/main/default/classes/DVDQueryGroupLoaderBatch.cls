/**
 * Batch to enable creation of the QueryGroup Queue
 * This execution will create the DVD_Query records from the selected DVD_Entity records
 * When the batch completes, it will update the status of the DVD_Query_Group record to 'Queued'
 */
public with sharing class DVDQueryGroupLoaderBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public integer count = 0;
 
    public Enum DVDEntityType {DRIVER, VEHICLE}
        
    /**Query for selection of the DVD_Entity Records*/
    public final string query;
    
    /** Post processor to fire on execution completion */
    private GenericCommand postProcessor;
    
    /** Authorised Service Provider Id */
    private Id aspId;
    
    /** Query Group Id */
    private DVD_Query_Group__c queryGroup;
    
    /** Select of selected entity id */
    private List<Id> entityIds;

    private Integer index = 1;

    /** Ctor for Queue All Drivers*/
    public DVDQueryGroupLoaderBatch(Id aspId, DVD_Query_Group__c queryGroup, GenericCommand postProcessor, 
                                              DVDEntityType entityType) {
        this.postProcessor = postProcessor;
        this.aspId = aspId;
        this.queryGroup = queryGroup;       
         system.debug('<-----1st query ALL query------------>');
        system.debug('aspId------------>'+aspId);
         system.debug('queryGroup------------>'+queryGroup);
          system.debug('postProcessor------------>'+postProcessor);
           system.debug('entityType------------>'+entityType);
                                                   
        if(entityType == DVDEntityType.DRIVER) {
            query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Authorised_Service_Provider__c, '
                  + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, RecordType.DeveloperName, Taxi_Licence_Status__c '
                  + ' From DVD_Entity__c ' 
                  + '   WHERE Authorised_Service_Provider__c =  \'' + String.escapeSingleQuotes(this.aspId) + '\''
                  + '   AND DVD_Entity__c.RecordType.DeveloperName = \'Driver\''
                  + '   AND Inactive__c = false';
        } else if(entityType == DVDEntityType.VEHICLE) {
            query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Authorised_Service_Provider__c, '
                  + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, RecordType.DeveloperName, Taxi_Licence_Status__c '
                  + ' From DVD_Entity__c ' 
                  + '   WHERE Authorised_Service_Provider__c =  \'' + String.escapeSingleQuotes(this.aspId) + '\''
                  + '   AND DVD_Entity__c.RecordType.DeveloperName = \'Vehicle\''
                  + '   AND Inactive__c = false';
        }
        System.debug(LoggingLevel.INFO,'Generated query: ' + query);
    }    

    /** Ctor for passed scope of entity*/
    public DVDQueryGroupLoaderBatch(Id aspId, DVD_Query_Group__c queryGroup, GenericCommand postProcessor, 
                                              DVDEntityType entityType, 
                                              List<DVD_Entity__c> entities) {
        this.postProcessor = postProcessor;
        this.aspId = aspId;
        this.queryGroup = queryGroup;                                                  
        entityIds = new List<Id>();
        for(DVD_Entity__c e: entities){
            entityIds.add(e.Id);
        }
        
        system.debug('aspId------------>'+aspId);
         system.debug('queryGroup------------>'+queryGroup);
          system.debug('postProcessor------------>'+postProcessor);
           system.debug('entityType------------>'+entityType);
                                                   
                                                   
        System.debug(LoggingLevel.INFO, 'Total number of entities: ' + entityIds.size());
        if(entityType == DVDEntityType.DRIVER) {
            query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Authorised_Service_Provider__c, '
                  + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, RecordType.DeveloperName, Taxi_Licence_Status__c '
                  + ' From DVD_Entity__c ' 
                  + '   WHERE Authorised_Service_Provider__c = \'' + String.escapeSingleQuotes(this.aspId) + '\''
                  + '   AND DVD_Entity__c.RecordType.DeveloperName = \'Driver\''
                  + '   AND Id IN :entityIds'
                  + '   AND Inactive__c = false';
        } else if(entityType == DVDEntityType.VEHICLE) {
            query = 'SELECT Id, Drivers_Licence_Number__c, Date_of_Birth__c, Last_Name__c, Authorised_Service_Provider__c, '
                  + ' Plate_Number__c, Plate_Type__c, VIN_Number_or_Chassis_Number__c, RecordType.DeveloperName, Taxi_Licence_Status__c '
                  + ' From DVD_Entity__c ' 
                  + '   WHERE Authorised_Service_Provider__c =  \'' + String.escapeSingleQuotes(this.aspId) + '\''
                  + '   AND DVD_Entity__c.RecordType.DeveloperName = \'Vehicle\''
                  + '   AND Id IN :entityIds'
                  + '   AND Inactive__c = false';
        }
        
        System.debug(LoggingLevel.INFO,'Generated query: ' + query);
    }    

// Changed the return type from List to Querylocator, to make sure that the batch handles more than 50,000 records, new limit will be 5 MILLION.

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        System.debug(LoggingLevel.INFO,'Query to be used: ' + query);
        /*System.debug(LoggingLevel.INFO, 'Total number of entities: ' + entityIds.size());
        System.debug(entityIds);*/
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<DVD_Query__c> newObjects = new List<DVD_Query__c>();
        List<DVD_Entity__c> resetEntities = new List<DVD_Entity__c>();
        Map<Id, DVD_Query__c> newObjectsMap = new Map<Id, DVD_Query__c>();
        
        count++;

        // changes for POC of flexqueues
        
        for(Sobject s : scope){
                       
               DVD_Entity__c e = (DVD_Entity__c) s;
               e.DVD_Status__c = 'Requested';
               e.Criminal_Check__c = 'None';
               e.Licence_Check__c = 'None';
               e.P2P_Offence__c = 'None';
               e.P2P_Eligibility__c = 'None';
               e.Serious_Driving_Offence__c = 'None';
               e.Vehicle_Check__c = 'None';
              if(e.Drivers_Licence_Number__c!=null)
               e.Drivers_Licence_Number__c =(e.Drivers_Licence_Number__c).toUppercase();
            
               resetEntities.add(e);
               
               String queryFor = e.RecordType.DeveloperName;
               newObjectsMap.put(e.Id, new DVD_Query__c(
                   //copy from Entity to Query
                    //Drivers_Licence_Number__c= (e.Drivers_Licence_Number__c).toUppercase(),
                   Drivers_Licence_Number__c= e.Drivers_Licence_Number__c,
                   Date_of_Birth__c = e.Date_of_Birth__c, 
                   Last_Name__c = e.Last_Name__c,
                   Plate_Number__c = e.Plate_Number__c, 
                   Plate_Type__c = e.Plate_Type__c,
                   VIN_Number_or_Chassis_Number__c = e.VIN_Number_or_Chassis_Number__c,
                   Authorised_Service_Provider__c = this.aspId,
                   DVD_Query_Group__c = this.queryGroup.Id,
                   DVD_Entity__c = e.Id,
                   Requester_Id__c = this.queryGroup.Requester__c,
                   Organisation_Code__c = this.queryGroup.Organisation_Code__c, /*@XXX Service_Provider_Code__c?*/
                   //service provider username, 
                   Service_Provider_Username__c = this.queryGroup.Requester__c,
                   Query_Started_At__c = System.now(),
                   Query_Status__c = 'Completed',
                   Overall_Result__c = 'ERROR',
                   Taxi_Licence_Status__c = e.Taxi_Licence_Status__c,
                   Sequence_Number__c = index
               ));

               index ++;
               
            System.debug('Added DVD Query to the list');
           }
            System.debug('Inserting DVD Queries from DVD Entities - ' + newObjects.size());
        List<Database.SaveResult> results = Database.update(resetEntities, false);
        for(Database.SaveResult result : results){
            if(result.isSuccess()){
                newObjectsMap.get(result.getId()).Query_Status__c = 'Queued';
                newObjectsMap.get(result.getId()).Overall_Result__c = null;
                //count++;
            }
        }
        insert newObjectsMap.values();
        
       }

       public void finish(Database.BatchableContext bc) {
           system.debug('Batch Execution complete. Firing post process');
           system.debug('No of records processed ------------->'+count);
           if(null != postProcessor) {
               postProcessor.execute();
           }
           //Send an email to the User after your batch completes
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'venkatesh.sakthivel@transport.nsw.gov.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Batch Apex Job is done : Record Count' + count );
            mail.setPlainTextBody('Total' +'  '+ count +'  '+ 'Records updated sucessfully');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
           
}