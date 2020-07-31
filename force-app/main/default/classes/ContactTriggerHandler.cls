/*
 * Handler class to trigger execution on contact
 */
public with sharing class ContactTriggerHandler {
    
    public static void beforeUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        
        //deactivate users if contact is deactivated.
        PortalUserDeactivator deactivator = new PortalUserDeactivator(oldContacts, newContacts);
        deactivator.processForDeactivation();
        
        UpdateRelatedRegistrationsContactHelper contactRelatedRegistrationUpdate = new UpdateRelatedRegistrationsContactHelper(newContacts, oldContacts);
        contactRelatedRegistrationUpdate.processRelatedRegistrations(); 
        
        //AuditVendorUserManager auditUserManager = new AuditVendorUserManager(newContacts.values(), oldContacts);
        //auditUserManager.manageAuditVendorUsers();
    }
    
    public static void afterInsert(Map<Id, Contact> newContacts){
        
        //upgrade/degrade portal access for contact
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, new Map<Id, Contact>());
        accessUpdater.updateAccess();
        
        //AuditVendorUserManager auditUserManager = new AuditVendorUserManager(newContacts.values(), NULL);
        //auditUserManager.manageAuditVendorUsers();
    }
    
    public static void afterUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts){
        
        //upgrade or remove portal access for contact
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
    }
}