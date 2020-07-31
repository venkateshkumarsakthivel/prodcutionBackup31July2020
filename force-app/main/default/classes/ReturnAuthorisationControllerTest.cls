@isTest
public class ReturnAuthorisationControllerTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;        
    }
    
    @isTest
    public static void validateAuthorisationRecordTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = GlobalConstants.AUTHORISATION_SUSPENDED, Service_Provider__c = accountId);
        insert authRecord;
        
        String authId = authRecord.Id;                
        String message;
        test.startTest();
        System.runAs(user) {
            message = ReturnAuthorisationController.validateAuthorisationRecord(authId);                                    
        }
        System.assertEquals('SUCCESS', message);
        test.stopTest();    
    }
    
    @isTest
    public static void validateAuthorisationRecordExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c();        
        
        String authId = authRecord.Id;                
        String updatedAuth;
        test.startTest();
        System.runAs(user) {
            updatedAuth = ReturnAuthorisationController.validateAuthorisationRecord(authId);                                    
        }
        test.stopTest();        
        
        System.assertEquals(null, updatedAuth);
    }
    
    @isTest
    public static void returnAuthorisationTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        insert authRecord;
        
        String authId = authRecord.Id;                
        String updatedAuth;
        test.startTest();
        System.runAs(user) {
            updatedAuth = ReturnAuthorisationController.returnAuthorisation(authId);                                    
        }
        test.stopTest();        
        
        System.assertEquals('SUCCESS', updatedAuth);
    }
    
    
    
    @isTest
    public static void returnAuthorisationExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c();        
        
        String authId = authRecord.Id;                
        String updatedAuth;
        test.startTest();
        System.runAs(user) {
            updatedAuth = ReturnAuthorisationController.returnAuthorisation(authId);                                    
        }
        test.stopTest();        
        
        System.assertEquals('ERROR', updatedAuth);
    }
    
}