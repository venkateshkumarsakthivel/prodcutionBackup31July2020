@isTest
public class LoggedInUserControllerTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @isTest
    private static void getLoggedInUserTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;               
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String usr;
        
        Test.startTest();
        usr = LoggedInUserController.getLoggedInUser();
        System.assertNotEquals(NULL, usr);
        
        System.runAs(user) {
            
            usr = LoggedInUserController.getLoggedInUser();
            System.assertNotEquals(NULL, usr);
        }
        Test.stopTest();
        
        system.assert(usr != null);
    }
    
    @isTest
    private static void hasBothCommunityAccessTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        System.assertEquals(FALSE, LoggedInUserController.hasBothCommunityAccess());
        
        System.runAs(user) {
            
            System.assertEquals(TRUE, LoggedInUserController.hasBothCommunityAccess());
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void renderOtherTilesTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Boolean usr;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        usr = LoggedInUserController.renderOtherTiles();
        System.assertEquals(True, usr);        
        
        System.runAs(user) {
            
            usr = LoggedInUserController.renderOtherTiles();
            System.assertEquals(True, usr);        
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void renderDVDTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Boolean usr;
        
        Test.startTest();         
        usr = LoggedInUserController.renderDVD();
        System.assertEquals(True, usr);        
        
        System.runAs(user) {
            
            usr = LoggedInUserController.renderDVD();
            System.assertEquals(True, usr);        
        }
        
        Test.stopTest();                
    }
    
}