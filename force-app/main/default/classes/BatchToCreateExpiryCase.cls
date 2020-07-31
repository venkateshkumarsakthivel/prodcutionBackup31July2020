global class BatchToCreateExpiryCase implements Database.Batchable<sObject>{
	
    global final String Query;
    public static final String TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME = 'Taxi License Administration';
    public static final String TAXI_LICENCE_AUTHORISATION_DEV_NAME ='Taxi_Licence';
    public static final String TAXI_LICENCE_EXPIRATION_CASE_SUBJECT = 'Expiry of Taxi license';
    public static final String TAXI_LICENCE_EXPIRATION_CASE_DESC = 'Expiry of Taxi license';
	public static final String CASE_TYPE_TAXI = 'Taxi';
    public static final String EXPIRY_CASE_SUB_TYPE = 'Expiry';
    public static final String EXPIRY_RENEWAL_CASE_SUB_TYPE = 'Expiry - Renewable';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String TAXI_LEVEL_2_QUEUE_DEV_NAME = 'Taxi_Support_Level_2';
    public static final String ERROR ='Error';//logging level
    public static final Set<String> AUTH_STATUSES = new Set<String>{'Granted','Suspended','Granted With Conditions','Granted Unconditionally'};
	global BatchToCreateExpiryCase() {
        Date dateGMT=System.Today()+7;  
        Datetime d1=Date.valueOf(dateGMT);
        string dateTimeFormat =d1.format('yyyy-MM-dd');
        
        query = 'SELECT Id, Service_Provider__c, Contact__c, Licence_Class__c, Record_Type_Dev_Name__c, First_Issued_Date__c ' +
            	'FROM Authorisation__c '+
            	'WHERE End_Date__c ='+dateTimeFormat+
            		' AND Status__c IN:AUTH_STATUSES' +
            		' AND Licence_Class__c != NULL '+
            		' AND Record_Type_Dev_Name__c =: TAXI_LICENCE_AUTHORISATION_DEV_NAME';
        
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Authorisation__c> scope){
        List<Case> caseRecordsToInsert = new List<Case>();
        List<Authorisation__c> updateAuthorisationList = new List<Authorisation__c>();
        try{
                Id TARecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                Map<String, Taxi_Class__mdt> classVsConfig = new Map<String, Taxi_Class__mdt>();
                for(Taxi_Class__mdt config : [SELECT MasterLabel, Is_Renewable__c,Licence_Class__c, Licence_Type__c, Max_Years__c
                                                FROM Taxi_Class__mdt]) {
                    classVsConfig.put(config.Licence_Class__c, config);
                } 
                Id taxiQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: TAXI_LEVEL_2_QUEUE_DEV_NAME].Id;
 
                Map<Id, Authorisation__c> licencesForExpiry = new Map<Id, Authorisation__c>();
                Set<Id> serviceProviders = new Set<Id>();
                for(Authorisation__c auth : scope){
                    serviceProviders.add(auth.Service_Provider__c);
                    licencesForExpiry.put(auth.Id, auth);
                }
                PrimaryContactRetriever contactRetriever = new PrimaryContactRetriever(serviceProviders);
                
                //check if open surrender case exist for a licence, do not create expiry case if surrender is in progress
                List<Case> openSurrenderRequests = [SELECT CaseNumber, Status, Authorisation__c
                                                    FROM Case 
                                                    WHERE IsClosed = FALSE
                                                        AND Authorisation__c IN :licencesForExpiry.keySet()
                                                        AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                                        AND (Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_SURRENDER_PAIRED
                                                                OR Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_SURRENDER)];
                //Filter licences which are in surrender process
                for(Case surrenderCase : openSurrenderRequests){
                    System.debug(LoggingLevel.INFO, 'Surrender request exists for the licence ' + surrenderCase.Authorisation__c);
                    licencesForExpiry.remove(surrenderCase.Authorisation__c);
                }

                //Fetching the assignment rules on case
                for(Authorisation__c authRec : licencesForExpiry.values()) {
                    if(classVsConfig.containsKey(authRec.Licence_Class__c)) {
                        Taxi_Class__mdt taxiClass = classVsConfig.get(authRec.Licence_Class__c);
                        authRec.Is_ExpiryCaseCreated__c= true;
                        updateAuthorisationList.add(authRec);
                        Date todaysDate = System.today();
                        Integer differenceInYears = authRec.First_Issued_Date__c == null ? 0 : (authRec.First_Issued_Date__c.monthsBetween(todaysDate)/12);
                            
                        Case caseRecord = new Case();
                        caseRecord.RecordTypeId = TARecordTypeId;
                        caseRecord.Status = CASE_STATUS_NEW;
                        caseRecord.Type = CASE_TYPE_TAXI;
                        caseRecord.Subject = TAXI_LICENCE_EXPIRATION_CASE_SUBJECT;
                        caseRecord.Description = TAXI_LICENCE_EXPIRATION_CASE_DESC;
                        caseRecord.AccountId = authRec.Service_Provider__c;
                        caseRecord.ContactId = contactRetriever.identifyPrimaryContact(authRec.Service_Provider__c);
                        caseRecord.Authorisation__c = authRec.Id;
                        caseRecord.OwnerId = taxiQueueId;

                        if( taxiClass.Is_Renewable__c == 'No' || (taxiClass.Is_Renewable__c == 'Yes' && differenceInYears >= taxiClass.Max_Years__c)){
                            caseRecord.Sub_Type__c = EXPIRY_CASE_SUB_TYPE;
                        } else if(taxiClass.Is_Renewable__c == 'Yes'){
                            caseRecord.Sub_Type__c = EXPIRY_RENEWAL_CASE_SUB_TYPE;
                        }
                        if(taxiClass.Max_Years__c == 0 && taxiClass.Is_Renewable__c == 'Yes')
                        caseRecord.Sub_Type__c = EXPIRY_RENEWAL_CASE_SUB_TYPE;
                        
                        caseRecordsToInsert.add(caseRecord);
                    } 
                    
                }
            if(caseRecordsToInsert.Size() > 0 ){
                insert caseRecordsToInsert;
                update updateAuthorisationList;
            }
            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchToCreateExpiryCase','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    }
}