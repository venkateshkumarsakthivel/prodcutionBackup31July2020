/*
* Helper class to handle service provider related levy registration udpates and maintainig its versions
*/
public with sharing class UpdateRelatedRegistrationsAccountHelper {
    
    private Map<Id, Account> newAccounts;
    private Map<Id, Account> oldAccounts;
    
    public UpdateRelatedRegistrationsAccountHelper(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts){
        
        this.newAccounts = newAccounts;
        this.oldAccounts = oldAccounts;
    }
    
    /*
     *  Method to identify related active registrations and accordingly update them
     *  If existing registration record status is 'Active' and sub status is 'Completed', then clone the existing record to maintain
     *  its older version. If sub status is 'Pending - Revenue NSW' or 'Pending with P2P' the update the existing record itself
     */
    public void processRelatedRegistrations() {
        
     try {

       
       List<Tax_Payer_Registration__c> relatedRegistrationsToValidate = new List<Tax_Payer_Registration__c>();
       List<Tax_Payer_Registration__c> relatedRegistrationsToUpsert = new List<Tax_Payer_Registration__c>();
       
       Set<Id> targetAccounts = new Set<Id>();
       
       for(Account tempAccount : newAccounts.values()) {
          
          if(hasAccountInfoChanged(tempAccount, oldAccounts.get(tempAccount.Id)))
            targetAccounts.add(tempAccount.Id);
       }
       
       relatedRegistrationsToValidate = [SELECT Status__c, Sub_Status__c, Service_Provider_Name__c, Levy_Contact__c, 
                                         Revenue_NSW_Status__c, RNSWCustomerId__c, Applied_For_Exemption__c 
                                         FROM Tax_Payer_Registration__c
                                         WHERE Service_Provider_Name__c IN : targetAccounts
                                         AND status__c = :GlobalConstants.STATUS_ACTIVE];
         
       
       for(Tax_Payer_Registration__c tempRegistration : GlobalUtility.validateRegistrationUpdates(relatedRegistrationsToValidate)) {
       
         //if existing registration record and not a clonned older version
         if(!String.isBlank(tempRegistration.Id)) {
        
           if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE){
           
                tempRegistration.IsProviderUpdate__c = TRUE;
                tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
           }
             
           if(String.isBlank(tempRegistration.RNSWCustomerId__c) == true){
           
                tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
           }  
           
           tempRegistration.ABN__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).ABN__c;
           tempRegistration.Registered_Business_Name__c  = newAccounts.get(tempRegistration.Service_Provider_Name__c).Registered_Business_Name__c;
           tempRegistration.Levy_Notification_Address_City__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).Notice_Address_City__c;
           tempRegistration.Levy_Notification_Address_Country__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).Notice_Address_Country__c;
           tempRegistration.Levy_Notification_Address_Postal_Code__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).Notice_Address_Postal_Code__c;
           tempRegistration.Levy_Notification_Address_State__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).Notice_Address_State__c;
           tempRegistration.Levy_Notification_Address_Street__c = newAccounts.get(tempRegistration.Service_Provider_Name__c).Notice_Address_Street__c;
           
         }
         
         relatedRegistrationsToUpsert.add(tempRegistration);
       }
       
       if(relatedRegistrationsToUpsert.size() > 0)
         Database.Upsert(relatedRegistrationsToUpsert, FALSE);
     }
     catch(Exception e) {
     
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'UpdateRelatedRegistrationsAccountHelper', 'processRelatedRegistrations', e.getMessage(), e);
     }
    }
    
    /* 
     * Helper method to identify if either of the required fields on account have changed or not
     */
    @TestVisible
    private Boolean hasAccountInfoChanged(Account newAccount, Account oldAccount) {
      
      //if required specific fields of accounts have changed
      if(newAccount.Name != oldAccount.Name || newAccount.ABN__c != oldAccount.ABN__c
          || newAccount.Registered_Business_Name__c != oldAccount.Registered_Business_Name__c
          || newAccount.Notice_Address_City__c != oldAccount.Notice_Address_City__c
          || newAccount.Notice_Address_Country__c != oldAccount.Notice_Address_Country__c
          || newAccount.Notice_Address_Postal_Code__c != oldAccount.Notice_Address_Postal_Code__c
          || newAccount.Notice_Address_State__c != oldAccount.Notice_Address_State__c
          || newAccount.Notice_Address_Street__c != oldAccount.Notice_Address_Street__c) {
          
          return true;
      }
      
      return false;
    }
}