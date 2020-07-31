/*
* Helper class to handle primary contact/levy contact related levy registration udpates and maintainig its versions
*/
public with sharing class UpdateRelatedRegistrationsContactHelper {
    
    private Map<Id, Contact> newContacts;
    private Map<Id, Contact> oldContacts;
    
    public UpdateRelatedRegistrationsContactHelper(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
    }
    
    /*
     *  Method to identify related active registrations and accordingly update them
     *  If existing registration record status is 'Active' and sub status is 'Completed', then clone the existing record to maintain
     *  its older version. If sub status is 'Pending - Revenue NSW' or 'Pending with P2P' the update the existing record itself
     */
    public void processRelatedRegistrations() {
    
      try {
        
        Set<Id> targetLevyContacts = new Set<Id>();
        Map<Id, Id> accountIdVsTargetPrimaryContacts = new Map<Id, Id>();
        
        Set<Tax_Payer_Registration__c> relatedRegistrationsToValidate = new Set<Tax_Payer_Registration__c>();
        Set<Tax_Payer_Registration__c> relatedRegistrationsToUpsert = new Set<Tax_Payer_Registration__c>();
        
        for(Contact tempContact : newContacts.values()) {
           
           if(hasContactInfoChanged(tempContact, oldContacts.get(tempContact .Id)) && tempContact.Primary_Contact__c)
            accountIdVsTargetPrimaryContacts.put(tempContact.AccountId, tempContact.Id);
           
           if(hasContactInfoChanged(tempContact, oldContacts.get(tempContact .Id)))
            targetLevyContacts.add(tempContact.Id);
        }
        
        //fetching all registration records related to changed levy contact
        relatedRegistrationsToValidate = new Set<Tax_Payer_Registration__c>([SELECT Status__c, Sub_Status__c, Service_Provider_Name__c, Levy_Contact__c, 
                                                                             Revenue_NSW_Status__c, RNSWCustomerId__c, Applied_For_Exemption__c 
                                                                             FROM Tax_Payer_Registration__c
                                                                             WHERE Levy_Contact__c IN :targetLevyContacts 
                                                                             AND Status__c = :GlobalConstants.STATUS_ACTIVE]);
        
        //fetching all registration records related to changed primary contact                                  
        for(Tax_Payer_Registration__c tempRegistration : [SELECT Status__c, Sub_Status__c, Service_Provider_Name__c, Levy_Contact__c, 
                                                          Revenue_NSW_Status__c, RNSWCustomerId__c, Applied_For_Exemption__c 
                                                          FROM Tax_Payer_Registration__c
                                                          WHERE Service_Provider_Name__c IN :accountIdVsTargetPrimaryContacts.keySet()
                                                          AND status__c = :GlobalConstants.STATUS_ACTIVE]) {
            
            relatedRegistrationsToValidate.add(tempRegistration);                                              
        }
        
        for(Tax_Payer_Registration__c tempRegistration : GlobalUtility.validateRegistrationUpdates(new List<Tax_Payer_Registration__c>(relatedRegistrationsToValidate))) {
       
         //if existing registration record and not a clonned older version
         if(!String.isBlank(tempRegistration.Id)) {
        
          //if details of levy contact have changed
          if(targetLevyContacts.contains(tempRegistration.Levy_Contact__c)) {
           
           Contact currentContact = newContacts.get(tempRegistration.Levy_Contact__c);
           
           if(String.isBlank(currentContact.FirstName) || String.isBlank(currentContact.LastName)
              || String.isBlank(currentContact.Levy_Contact_Phone__c) || String.isBlank(currentContact.Email)) {
              
              currentContact.addError(System.Label.Levy_Contact_Email_Mandatory);
           }   
           else {
           
            tempRegistration.Levy_Contact_First_Name__c = newContacts.get(tempRegistration.Levy_Contact__c).FirstName;
            tempRegistration.Levy_Contact_Last_Name__c = newContacts.get(tempRegistration.Levy_Contact__c).LastName;
            tempRegistration.Levy_Contact_Email__c = newContacts.get(tempRegistration.Levy_Contact__c).Email;
            tempRegistration.Levy_Contact_Phone__c = newContacts.get(tempRegistration.Levy_Contact__c).Levy_Contact_Phone__c;
           
            if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) {
            
                tempRegistration.IsAuthorisationUpdate__c = TRUE;
                tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
            }
            if(String.isBlank(tempRegistration.RNSWCustomerId__c) == true) {
            
                tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
            }   
           } 
          }
          
          //if details of primary contact have changed
          if(accountIdVsTargetPrimaryContacts.containsKey(tempRegistration.Service_Provider_Name__c)
                    && String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) {
            
                tempRegistration.IsProviderUpdate__c = TRUE;
                tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
          }
         }  
         
         relatedRegistrationsToUpsert.add(tempRegistration);      
        } 
        
        if(relatedRegistrationsToUpsert.size() > 0)
         Database.Upsert(new List<Tax_Payer_Registration__c>(relatedRegistrationsToUpsert), FALSE);
      }
      catch(Exception e) {
     
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'UpdateRelatedRegistrationsContactHelper', 'processRelatedRegistrations', e.getMessage(), e);
     }
    }
    
    /* 
     * Helper method to identify if either of the required fields on contact have changed or not
     */
    @TestVisible
    private Boolean hasContactInfoChanged(Contact newContact, Contact oldContact) {
      
       //if required specific fields of contact have changed
       if(newContact.FirstName != oldContact.FirstName || newContact.LastName != oldContact.LastName
          || newContact.Email != oldContact.Email || newContact.Levy_Contact_Phone__c != oldContact.Levy_Contact_Phone__c
          || newContact.Birthdate != oldContact.Birthdate || newContact.Australian_Driver_Licence_Number__c != oldContact.Australian_Driver_Licence_Number__c)
          return true;
          
       return false;
    }
}