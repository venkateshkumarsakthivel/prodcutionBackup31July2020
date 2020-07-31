/*
 * Helper class to detect if it was last active authorisation and if yes then
 * revoke DVD access of all related authorisation contacts
 */
public with sharing class RevokeDVDAccess {

    private Map<Id, Case> newApplications;
    private Map<Id, Case> oldApplications;
    private static final Set<Id> aspRecordTypes;
    
    static {
        
        aspRecordTypes = GlobalUtility.retrieveASPApplicationRecordTypes();
    }
    
    public RevokeDVDAccess(Map<Id, Case> newApplications, Map<Id, Case> oldApplications){
    
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    
    public void revokeDVDAccess() {
       
     try {
       
        Set<Id> targetServiceProviders = new Set<Id>();
        Set<Id> targetAuthorisations = new Set<Id>();
        Set<Id> authorisationRelatedContacts = new Set<Id>();
        
        //Map<String, List<String>> authorisationVsContact = new Map<String, List<String>>();
        Map<String, Integer> accountVsRelatedActiveAuthCount = new Map<String, Integer>();
        Map<String, String> contactVsAccount = new Map<String, String>();
        
        Map<String, User> contactVsUser = new Map<String, User>();
       
        System.debug('In Revoke DVD Access: '+newApplications.values()[0]);
        
        for(Case tempCase : newApplications.values()) {
         
          if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_DEV_NAME
              && tempCase.Type == GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
              && (tempCase.Sub_Type__c == GlobalConstants.VOLUNTARY_RETURN_CASE_SUB_TYPE 
                  || tempCase.Sub_Type__c == GlobalConstants.SUSPEND_CASE_SUB_TYPE
                  || tempCase.Sub_Type__c == GlobalConstants.CANCEL_CASE_SUB_TYPE
                  || tempCase.Sub_Type__c == GlobalConstants.EXPIRY_CASE_SUB_TYPE)
              && (tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   || tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS)
              && tempCase.Authorisation__c != NULL
              && tempCase.AccountId != NULL) {
           
              targetServiceProviders.add(tempCase.AccountId);
              targetAuthorisations.add(tempCase.Authorisation__c);
          }
        }
        
        //if any case of type return, suspend or expiry is found, check if it was last active authorisation
        //if yes, revoke DVD access of the user
        if(!targetAuthorisations.isEmpty()) {
        
         System.debug('In Revoke DVD Access: '+targetAuthorisations);
         
         
         for(Contact tempCon : [SELECT FirstName, LastName, AccountId
                                FROM Contact
                                WHERE AccountId IN :targetServiceProviders]) {
             
           authorisationRelatedContacts.add(tempCon.Id);  
           contactVsAccount.put(tempCon.Id, tempCon.AccountId);
           //authorisationVsContact.put(tempAuthCon.Authorisation__c, associatedContacts);                                       
         }
         
         if(!authorisationRelatedContacts.isEmpty()) {
         
          for(Authorisation__c tempAuth : [SELECT Id, Status__c, Service_Provider__c
                                           FROM Authorisation__c
                                           WHERE Service_Provider__c IN :targetServiceProviders
                                           AND Id NOT IN :targetAuthorisations
                                           AND Status__c IN :GlobalConstants.AUTHORISATION_VALID_RETURN_STATUS]) {
                                                     
           Integer associatedAuthorisationCount;
           if(accountVsRelatedActiveAuthCount.containsKey(tempAuth.Service_Provider__c))
             associatedAuthorisationCount = accountVsRelatedActiveAuthCount.get(tempAuth.Service_Provider__c);
           else
             associatedAuthorisationCount = 0;
           
           associatedAuthorisationCount++; 
           accountVsRelatedActiveAuthCount.put(tempAuth.Service_Provider__c, associatedAuthorisationCount);                                       
          }
         
         
          for(User tempCommunityUser : [SELECT Id, isActive, ContactId, Profile.Name
                                        FROM User
                                        WHERE ContactId IN :authorisationRelatedContacts
                                        AND isActive = TRUE]) {
                                      
            contactVsUser.put(tempCommunityUser.ContactId, tempCommunityUser);                             
          }
         
          System.debug('In Revoke DVD Access: '+accountVsRelatedActiveAuthCount);
          System.debug('In Revoke DVD Access: '+contactVsAccount);
          
          Set<String> targetUserstoRevokeAccess = new Set<String>();
                                             
          for(String relatedConId : authorisationRelatedContacts)  {
         
           //if it was last granted authorisation for the account change user profile to Account Manager
           if(!accountVsRelatedActiveAuthCount.containsKey(contactVsAccount.get(relatedConId))) {
          
            if(contactVsUser.containsKey(relatedConId))
             targetUserstoRevokeAccess.add(contactVsUser.get(relatedConId).Id);
           }
          }
          
          
          System.debug('Target Users To Revoke: '+targetUserstoRevokeAccess);
          System.debug('Contact Vs User Map: '+contactVsUser);
          
          List<Contact> contactsToUpdate = new List<Contact>();
          
          //code to update access specific checkboxes on contact records
          for(String contactId : contactVsUser.keySet()) {
            
            //if contact id is present in set of users to downgrade
            if(targetUserstoRevokeAccess.contains(contactVsUser.get(contactId).Id)) {
             
             Contact tempCon = new Contact();
             tempCon.Id = contactId;
             
             System.debug('Profile Name: '+contactVsUser.get(contactId).Profile.Name);
             
             Set<String> validCombinationProfilesToDowngradeWithLevy = new Set<String>();
             validCombinationProfilesToDowngradeWithLevy.add(GlobalConstants.Taxi_ASP_PROFILE_NAME);
             validCombinationProfilesToDowngradeWithLevy.add(GlobalConstants.ASP_PROFILE_NAME);
             validCombinationProfilesToDowngradeWithLevy.add(GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME);
             validCombinationProfilesToDowngradeWithLevy.add(GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME);
             
             if(validCombinationProfilesToDowngradeWithLevy.contains(contactVsUser.get(contactId).Profile.Name)) {
               
               tempCon.Is_Access_Level_DVD_Administrator__c = FALSE;
               tempCon.Is_Access_Level_Account_Administrator__c = TRUE;
               tempCon.Is_Access_Level_Levy_Administrator__c = TRUE;
               contactsToUpdate.add(tempCon);
             }
             
             Set<String> validSingleProfilesToDeactivate = new Set<String>();
             validSingleProfilesToDeactivate.add(GlobalConstants.DVD_USER);
             validSingleProfilesToDeactivate.add(GlobalConstants.LEVY_PROFILE_NAME);
             
             if(validSingleProfilesToDeactivate.contains(contactVsUser.get(contactId).Profile.Name)) {
               
               tempCon.Is_Access_Level_Account_Administrator__c = FALSE;
               tempCon.Deactivated__c = TRUE;
               tempCon.Deactivation_Date__c = System.Today();
               tempCon.Status__c = GlobalConstants.INACTIVE_CONTACT_STATUS;
               contactsToUpdate.add(tempCon);
             }
            }
          }
          
          System.debug('Contacts to update size: '+contactsToUpdate);
          
          if(contactsToUpdate.size() > 0)
            update contactsToUpdate;
          
          UserProfileUpdater.updateUserProfile(targetUserstoRevokeAccess);         
         
         }
        }
        
      }
      catch(Exception e) {
       
       System.debug('Exception: '+e);
     
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RevokeDVDAccess', 'RevokeDVDAccess', e.getMessage(), e);
      }  
    }  
}