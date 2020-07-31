/*
 * @Description: Helper class to update contacts associated with authorisation/licence.
 * Running under without sharing mode to allow site guest user to update the contacts post payment from portal
 */
public without sharing class ContactUpdater{
    
    private List<Contact> contactsToUpdate;
    public ContactUpdater(List<Contact> contacts){
        if(contacts == null){
            throw new InvalidDataException('Failed to update contacts. Contact details missing.');
        }
        this.contactsToUpdate = contacts;
    }
    
    public void updateContacts(){
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        
        Database.update(contactsToUpdate, dml);
    }
    
    public class InvalidDataException extends Exception{}
}