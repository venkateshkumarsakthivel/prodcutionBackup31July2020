/*
 * @Description: Helper class to deactivate portal users
 */
public without sharing class PortalUserDeactivator {
    private Map<Id, Contact> newContactMap;
    private Map<Id, Contact> oldContactMap;
    
    //Function to deactivate user after contact deactivation.
    @future
    public static void deactivatePortalUser(List<Id> conId){
        System.debug('Ids for user deactivation '+ conId);
        List<User> users = new List<User>();
        for(User u : [SELECT Id, IsActive FROM User WHERE ContactId  IN : conId AND IsActive = true]){      
            u.IsActive = false;
            users.add(u);            
        }
        
        update users;
    }
    
    public PortalUserDeactivator(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap){
        if(newContactMap == null || oldContactMap == null || oldContactMap.isEmpty() || newContactMap.isEmpty()){
            throw new InvalidDataException('Failed to deactivate user. Contact details missing.');
        }
        this.newContactMap = newContactMap;
        this.oldContactMap = oldContactMap;
    }
    
    public void processForDeactivation(){
        
        List<Id> contactsToDeactivate = new List<Id>();
        for(Contact newContact :newContactMap.values()){
            if(isQualifiedForDeactivation(newContact)){
                newContact.Deactivation_Date__c  = System.today();
                contactsToDeactivate.add(newContact.Id);
            }
        }
        
        if(!(System.isFuture() || System.isBatch()))
         PortalUserDeactivator.deactivatePortalUser(contactsToDeactivate);
    }
    
    private Boolean isQualifiedForDeactivation(Contact newContact){
        //verify if the contact is requested for deactivation.
        if(oldContactMap.get(newContact.Id) != null
                && (oldContactMap.get(newContact.Id).Deactivated__c != newContact.Deactivated__c
                    && newContact.Deactivated__c)
                    || (oldContactMap.get(newContact.Id).Status__c != newContact.Status__c
                         && newContact.Status__c == GlobalConstants.INACTIVE_CONTACT_STATUS)){
            return true;
        }
        return false;
    }
    
    public class InvalidDataException extends Exception {}
}