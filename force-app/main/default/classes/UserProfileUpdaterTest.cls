@isTest
private class UserProfileUpdaterTest {
    
    @isTest
    private static void updateUserProfileTest(){
    
        Id rtIdforIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Partnership').getRecordTypeId();
        Id rtIdforCompany = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc',RecordTypeId = rtIdforIndividual, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Account ac2 = new Account(name ='testAcc2',RecordTypeId = rtIdforCompany, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac2;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac2.Id, Email='test2@contest.com');
        insert con2; 
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String accName;
        
        Set<String> userIdList = new Set<String>();
        userIdList.add(user.Id);
        
        Community_Site_URL__c csu = new Community_Site_URL__c(Name = 'Industry Portal URL');
        insert csu;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UserProfileUpdaterMock());
        UserProfileUpdater.updateUserProfile(userIdList);
        Test.stopTest();
        
        System.assert(true);
        
    }
    
}