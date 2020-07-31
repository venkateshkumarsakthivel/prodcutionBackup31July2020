@IsTest
private with sharing class ContactUpdaterTest {
    
    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            ContactUpdater updater = new ContactUpdater(null);
            System.assert(false);
        } catch(ContactUpdater.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForContactUpdate(){
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];
        for(Contact con : contacts){
            con.LastName = 'Test';
        }
        System.Test.startTest();
        ContactUpdater updater = new ContactUpdater(contacts);
        updater.updateContacts();
        System.Test.stopTest();
        contacts = [SELECT Id FROM Contact WHERE LastName = 'Test'];
        System.assert(!contacts.isEmpty());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        createContact(act.Id, false);
    }
    
    private static Account createAccount(){
        Account act = new Account();
        act.Name = 'Test Account';
        act.Email__c = 'test@example.com';
        act.Notice_Email__c = 'test@example.com';
        act.Notice_Address_City__c = 'Sydney';
        act.Notice_Address_Country__c = 'Australia';
        act.Notice_Address_Postal_Code__c = '2000';
        act.Notice_Address_State__c = 'NSW';
        act.Notice_Address_Street__c = '333 George Street';
        act.ACN__c = '000000019';
        act.ABN__c = '89000000019';
        
        insert act;
        return act;        
    }
    
    private static Contact createContact(Id actId, Boolean isPrimary){
        Contact con = new Contact();
        con.AccountId = actId;
        con.Email = 'test@example.com';
        con.FirstName = 'Test';
        con.LastName = 'User';
        con.Contact_Type__c = GlobalConstants.CONTACT_GENERAL_CONTACT ;
        con.Deactivated__c = false;
        con.Primary_Contact__c = isPrimary;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        
        Database.insert(con, dml);
        return con;
    }
}