@IsTest
private with sharing class ContactTriggerHandlerTest {
    
    public static testMethod void testForBeforeUpdate(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = createContact(acc.Id);
        con.Email = 'updatedTest@example.com';
        System.Test.startTest();
        update con;
        System.Test.stopTest();
        con = [SELECT Id, Email FROM Contact];
        System.assert(con.Email == 'updatedTest@example.com');
    }
    
    public static testMethod void testForAfterInsert(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.Test.startTest();
        Contact con = createContact(acc.Id);
        System.Test.stopTest();
        System.assert(con.Id != null);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account acc = createAccount();        
    }
    
    private static Account createAccount(){
        Account acc = new Account(name ='testAcc', BillingStreet='Castlereagh Street', 
            BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert acc;
        return acc;
    }
    
    private static Contact createContact(Id accId){
        Contact con = new Contact(LastName ='testCon',AccountId = accId, Email='test@example.com');
        insert con;
        return con;
    }
}