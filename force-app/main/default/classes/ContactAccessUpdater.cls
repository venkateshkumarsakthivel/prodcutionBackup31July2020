/*
 * @Description: Helper class to qualify and update portal access for given contact
 */
public with sharing class ContactAccessUpdater {
    
    private Map<Id, Contact> oldContacts;
    private Map<Id, Contact> newContacts;
    
    public ContactAccessUpdater(Map<Id, Contact> newContacts, Map<Id,Contact> oldContacts){
        if(newContacts == null || oldContacts == null){
            throw new InvalidDataException('Failed to check for access. Contact details missing');
        }
        this.oldContacts = oldContacts;
        this.newContacts = newContacts;
    }
    
    public void updateAccess(){
        List<Id> qualifiedContacts = new List<Id>();
        for(Contact newCon : newContacts.values()){
            if(isQualifiedForUpdate(newCon)){
                qualifiedContacts.add(newCon.Id);
            }
        }
        
        if(!qualifiedContacts.isEmpty()){
            ManageAccountUsers.updateUser(qualifiedContacts);
        }
    }
    
    private Boolean isQualifiedForUpdate(Contact newContact){
        if((oldContacts.get(newContact.Id) != null
                && (oldContacts.get(newContact.Id).Is_Access_Level_Account_Administrator__c != newContact.Is_Access_Level_Account_Administrator__c 
                     || oldContacts.get(newContact.Id).Is_Access_Level_DVD_Administrator__c != newContact.Is_Access_Level_DVD_Administrator__c
                     || oldContacts.get(newContact.Id).Is_Access_Level_Levy_Administrator__c != newContact.Is_Access_Level_Levy_Administrator__c
                     || oldContacts.get(newContact.Id).Is_Access_Level_Taxi_Agent__c != newContact.Is_Access_Level_Taxi_Agent__c)) 
                || (oldContacts.isEmpty() 
                     && (newContact.Is_Access_Level_Account_Administrator__c 
                          || newContact.Is_Access_Level_DVD_Administrator__c 
                          || newContact.Is_Access_Level_Levy_Administrator__c
                          || newContact.Is_Access_Level_Taxi_Agent__c))){
            return true;
        }
        return false;
    }
    
    public class InvalidDataException extends Exception {}
}