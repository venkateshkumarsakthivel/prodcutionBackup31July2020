/**
* Scheduler class to Create Case for Authorisations that are due for Expiry within next 7 days
* This Batch runs run Daily.
* 
* Criteria -
* Authorisation Type: BSP or TSP
* Status: Granted Unconditionally, Granted With Conditions or Suspended
* End Date in the next 7 days
* 
*/
public with sharing class ASPAuthorisationExpiryBatch implements Database.Batchable<Authorisation__c> {
    
    private static final Date currentPlus7Days = System.today().addDays(Integer.valueOf(Label.Expiry_Eligible_Period_Before_End_Date_of_ASP_Authorisation));
    public static final String ASP_Support_Tier_2_QUEUE_DEV_NAME = 'ASP_Support_Tier_2';
    
    public Iterable<Authorisation__c> start(Database.BatchableContext BC) {
        
        List<Authorisation__c> listAuthorisations = [SELECT Id, Name, Authorisation_Number__c, Authorisation_Type__c, Service_Provider__c, Application__c
                                                     FROM Authorisation__c 
                                                     WHERE (Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_BSP 
                                                            OR Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_TSP)
                                                     AND (Status__c =: GlobalConstants.GRANTED_UNCONDITIONALLY
                                                          OR Status__c =: GlobalConstants.GRANTED_CONDITIONALLY
                                                          OR Status__c =: GlobalConstants.AUTHORISATION_SUSPENDED)
                                                     AND End_Date__c =: currentPlus7Days];
        return listAuthorisations;
    }
    
    public void execute(Database.BatchableContext BC, List<Authorisation__c> scope) {
        
        Set<Id> serviceProviders = new Set<Id>();
        for(Authorisation__c auth : scope){
            serviceProviders.add(auth.Service_Provider__c);
        }
        
        PrimaryContactRetriever primaryContactRetriever = new PrimaryContactRetriever(serviceProviders);

        Id serviceProviderAdministrationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Id aspQueueId = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: ASP_Support_Tier_2_QUEUE_DEV_NAME].Id;
        
        // Create Cases
        List<Case> expiryCases = new List<Case>();
        Case expiryCase;
        
        for(Authorisation__c auth : scope) {
            
            expiryCase = new Case();
            expiryCase.AccountId = auth.Service_Provider__c;
            expiryCase.ContactId = primaryContactRetriever.identifyPrimaryContact(auth.Service_Provider__c);
            expiryCase.Authorisation__c = auth.Id;
            expiryCase.RecordTypeId = serviceProviderAdministrationRecordType;
            expiryCase.Status = GlobalConstants.CASE_NEW;
            //expiryCase.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
            expiryCase.Type = (auth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP) ? GlobalConstants.AUTHORISATION_TYPE_BSP : GlobalConstants.AUTHORISATION_TYPE_TSP;                 
            expiryCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE;
            expiryCase.Subject = 'Expiry of ASP Authorisation';
            expiryCase.Description = 'Expiry of ASP Authorisation';               
            //expiryCase.Origin = GlobalConstants.CASE_ORIGIN_WEB;
            expiryCase.OwnerId = aspQueueId;
            
            expiryCases.add(expiryCase);
        }
        
        // Insert Cases
        Database.insert(expiryCases, false);
        
        System.debug('Expiry Cases Inserted : ' + expiryCases);
    }
    
    public void finish(Database.BatchableContext BC){
        // do nothing
    }
}