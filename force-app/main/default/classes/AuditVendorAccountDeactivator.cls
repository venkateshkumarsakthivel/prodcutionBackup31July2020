/*
 * Helper class to deactivate all related audit vendor record type contacts when
 * audit vendor account is marked as inactive
*/
public without sharing class AuditVendorAccountDeactivator {
  
  private Map<Id, Account> newAccounts;
  private Map<Id, Account> oldAccounts;
    
  public AuditVendorAccountDeactivator(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts){
        
   this.newAccounts = newAccounts;
   this.oldAccounts = oldAccounts;
  }
  
  public void deactivateAuditVendorAccounts() {
   
   try {
      
      Set<String> deactivateAuditAccountIds = new Set<String>();
      List<Contact> auditContactsToDeactivate = new List<Contact>();
      
      for(Account tempAuditAcc : newAccounts.values()) {
         
         if(tempAuditAcc.Record_Type_Dev_Name__c == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_AUDIT_VENDOR
             && tempAuditAcc.Auditor_Status__c == GlobalConstants.AUDITOR_STATUS_INACTIVE
             && oldAccounts.get(tempAuditAcc.Id).Auditor_Status__c != tempAuditAcc.Auditor_Status__c) {
             
            deactivateAuditAccountIds.add(tempAuditAcc.Id);  
         }
      }
      
      for(Contact tempAuditContact : [SELECT Id, Status__c, AccountId 
                                       FROM Contact
                                       WHERE AccountId IN :deactivateAuditAccountIds]) {
           
             tempAuditContact.Status__c = GlobalConstants.AUDITOR_STATUS_INACTIVE;
             auditContactsToDeactivate.add(tempAuditContact);                             
      }
      
      if(auditContactsToDeactivate.size() > 0)
         Database.update(auditContactsToDeactivate, false);
   }
   catch(Exception e) {
     
     System.debug('Exception: '+e);
     ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AuditVendorAccountDeactivator', 'deactivateAuditVendorAccounts', e.getMessage(), e);
   }
  }
}