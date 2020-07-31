/*
 * * * created by : Srikanth Sunkara
 * Created Date: 09/05/2019
*Scheduler class to Create Register for Levy Case for Authorisations that are not registered after 7 days of Authorisation approval.
* This Batch runs run Daily.
* 
* Criteria -
* Authorisation Type: BSP or TSP
* Status: Granted Unconditionally
* End Date in the next 7 days
* 
*/
global class ASPRegisterLevyExpiryBatch implements Database.Batchable<sObject> {
    global String Query;
    global String dateTimeFormat;
    public static final String ERROR ='Error';//logging level
    //private static final Date currentPlus7Days = System.today().addDays(-7);
    public static final String ASP_Support_Tier_2_QUEUE_DEV_NAME = 'ASP_Support_Tier_2';
    public static final Set<String> AUTH_TYPE = new Set<String>{'TSP','BSP'};
    public static final String STATUS = GlobalConstants.GRANTED_UNCONDITIONALLY;
    public static final String TAXI_LICENCE_AUTHORISATION_DEV_NAME ='Taxi_Licence';
    public static final boolean IS_REGISTERLEVYCASE = false;
    
    global ASPRegisterLevyExpiryBatch() {
        
        Date dateGMT=System.today()-7;  
        Datetime d1=Date.valueOf(dateGMT);
        dateTimeFormat =d1.format('yyyy-MM-dd');
        
       system.debug(dateTimeFormat);
        system.debug(GlobalConstants.GRANTED_UNCONDITIONALLY);
        system.debug(AUTH_TYPE);
        system.debug(STATUS);
        // Fetch those Authorisation records whose Application status is 'granted unconditionally'.
        try{
            /*
            Query = 'SELECT Id, Status__c, Service_Provider__c, Contact__c, Application__c,Is_RegisterLevyCase__c,Authorisation_Type__c,Record_Type_Dev_Name__c FROM Authorisation__c WHERE First_Issued_Date__c = ' +dateTimeFormat +
                ' AND Authorisation_Type__c IN : AUTH_TYPE '+ ' AND status__c = : STATUS  ' + ' AND Is_RegisterLevyCase__c = : IS_REGISTERLEVYCASE  ' 
                + ' AND Record_Type_Dev_Name__c != : TAXI_LICENCE_AUTHORISATION_DEV_NAME ';
             system.debug('Query' + Query);
*/
        }
       
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'ASPRegisterLevyExpiryBatch','ASPRegisterLevyExpiryBatch',ex.getMessage(),ex);
        }
    }
    
   //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        Query = 'SELECT Id, Status__c, Service_Provider__c, Contact__c, Authorisation_Number__c,name,Application__c,Authorisation_Type__c,Record_Type_Dev_Name__c FROM Authorisation__c WHERE First_Issued_Date__c < ' +dateTimeFormat +
                ' AND Authorisation_Type__c IN : AUTH_TYPE '+ ' AND status__c = : STATUS  '  
                + ' AND Record_Type_Dev_Name__c != : TAXI_LICENCE_AUTHORISATION_DEV_NAME ';
             system.debug('Query' + Query);
        return Database.getQueryLocator(Query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Authorisation__c> scope) {
        List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
        List<Case> failureRegisterLevyCases = new List<Case>();
        Map<Id,String> Authorisationsmap = new Map<Id,String>();
        Map<Id,String> AuthorisationsbSPmap = new Map<Id,String>();
        Set<Id> serviceProviders = new Set<Id>();
        system.debug(scope);
        for(Authorisation__c auth : scope){
            serviceProviders.add(auth.Service_Provider__c);
            if(auth.Authorisation_Type__c =='TSP')
            Authorisationsmap.put(auth.Service_Provider__c,auth.Id);
            if(auth.Authorisation_Type__c =='BSP')
            AuthorisationsbSPmap.put(auth.Service_Provider__c,auth.Id);                
           // auth.Is_RegisterLevyCase__c = true;
            //authRecordsToUpdate.add(auth);
        }
        
        PrimaryContactRetriever primaryContactRetriever = new PrimaryContactRetriever(serviceProviders);
        
        Id failureRegisterLevyRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.CASE_RECORDTYPE_FAILURE_REGISTER_LEVY).getRecordTypeId();
        try {
            Id aspQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: ASP_Support_Tier_2_QUEUE_DEV_NAME].Id;
            
            List<Account> accList = [select Id,(select Id from Tax_Payer_Registrations__r),(select id,Authorisation_Type__c from Authorities__r where Authorisation_Type__c in :AUTH_TYPE),(select Id from Cases where recordTypeId=:failureRegisterLevyRecordType) from Account where Id in: serviceProviders];
            // Create Cases
            
            Case failureRegisterLevyCase;
            if(accList.Size() > 0)
            {
                //&& acc.cases.Size() == 0
                for(Account acc: accList) {
                    system.debug(acc.Id);
                    if(acc.Tax_Payer_Registrations__r.size() == 0 && acc.cases.Size() == 0 ) {
                        //createCase(accList);
                        failureRegisterLevyCase = new Case();
                        failureRegisterLevyCase.AccountId = acc.Id;
                        failureRegisterLevyCase.ContactId = primaryContactRetriever.identifyPrimaryContact(acc.Id);
                        if(acc.Authorities__r.Size() > 1) {
                        failureRegisterLevyCase.Authorisation_TSP__c = Authorisationsmap.get(acc.Id);
                        failureRegisterLevyCase.Authorisation_BSP__c = AuthorisationsbSPmap.get(acc.Id);     
                        }
                        if(acc.Authorities__r.Size()== 1 && acc.Authorities__r[0].Authorisation_Type__c == 'TSP')
                        failureRegisterLevyCase.Authorisation_TSP__c = Authorisationsmap.get(acc.Id);
                        if(acc.Authorities__r.Size()== 1 && acc.Authorities__r[0].Authorisation_Type__c == 'BSP')
                        failureRegisterLevyCase.Authorisation_BSP__c = AuthorisationsbSPmap.get(acc.Id);
                        
                        failureRegisterLevyCase.RecordTypeId = failureRegisterLevyRecordType;
                        failureRegisterLevyCase.Status = GlobalConstants.CASE_NEW;
                        failureRegisterLevyCase.Sub_Status__c =  GlobalConstants.CASE_NEW;
                        failureRegisterLevyCase.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;                
                        failureRegisterLevyCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NON_REGISTRATION;
                        failureRegisterLevyCase.OwnerId = aspQueueId;
                        failureRegisterLevyCase.Subject='Failure to Register for Levy';
                        failureRegisterLevyCases.add(failureRegisterLevyCase);
                        
                    }
                    
                }
            }
           //public  createCase(List<Account> accList){
             
              
                
            //}
            // Insert Cases
            if(failureRegisterLevyCases.Size() > 0) {
                Database.insert(failureRegisterLevyCases, false);
                //update authRecordsToUpdate;
            }
          
        }  
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'ASPRegisterLevyExpiryBatch','execute',ex.getMessage(),ex);
        }
        System.debug('failureRegisterLevy Cases Inserted : ' + failureRegisterLevyCases);
        
    }
    
    global void finish(Database.BatchableContext BC){
        // do nothing
    }
}