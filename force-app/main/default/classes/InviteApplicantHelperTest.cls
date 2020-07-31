@IsTest
private with sharing class InviteApplicantHelperTest {

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            InviteApplicantHelper helper = new InviteApplicantHelper(null);
            System.assert(false);
        } catch(InviteApplicantHelper.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForActiveTaxiPortalUser(){
        List<Case> applications = [SELECT Id, AccountId, ContactId FROM Case];
        Set<Id> accountIds = new Set<Id>();
        for(Case app : applications){
            accountIds.add(app.AccountId);
        }
        List<User> portalUsers  = [SELECT Id FROM User WHERE AccountId IN :accountIds AND IsActive = true];
        
        System.Test.startTest();
        InviteApplicantHelper helper = new InviteApplicantHelper(applications);
        helper.invite();
        System.Test.stopTest();
        
        List<User> newPortalUsers = [SELECT Id FROM User WHERE AccountId IN :accountIds AND IsActive = true];
        System.assert(portalUsers.size() == newPortalUsers.size());
        System.assert(portalUsers[0].Id == newPortalUsers[0].Id);
    }
    
    private static testMethod void testForActiveASPPortalUser(){
        Account acc = createAccount('Test ASP Account');
        Contact con = createContact(acc.Id);
        createPortalUser(con.Id, GlobalUtility.getASPProfile().id);
        List<Case> applications = new List<Case>{createApplication(acc.Id, con.Id)};
        
        System.Test.startTest();
        InviteApplicantHelper helper = new InviteApplicantHelper(applications);
        helper.invite();
        System.Test.stopTest();
        Id taxiPlusAspProfile = GlobalUtility.getTaxiASPProfile().Id;
        List<User> portalUsers = [SELECT Id, ProfileId FROM User WHERE ContactId = :con.Id];
        System.assert(portalUsers.size() == 1);
        System.assert(portalUsers[0].ProfileId == taxiPlusAspProfile);
    }
    
    private static testMethod void testForInactivePortalAccount(){
        List<Case> applications = [SELECT Id, AccountId, ContactId FROM Case];
        Set<Id> accountIds = new Set<Id>();
        for(Case app : applications){
            accountIds.add(app.AccountId);
        }
        List<User> portalUsers  = [SELECT Id FROM User WHERE AccountId IN :accountIds AND IsActive = true];
        for(User user : portalUsers){
            user.IsActive = false;
        }
        update portalUsers;
        
        System.Test.startTest();
        InviteApplicantHelper helper = new InviteApplicantHelper(applications);
        helper.invite();
        System.Test.stopTest();
        List<User> newPortalUsers = [SELECT Id FROM User WHERE AccountId IN :accountIds AND IsActive = true];
        System.assert(portalUsers.size() == newPortalUsers.size());
        System.assert(portalUsers[0].Id == newPortalUsers[0].Id);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account acc = createAccount('Test Account');
        Contact con = createContact(acc.Id);
        createPortalUser(con.Id, GlobalUtility.getTaxiLicenceUserProfile().id);
        createApplication(acc.Id, con.Id);
    }
    
    private static Account createAccount(String accName){
        Id ownerid = GlobalUtility.getOwnerId();
        Account acc = new Account(name = accName, BillingStreet='Castlereagh Street', 
            BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert acc;
        return acc;
    }
    
    private static Contact createContact(Id accId){
        Long millis = System.now().getTime();
        Contact con = new Contact(LastName ='testCon',AccountId = accId, Email= millis + 'test@example.com');
        insert con;
        return con;
    }
    
    private static Case createApplication(Id actId, Id conId){
        Case application = new Case();
        application.AccountId = actId;
        application.ContactId = conId;
        application.Status = GlobalConstants.CASE_DRAFT;
        application.Sub_Status__c = GlobalConstants.CASE_DRAFT;
        
        insert application;
        return application;
    }
    
    private static User createPortalUser(Id conId, Id profileId){
        Long millis = System.now().getTime();
        User user = new User(alias = 'test123', email='test123@example.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username= millis + 'tester@noemail.com');
        insert user;
        return user;
    }   
}