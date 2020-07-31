@IsTest
private with sharing class PortalUserDeactivatorTest{
    
    private static testMethod void testForContactDeactivate(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Deactivated__c, Deactivation_Date__c FROM Contact]);
        for(Contact newContact : newContacts.values()){
            newContact.Deactivated__c = true;
        }
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Deactivated__c, Deactivation_Date__c FROM Contact]);
        
        System.Test.startTest();
        PortalUserDeactivator deactivator = new PortalUserDeactivator(oldContacts, newContacts);
        deactivator.processForDeactivation();
        System.Test.stopTest();
        for(Contact newContact : newContacts.values()){
            System.assert(newContact.Deactivation_Date__c != null);
        }
        List<User> portalUsers = [SELECT Id FROM User WHERE ContactId IN :newContacts.values() AND IsActive = true];
        System.assert(portalUsers.isEmpty());
    }
    
    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            PortalUserDeactivator deactivator = new PortalUserDeactivator(null, null);
            System.assert(false);
        } catch(PortalUserDeactivator.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForNonEligibleContact(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id,Status__c, Deactivated__c, Deactivation_Date__c FROM Contact]);
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Status__c,Deactivated__c, Deactivation_Date__c FROM Contact]);
        
        System.Test.startTest();
        PortalUserDeactivator deactivator = new PortalUserDeactivator(oldContacts, newContacts);
        deactivator.processForDeactivation();
        System.Test.stopTest();
        for(Contact newContact : newContacts.values()){
            System.assert(newContact.Deactivation_Date__c == null);
            System.assert(newContact.Deactivated__c == false);
        }
        List<User> portalUsers = [SELECT Id FROM User WHERE ContactId IN :newContacts.values() AND IsActive = true];
        System.assert(!portalUsers.isEmpty());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account acc = createAccount();
        Contact con = createContact(acc.Id);
        createPortalUser(con.Id);
    }
    
    private static Account createAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account acc = new Account(name ='testAcc', BillingStreet='Castlereagh Street', 
            BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerID=ownerid);
        insert acc;
        return acc;
    }
    
    private static Contact createContact(Id accId){
        Contact con = new Contact(LastName ='testCon',AccountId = accId, Email='test@example.com');
        insert con;
        return con;
    }
    
    private static User createPortalUser(Id conId){
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@example.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        return user;
    }
}