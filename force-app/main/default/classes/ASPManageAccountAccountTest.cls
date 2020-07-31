@isTest
public class ASPManageAccountAccountTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
           Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    //this test verifies account name of current ASP user running
    @isTest
    public static void testGetAccount(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Account acc;
        test.startTest();
        System.runAs(user) {
            String str = ASPManageAccountAccount.getAccountDetails('');
            acc = (Account)JSON.deserialize(str, Account.class);
            System.debug('acc === '+acc);
        }
        test.stopTest();
        System.assertEquals('testAcc', acc.name);
        
    }
    
    
    
    //This method vefies all the data is cottectly stored or not in backend
    @isTest
    public static void testSaveAccountDetails(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Account acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE name = 'testAcc' LIMIT 1];
        test.startTest();
        System.runAs(user) {
            ASPManageAccountAccount.saveAccountDetails(acc.Id, 'New Street', 'Sydney', 'NSW', '2010', 'High Street', 'Melbourne', 'VIC', '1010');
        }
        test.stopTest();
        System.debug('outside test');
        Account newAcc = [SELECT Id, name, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                          FROM Account 
                          WHERE name = 'testAcc'
                          LIMIT 1];
        
        System.assertEquals('testAcc', newAcc.name);
        System.assertEquals('New Street', newAcc.BillingStreet);
        System.assertEquals('Sydney', newAcc.BillingCity);
        System.assertEquals('NSW', newAcc.BillingState);
        System.assertEquals('2010', newAcc.BillingPostalCode);
        System.assertEquals('High Street', newAcc.ShippingStreet);
        System.assertEquals('Melbourne', newAcc.ShippingCity);
        System.assertEquals('VIC', newAcc.ShippingState);
        System.assertEquals('1010', newAcc.ShippingPostalCode);
    }
    
    
    @isTest
    public static void testSaveAccountDetailsException(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Account acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE name = 'testAcc' LIMIT 1];
        test.startTest();
        System.runAs(user) {
            ASPManageAccountAccount.saveAccountDetails(null, 'New Street', 'Sydney', 'NSW', '2010', 'High Street', 'Melbourne', 'VIC', '1010');
        }
        test.stopTest();
        System.debug('outside test');
        Account newAcc = [SELECT Id, name, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                          FROM Account 
                          WHERE name = 'testAcc'
                          LIMIT 1];
        
        System.assertEquals('testAcc', newAcc.name);
        System.assertEquals('Castlereagh Street', newAcc.BillingStreet);
        System.assertEquals('Sydney', newAcc.BillingCity);
        System.assertEquals('NSW', newAcc.BillingState);
        System.assertEquals('2000', newAcc.BillingPostalCode);
        System.assertEquals(null, newAcc.ShippingStreet);
        System.assertEquals(null, newAcc.ShippingCity);
        System.assertEquals(null, newAcc.ShippingState);
        System.assertEquals(null, newAcc.ShippingPostalCode);
    }
    
    @isTest
    public static void testUpdateAccountDetails(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Account acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE name = 'testAcc' LIMIT 1];
        acc.BillingState = 'VIC';
        acc.BillingPostalCode = '2011';
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', acc);
        String jsonstr = (String)JSON.serialize(parameters.get('SObject'));
        
        test.startTest();
        System.runAs(user) {
            ASPManageAccountAccount.updateAccount(jsonstr);
        }
        test.stopTest();
        Account newAcc = [SELECT Id, name, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                          FROM Account 
                          WHERE name = 'testAcc'
                          LIMIT 1];
        System.assertEquals('VIC', newAcc.BillingState);
        System.assertEquals('2011', newAcc.BillingPostalCode);
    }
    
    
    @isTest
    public static void testUpdateAccountDetailsException(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Account acc = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE name = 'testAcc' LIMIT 1];
        acc.BillingState = 'VIC';
        acc.BillingPostalCode = '2011';
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('SObject', acc);
        String jsonstr = (String)JSON.serialize(null);
        
        test.startTest();
        System.runAs(user) {
            ASPManageAccountAccount.updateAccount(jsonstr);
        }
        test.stopTest();
        Account newAcc = [SELECT Id, name, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                          FROM Account 
                          WHERE name = 'testAcc'
                          LIMIT 1];
        System.assertEquals('NSW', newAcc.BillingState);
        System.assertEquals('2000', newAcc.BillingPostalCode);
    }
    
    
    @isTest
    public static void submitHelpRequestTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Case caseRec = new Case(AccountId = accountId, ContactId = conId, Status = 'New');
        insert caseRec;
        
        test.startTest();
        System.runAs(user) {
            ASPManageAccountAccount.submitHelpRequest();
            Case retriveCase = [SELECT Id, AccountId from Case Where AccountId =:accountId limit 1];
            System.assertEquals(caseRec.AccountId, retriveCase.AccountId);
        }
        test.stopTest();        
    }
    
}