/**
 *  Description: Account trigger handler class
*/
public with sharing class AccountTriggerHandler {

  //before update handler
  public static void beforeUpdate(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
     
     UpdateRelatedRegistrationsAccountHelper accountRelatedRegistrationUpdate = new UpdateRelatedRegistrationsAccountHelper(newAccounts, oldAccounts);
     accountRelatedRegistrationUpdate.processRelatedRegistrations();
     
     //AuditVendorRoleCreator auditVendorRoleCreator = new AuditVendorRoleCreator(newAccounts.values());
     //auditVendorRoleCreator.createAuditVendorRoles();   
  }
  
  //after update handler
  public static void afterUpdate(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
     
     AuditVendorAccountDeactivator auditAccountDeactivator = new AuditVendorAccountDeactivator(newAccounts, oldAccounts);
     auditAccountDeactivator.deactivateAuditVendorAccounts();
      
  }
}