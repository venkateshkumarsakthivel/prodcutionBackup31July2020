/*
 * @Description: Helper class to identify the primary contact for an account
 */
public with sharing class PrimaryContactRetriever {
    
    private Map<Id, List<Contact>> actVsContacts;
    
    public PrimaryContactRetriever(Set<Id> serviceProviders){
        retrieveContactDetails(serviceProviders);
    }
    
    private void retrieveContactDetails(Set<Id> serviceProviders){
        actVsContacts = new Map<Id, List<Contact>>();
        List<Account> acts = [  SELECT Id, (SELECT Id, Primary_Contact__c, Email FROM Contacts WHERE Deactivated__c = false)
                                FROM Account
                                WHERE Id IN :serviceProviders];
        for(Account serviceProvider: acts){
            actVsContacts.put(serviceProvider.Id, new List<Contact>());
            if(serviceProvider.Contacts != null){
                actVsContacts.put(serviceProvider.Id, serviceProvider.Contacts);
            }
        }
    }
    
    public Id identifyPrimaryContact(Id actId){
        Contact primaryCon = new Contact();
        if(actVsContacts.get(actId) != null && actVsContacts.get(actId).size() == 1){
            primaryCon = actVsContacts.get(actId)[0];
        } else if(actVsContacts.get(actId) != null && actVsContacts.get(actId).size() > 0){
            for(Contact con :actVsContacts.get(actId)){
                if(con.Primary_Contact__c){
                    primaryCon = con;
                    break;
                } else if(!String.isBlank(con.Email)){
                    primaryCon = con;
                }
            }
            if(primaryCon.Id == null){
                primaryCon = actVsContacts.get(actId)[0];
            }
        }
        return primaryCon.Id;
    }
}