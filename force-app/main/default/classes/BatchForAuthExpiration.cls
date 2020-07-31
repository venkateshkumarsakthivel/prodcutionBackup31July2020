//Batch Class for Expiry of an authorisation when end date matches current date.

global class BatchForAuthExpiration implements Database.Batchable<sObject>{
    global final String Query;
    public static final String ERROR ='Error';//logging level
    public static final String AUTH_STATUS_LAPSED = 'Lapsed';
    public static final String SERVICE_PROVIDER_CASE_TYPE = 'Service Provider';
    public static final String EXPIRY_CASE_SUB_TYPE = 'Expiry';
    public static final String LODGED_CASE_STATUS = 'Lodged';
    public static final String CASE_STATUS_REVIEW_PENDING = 'Review Pending';
    public static final String SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME = 'Service Provider Administration';
    public static final String ASP_LEVEL_1_QUEUE_DEV_NAME = 'ASP_Support_Tier_1';
    public static final String TAXI_LICENCE_AUTHORISATION_DEV_NAME ='Taxi_Licence';
	public static final Set<String> AUTH_TYPE = new Set<String>{'TSP','BSP'};
	    
    //Constructor
    global BatchForAuthExpiration() {
        Date dateGMT=System.Today();  
        Datetime d1=Date.valueOf(dateGMT);
        string dateTimeFormat =d1.format('yyyy-MM-dd');
        
        try{ // Fetch those Authorisation records whose Application status is 'Withdrawn'. 
            Query = 'SELECT Id, Status__c, Service_Provider__c, Contact__c, Application__c FROM Authorisation__c WHERE End_Date__c ='+dateTimeFormat +
                    ' AND Authorisation_Type__c IN : AUTH_TYPE '+
                 	' AND Record_Type_Dev_Name__c != : TAXI_LICENCE_AUTHORISATION_DEV_NAME ';
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchForAuthExpiration','BatchForAuthExpiration',ex.getMessage(),ex);
        }
        
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Authorisation__c> scope) {
        List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
        List<Case> caseRecordsToInsert = new List<Case>();
        try{
                        
            Id aspQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: ASP_LEVEL_1_QUEUE_DEV_NAME].Id;
            
            Id SPARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Set<Id> serviceProviders = new Set<Id>();
            for(Authorisation__c auth : scope){
                serviceProviders.add(auth.Service_Provider__c);
            }
            PrimaryContactRetriever contactRetriever = new PrimaryContactRetriever(serviceProviders);
            
            for(Authorisation__c authRec : scope){
                
                authRec.Status__c= AUTH_STATUS_LAPSED;
                authRecordsToUpdate.add(authRec);

                Case caseRecord = new Case();
                caseRecord.RecordTypeId = SPARecordTypeId;
                caseRecord.Type = SERVICE_PROVIDER_CASE_TYPE;
                caseRecord.Sub_Type__c = EXPIRY_CASE_SUB_TYPE;
                caseRecord.Status = LODGED_CASE_STATUS;
                caseRecord.Sub_Status__c = CASE_STATUS_REVIEW_PENDING;
                caseRecord.AccountId = authRec.Service_Provider__c; 
                caseRecord.ContactId = contactRetriever.identifyPrimaryContact(authRec.Service_Provider__c);
                caseRecord.Authorisation__c = authRec.Id;
                caseRecord.OwnerId = aspQueueId;
                caseRecordsToInsert.add(caseRecord);
                
            }
            update authRecordsToUpdate;
            insert caseRecordsToInsert;
            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchForAuthExpiration','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    }
}