/**
* Server side Rest resource controller for ASP Dashboard
* This provides Action handles for the following:
* View, Add, Delete, Edit Drivers
* View, Add, Delete, Edit Vehicles
* View DVD Query Logs (DVD Query Group records with aggregated information)
* View DVD Query History
* 
* This controller services the following components:
* ASPDashboard.cmp
* DVDQueryLogs.cmp
* DVDHistory.cmp
*/
public with sharing class ASPDashboardController {
    /*
*This class contains methods which controls actions on DVD Dashboard page
*/
    
    //function returns the count of Fleets (vehicle and driver) 
    @AuraEnabled
    public static List<Integer> getDVDRecordCount(){
        
        List<Integer> resultSet = new Integer[2];
        for(AggregateResult ar : [select count(id), RecordType.Name from DVD_Entity__c group by RecordType.Name]) {
            if(ar.get('Name') == 'Driver') {
                resultSet[0] = (Integer)ar.get('expr0');
            } else {
                resultSet[1] = (Integer)ar.get('expr0');
            }
        }
        system.debug('rs' + resultset);
        
        return resultSet;
    }
    
    //returns the JSON string containing driver records, green count, red count etc

    @AuraEnabled
    public static List<DVD_Entity__c>  getInitialDVDRecords(){
        return EntityDataWrapper.getDriverDataWrapper().getEntities();
    }
 
    //returns the JSON string containing vehicle records, green count, red count etc 
    @AuraEnabled
    public static List<DVD_Entity__c> getInitialVehicleRecords(){
        return EntityDataWrapper.getVehicleDataWrapper().getEntities();
    }
    
    //returns list of DVD Query group
    @AuraEnabled
    public static List<DVD_Query_Group__c> getDVDQueryGroupLogs(){
        
        List<DVD_Query_Group__c> dvdQueryLogrecords = [SELECT Id, Run_Type__c, CreatedDate, isExportAllowed__c,
                                                       Requester__r.Name, Status__c,
                                                       Eligibility_Y__c, Eligibility_N__c, Eligibility_Unknown__c, 
                                                       Total__c, Eligibility_Check_Total_Count__c
                                                       FROM DVD_Query_Group__c 
                                                       ORDER BY CreatedDate DESC LIMIT 100];
        system.debug('dvdQueryLogrecords: '+dvdQueryLogrecords);
        
        return DVDQueryLogrecords;
    } 
    
    /**
* Utility method to create an DVDQueue instance
*/ 
    @TestVisible
    private static DVDQueue getDVDQueueInstance() {
        Account acc;
        User u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(Test.isRunningTest()){
            /*
            acc = new Account(Name='TestAccount');
            insert acc;
            */
            acc = [SELECT Id FROM Account WHERE Name ='testAcc' LIMIT 1];  
        }else{
            
            acc = [SELECT Id FROM Account WHERE Id = :u.Contact.AccountId];     
        }
        DVDQueue q = new DVDQueue(acc, u);
        return q;
    }
    
    //runchecks all driver records
    @AuraEnabled
    public static String runCheckAllDrivers() {
        DVDQueue q = getDVDQueueInstance();
        q.checkAllDrivers();
        return 'Successfully queued drivers';        
    }
    
     //runchecks all driver records
    @AuraEnabled
    public static string runExportAllDrivers() {
        DVDQueue q = getDVDQueueInstance();
        q.ExportAllBatch();
        
       
       return 'Success: You will receive an Email once the export is complete';        
    }
    
    //runchecks all vehicle records
    @AuraEnabled
    public static String runCheckAllVehicles() {
        DVDQueue q = getDVDQueueInstance();
        q.checkAllVehicles();
        return 'Successfully queued vehicles';        
    }
    
    /**
* @param - list of Ids of selected drivers to queue for DVD 
*/
    @AuraEnabled
    public static void runCheckSelectedDrivers(List<String> ids) {
        
        if(ids == null || ids.isEmpty()){ return; }
        DVDQueue q = getDVDQueueInstance();
        //Get the list of driver/vehicle dvd_entitiy__c records with each record containing the Id
        List<DVD_Entity__c> entities = [SELECT Id  FROM DVD_Entity__c WHERE Id in :ids];
        
        q.checkSelectedDrivers(entities);
    }
    
    /**
* @param - list of Ids of selected vehicles to queue for DVD 
*/
    @AuraEnabled
    public static void runCheckSelectedVehicles(List<String> ids) {
        
        if(ids == null || ids.isEmpty()){ return;}
        DVDQueue q = getDVDQueueInstance();
        //Get the list of driver/vehicle dvd_entitiy__c records with each record containing the Id
        List<DVD_Entity__c> entities = [SELECT Id, Plate_Number__c, Taxi_Licence_Status__c  FROM DVD_Entity__c WHERE Id in :ids];
        
        //Populate Taxi Licence Status on DVD Entity
        try{
            if(isTaxiLicenceCheckRequired()){
                EntityDataWrapper.populateTaxiLicenceStatus(entities);
                update entities;
            }
        }catch(Exception e){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPDashboardController', 'runCheckSelectedVehicles', 'Error performing DML operation on Vehicle entities', e);
        }
        
        q.checkSelectedVehicles(entities);
    }    
    
    /**
* @param - record ids of the DVD record to be deleted
*/
    @AuraEnabled
    public static void dvdRecordListDeletion(List<String> ids) {
        
        System.debug('Got Ids: '+ids);
        
        try {
            
            FleetDeletor.deleteEntities(ids);
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPDashboardController', 'dvdRecordListDeletion', e.getMessage(), e);
        }
    } 
    
    /**
* @param - record id of the DVD record to be updated
*/
    @AuraEnabled
    public static string dvdDriverRecordUpdate(String recordId, String lName, String licenceNumber, String dob) {
        
        system.debug('Got Rec Id: '+recordId);
        DVD_Entity__c tempDVDRecord = new DVD_Entity__c();
        try{   
            
            tempDVDRecord.Id = recordId;
            tempDVDRecord.Last_Name__c = lName;
            tempDVDRecord.Drivers_Licence_Number__c = licenceNumber;
            
            if(dob == NULL || dob == '')
                tempDVDRecord.Date_of_Birth__c = NULL;
            else
                tempDVDRecord.Date_of_Birth__c = Date.parse(dob);
            
            tempDVDRecord.Licence_Check__c = 'None';
            tempDVDRecord.Criminal_Check__c = 'None';
            tempDVDRecord.Serious_Driving_Offence__c = 'None';
            tempDVDRecord.P2P_Offence__c = 'None';
            tempDVDRecord.P2P_Eligibility__c = 'None';
            
            tempDVDRecord.Last_DVD_Check_date__c = NULL;
            tempDVDRecord.PTCode_Active_Start_Date__c=NULL;
            update tempDVDRecord;    
            return 'Success';
        }  
        catch(Exception ex){
            tempDVDRecord.addError(ex.getMessage());
            if(ex.getMessage().contains(GlobalConstants.DUPLICATE_VALUE_EXCEPTION)){
                return Label.ERRMSG_DUPLICATE_RECORD_FOUND;
            }
            else if(ex.getMessage().contains(GlobalConstants.INVALID_DATE_EXCEPTION)){
                return GlobalConstants.INVALID_DATE_MESSAGE;
            }
            else if(ex.getMessage().contains(GlobalConstants.INVALID_AGE_EXCEPTION)){
                return GlobalConstants.INVALID_AGE_MESSAGE;
            }
            return ex.getMessage();
        }
        
    }
    
    /**
* @param - record id of the DVD record to be updated
*/
    @AuraEnabled
    public static string dvdVehicleRecordUpdate(String recordId, String plateNumber, String plateType, String vin) {
        try{
            system.debug('Got Rec Id: '+recordId);
            
            DVD_Entity__c tempDVDRecord = new DVD_Entity__c();
            tempDVDRecord.Id = recordId;
            tempDVDRecord.Plate_Number__c = plateNumber;
            tempDVDRecord.PLate_Type__c = plateType;
            tempDVDRecord.VIN_Number_or_Chassis_Number__c = vin;
            tempDVDRecord.Vehicle_Check__c = 'None';
            tempDVDRecord.Taxi_Licence_Status__c = 'None';
            tempDVDRecord.Last_DVD_Check_date__c = NULL;
            tempDVDRecord.Last_AIS_Inspection_Date__c = NULL;
            
            update tempDVDRecord;
            return 'Success';
        }catch(Exception ex){
            if(ex.getMessage().contains(GlobalConstants.DUPLICATE_VALUE_EXCEPTION)){
                return Label.ERRMSG_DUPLICATE_RECORD_FOUND;
            }
            return ex.getMessage();
        }
        
    } 
    
    //returns list of DVD Queries
    @AuraEnabled
    public static List<DVD_Query__c> QueriesToExport(Id recId, String dvdEntityType) {
        
        List<Id> entityIds = new List<Id>();
        List<DVD_Query__c> dvdQueryRecords = [SELECT DVD_Entity__c, Drivers_Licence_Number__c,PTCode_Active_Start_Date__c,
                                              Last_Name__c, P2P_Eligibility__c, CreatedDate,
                                              Last_AIS_Inspection_Date__c, Last_AIS_Inspection_Date_Check__c, NSW_Tenure_Check__c,
                                              Plate_Number__c, Traffic_Light_Indicator__c, SDO_Check_Status__c, 
                                                Plate_Type__c, VIN_Number_or_Chassis_Number__c,Criminal_Charge_Check_Status__c, Taxi_Licence_Status__c 
                                              FROM DVD_Query__c 
                                              WHERE DVD_Query_Group__c =: recId];

        return dvdQueryRecords;        
    }
    
    //Function to return time according to user's timezone 
    @AuraEnabled
    public static String getCurrentTime() {
        String dt = System.now().format('dd/MM/yyyy-kk:mm:ss');
        return dt;        
    } 
    
    //returns the JSON string containing green count for specified enity type
    @AuraEnabled
    public static String  getAggregateGreenCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getGreenCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing red count for specified enity type
    @AuraEnabled
    public static String  getAggregateRedCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getRedCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing white count for specified enity type
    @AuraEnabled
    public static String  getAggregateWhiteCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getWhiteCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing count of passed p2p eligibility records
    @AuraEnabled
    public static String  getAggregatePassEligibilityCount() {
        
        return JSON.serialize(EntityDataWrapper.getPassEligibilityCountDataWrapper());
    }
    
     @AuraEnabled
    public static String  getDriverCount() {
        
        return JSON.serialize(EntityDataWrapper.getDVDTotalDriverCount());
    }
    
    @AuraEnabled
    public static String  getVehicleCount() {
        return JSON.serialize(EntityDataWrapper.getDVDTotalVehicleCount());
    }
    
    //returns the JSON string containing count of failed p2p eligibility records
    @AuraEnabled
    public static String  getAggregateFailEligibilityCount() {
        
        return JSON.serialize(EntityDataWrapper.getFailedEligibilityCountDataWrapper());
    }
    
    // ***********new methods after serious driver offence (SDO) implementation ****************
    //returns the JSON string containing green count for specified enity type
    
    @AuraEnabled
    public static String  getAggregateErrorCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getErrorCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateVehicleErrorCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getVehicleErrorCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateSDOGreenCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getSDOGreenCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing red count for specified enity type
    @AuraEnabled
    public static String  getAggregateSDORedCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getSDORedCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing white count for specified enity type
    @AuraEnabled
    public static String  getAggregateSDOWhiteCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getSDOWhiteCountDataWrapper(entityType));
    }
    
    //returns the JSON string containing white count for specified enity type
    @AuraEnabled
    public static String  getAggregateSDOErrorCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getSDOErrorCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateCCGreenCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getCCGreenCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateCCRedCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getCCRedCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateCCWhiteCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getCCWhiteCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateCCErrorCount(String entityType) {
        
        return JSON.serialize(EntityDataWrapper.getCCErrorCountDataWrapper(entityType));
    }
    
    /************* Tenure Check Summary Methods: Start *******/
    
    @AuraEnabled
    public static String  getAggregateTenureGreenCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getTenureGreenCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateTenureRedCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getTenureRedCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateTenureWhiteCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getTenureWhiteCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateTenureErrorCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getTenureErrorCountDataWrapper(entityType));
    }
    /************* Tenure Check Summary Methods: End *******/
    
    /************* AIS Inspection Date Check Summary Methods: Start *******/
    @AuraEnabled
    public static String  getAggregateAISDateGreenCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getAISDateGreenCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateAISDateRedCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getAISDateRedCountDataWrapper(entityType));
    }
    
    @AuraEnabled
    public static String  getAggregateAISDateWhiteCount(String entityType) {        
        return JSON.serialize(EntityDataWrapper.getAISDateWhiteCountDataWrapper(entityType));
    }
    
    /************* AIS Inspection Date Check Summary Methods: End *******/

    
    //returns list of DVD Lights Controller Metadata
    @AuraEnabled
    public static Map<String, DVD_Lights_Controller__mdt> getDashboardConfigurationValues(){
        Map<String, DVD_Lights_Controller__mdt> dashboardStatusNameVsDashboardStatusValue = new Map<String, DVD_Lights_Controller__mdt>();
        
        for(DVD_Lights_Controller__mdt dashbordConfgVal : [Select Id,Hide_Results__c,MasterLabel From DVD_Lights_Controller__mdt]){
            dashboardStatusNameVsDashboardStatusValue.put(dashbordConfgVal.MasterLabel, dashbordConfgVal);   
        }
        
        return dashboardStatusNameVsDashboardStatusValue;
    }
    // Returns flag if Taxi licence check is required
    @AuraEnabled
    public static Boolean isTaxiLicenceCheckRequired() {
        //Fetch TSP Authorisations
        List<Authorisation__c> tspAuths = GlobalUtility.getValidTSPAuthorisations(getServiceProviderId());
    
        return !tspAuths.isEmpty() ? true : false;                                  
    }
    
    /**
     * Utility method to return the Account Id for the logged in user
     */
    private static Id getServiceProviderId(){
        if(Test.isRunningTest()){
            return [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1].Id;
        }else{
            User u = [SELECT ID, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            return u.Contact.AccountId;
        }
    }

    
}