@isTest
public class UserProfileUpdaterControllerTest {
    
    @testSetup 
    static void setup(){
    Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void doProfileUpdateSuccessTest(){
    
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id aspId = GlobalUtility.getASPProfile().id;
        Id accountManagerId = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = aspId, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        PageReference pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        pageRef.getParameters().put('profileId', aspId);
         
        UserProfileUpdaterController puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
         
        user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
        System.assertEquals(aspId, user.ProfileId);
        
        pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        pageRef.getParameters().put('profileId', NULL);
         
        puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
         
        user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
        System.assertEquals(accountManagerId, user.ProfileId);
        
        pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
        
        user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
        System.assertEquals(accountManagerId, user.ProfileId);
        
        Id taxiASPId = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.Taxi_ASP_PROFILE_NAME].Id;
        user.ProfileId = taxiASPId;
        update user;
        pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
        
        user = [SELECT ProfileId, isActive FROM User WHERE Id = :user.Id];
        Id taxiAccountManagerId = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME].Id;
        System.assertEquals(taxiAccountManagerId, user.ProfileId);
        
        pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
        
        user = [SELECT ProfileId, isActive FROM User WHERE Id = :user.Id];
        System.assertEquals(taxiAccountManagerId, user.ProfileId);
        
        Id dvdId = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.DVD_USER].Id;
        user.ProfileId = dvdId;
        update user;
        pageRef = Page.ProfileUpdate;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('userId', user.Id);
        puc = new UserProfileUpdaterController();
        puc.doProfileUpdate();
        
        user = [SELECT ProfileId, isActive FROM User WHERE Id = :user.Id];
        System.assertEquals(FALSE, user.isActive);
        
        Test.stopTest();      
    }
    
    @isTest
    private static void doProfileUpdateFailureTest(){
    
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id aspId = GlobalUtility.getASPProfile().id;
        Id accountManagerId = [SELECT Id, Name FROM Profile WHERE Name =: GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = aspId, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user) {
        
        
         Test.startTest();
         PageReference pageRef = Page.ProfileUpdate;
         Test.setCurrentPageReference(pageRef); 
         pageRef.getParameters().put('userId', user.Id);
         pageRef.getParameters().put('profileId', aspId);
         
         UserProfileUpdaterController puc = new UserProfileUpdaterController();
         puc.doProfileUpdate();
         
         user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
         System.assertEquals(aspId, user.ProfileId);
         Test.stopTest();      
       } 
    }
}