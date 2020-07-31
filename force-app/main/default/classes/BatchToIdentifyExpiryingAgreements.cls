//batch class for scheduler "TaxiAgent30DaysRemainingExpiryScheduler" and "TaxiAgent0DaysRemainingExpiryScheduler"
global class BatchToIdentifyExpiryingAgreements implements Database.Batchable<sObject>  {
  
  String query;
  String STATUS_ACTIVE = 'Active';
  String STATUS_INACTIVE = 'Inactive';
  
  Integer daysForExpiry;

  global BatchToIdentifyExpiryingAgreements(String query, Integer daysForExpiry) {
    
    this.query = query;
    this.daysForExpiry = daysForExpiry;
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<Account> targetAccounts) {
    
    Map<String, Authorisation_Agent__c> serviceProviderIdVsAuthAgent = new Map<String, Authorisation_Agent__c>();
    
    //String authAgentStatusToCheck = daysForExpiry == -1 ? STATUS_INACTIVE : STATUS_ACTIVE;
    
    for(Authorisation_Agent__c tempAuthAgent : [SELECT Id, Account__c, Status__c, Authorisation__r.Service_Provider__c, Days_to_Expire__c
                                                 FROM Authorisation_Agent__c
                                                 WHERE Account__c IN :targetAccounts
                                                 AND Status__c = :STATUS_ACTIVE
                                                 AND Days_to_Expire__c = :daysForExpiry]) {
        
        if(!serviceProviderIdVsAuthAgent.containsKey(tempAuthAgent.Authorisation__r.Service_Provider__c)) {
           
           Authorisation_Agent__c tempAuthAgentToUpdate = new Authorisation_Agent__c();
           tempAuthAgentToUpdate.Id = tempAuthAgent.Id;
           tempAuthAgentToUpdate.Send_Expiry_Notification__c = TRUE;
           
           serviceProviderIdVsAuthAgent.put(tempAuthAgent.Authorisation__r.Service_Provider__c, tempAuthAgentToUpdate);
        }                                             
    }
    
    Database.SaveResult[] sr = Database.update(serviceProviderIdVsAuthAgent.values());
    System.debug('Auth. Agent Update Result: '+sr);                                     
  }
  
  global void finish(Database.BatchableContext BC) {    
     
  }
}