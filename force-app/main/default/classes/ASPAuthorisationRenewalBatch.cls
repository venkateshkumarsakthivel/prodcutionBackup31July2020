/**
* Scheduler class to Create Case for Authorisations (along with Draft Authorisation(s)) that are due for Renewal within next 30 days
* This Batch runs run Daily.
* 
* Criteria -
* Authorisation Type: BSP or TSP
* Status: Granted Unconditionally, Granted With Conditions or Suspended
* End Date in the next 30 days
* No cases with type: Service Provider and sub-type: Renewal Application which are in Draft or Lodged status associated to the authorisation
* 
*/
public with sharing class ASPAuthorisationRenewalBatch implements Database.Batchable<Authorisation__c> {
    
    private static final Date currentPlus30Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_End_Date_of_ASP_Authorisation));
    
    public Iterable<Authorisation__c> start(Database.BatchableContext BC) {
        
        List<Authorisation__c> listAuthorisations = [SELECT Id, Name, Authorisation_Number__c, Authorisation_Type__c, Service_Provider__c, Application__c
                                                     FROM Authorisation__c 
                                                     WHERE (Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_BSP 
                                                            OR Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_TSP)
                                                     AND (Status__c =: GlobalConstants.GRANTED_UNCONDITIONALLY
                                                          OR Status__c =: GlobalConstants.GRANTED_CONDITIONALLY
                                                          OR Status__c =: GlobalConstants.AUTHORISATION_SUSPENDED)
                                                     AND End_Date__c <=: currentPlus30Days];
        return listAuthorisations;
    }
    
    public void execute(Database.BatchableContext BC, List<Authorisation__c> scope) {
        
        ASPAuthorisationRenewalInitiator initiater = new ASPAuthorisationRenewalInitiator();
        initiater.initiate(scope);
    }
    
    public void finish(Database.BatchableContext BC){
        // do nothing
    }
}