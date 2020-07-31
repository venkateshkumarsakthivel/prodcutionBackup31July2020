/**
* Helper class for server side rest resource LevyRegistrationTabController
*/
public without sharing class LevyRegistrationTabHelper {
    
    /* helper method to process registration updation */
    public static String processTaxPayerRegistrationContactUpdate(Tax_Payer_Registration__c taxPayerRegistration) {
        
        try {
            
            //if existing contact is chosen as levy contact person, stamp contact person details on the record
            if(taxPayerRegistration.Levy_Contact__c != NULL) {
                
                Contact existingLevyContact = [SELECT FirstName, LastName, Email, Phone, Levy_Contact_Phone__c
                                               FROM Contact
                                               WHERE Id = :taxPayerRegistration.Levy_Contact__c];
                
                
                taxPayerRegistration.Levy_Contact_First_Name__c = existingLevyContact.FirstName;
                taxPayerRegistration.Levy_Contact_Last_Name__c = existingLevyContact.LastName;
                taxPayerRegistration.Levy_Contact_Email__c = existingLevyContact.Email;
                taxPayerRegistration.Levy_Contact_Phone__c = existingLevyContact.Levy_Contact_Phone__c;
            }
            
            //update taxPayerRegistration;
            Contact levyContact = new Contact();
            
            //if existing contact is chosen as levy contact person, use its id for upsert
            if(taxPayerRegistration.Levy_Contact__c != NULL) {
            
                levyContact.Id = taxPayerRegistration.Levy_Contact__c;
            }
            else {
                
                levyContact.AccountId = taxPayerRegistration.Service_Provider_Name__c;
                levyContact.FirstName = taxPayerRegistration.Levy_Contact_First_Name__c;
                levyContact.LastName = taxPayerRegistration.Levy_Contact_Last_Name__c;
                levyContact.Email = taxPayerRegistration.Levy_Contact_Email__c;
                levyContact.Phone = taxPayerRegistration.Levy_Contact_Phone__c;
            }
            
            String serviceProviderOwnerId = [SELECT OwnerId FROM Account WHERE Id = :taxPayerRegistration.Service_Provider_Name__c].OwnerId;
            
            levyContact.Is_Access_Level_Levy_Administrator__c = taxPayerRegistration.Person_Enters_Returns_for_Levy__c == GlobalConstants.YES_VALUE ? TRUE : FALSE; 
            levyContact.OwnerId = serviceProviderOwnerId;
            upsert levyContact;
            
            taxPayerRegistration.Levy_Contact__c = levyContact.Id;
            taxPayerRegistration.Date_Registered__c = DateTime.Now(); 
            taxPayerRegistration.Date_Sent_to_Revenue__c = null;
            upsert taxPayerRegistration;
            
            //calling utility method to check and provide levy contact access to portal for accessing Levy stuff
            ManageAccountUsers.updateUser(new List<Id>{levyContact.Id});
            
            System.debug('Levy Granted User Creation Triggered !!');
            
            return taxPayerRegistration.Id;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyRegistrationTabHelper', 'processTaxPayerRegistrationUpdate', e.getMessage(), e);
            return NULL;
        }
    }
}