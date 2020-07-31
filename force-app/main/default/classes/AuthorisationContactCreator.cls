public with sharing class AuthorisationContactCreator {
    
    private List<Contact> newContacts;
    private List<Authorisation__c> authorisations;
    
    public AuthorisationContactCreator(List<Contact> newContacts, List<Authorisation__c> authorisations){        
        if(authorisations == null || newContacts == null){
            throw new InvalidDataException('Failed to create authorisation contact.' 
                + ' Either contact or authorisation details missing.');
        }
        this.authorisations = authorisations;
        this.newContacts = newContacts;
    }
    
    public List<Authorisation_Contact__c> create(){
        Map<Id, List<Authorisation__c>> actVsAuthorisation = new Map<Id, List<Authorisation__c>>();        
        for(Authorisation__c auth : authorisations){
            if(!actVsAuthorisation.containsKey(auth.Service_Provider__c)){
                actVsAuthorisation.put(auth.Service_Provider__c, new List<Authorisation__c>());
            }
            actVsAuthorisation.get(auth.Service_Provider__c).add(auth);
        }
        
        List<Authorisation_Contact__c> authContacts = new List<Authorisation_Contact__c>();        
        for(Contact con : newContacts){            
            if(actVsAuthorisation.get(con.AccountId) != null){
                for(Authorisation__c auth: actVsAuthorisation.get(con.AccountId)){
                    authContacts.add(createAuthContact(con, auth));
                }
            }       
        }
        insert authContacts;       
        return authContacts; 
    }
    
    private Authorisation_Contact__c createAuthContact(Contact con, Authorisation__c auth){
        Authorisation_Contact__c authCon = new Authorisation_Contact__c();
        authCon.Contact__c = con.Id;
        authCon.Authorisation__c = auth.Id;
        return authCon;
    }
    
    public class InvalidDataException extends Exception {}
}