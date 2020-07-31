@isTest
private class UpdateIsActiveCommunityUserTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;                        
        
    }
    
    @isTest
    private static void AuthorisationContactCreatorTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;         
        Id p = GlobalUtility.getASPProfile().id;        
        
        Contact con = new Contact(LastName ='testCon',AccountId = accountId, Email='test@contest.com');
        insert con;
        
        List<Id> userIds = new List<Id>();
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='sstester@noemail.com');
        
        insert user;        
        
        userIds.add(user.Id);
                
        test.startTest();
        System.runAs(user) {
            
           UpdateIsActiveCommunityUser.updateAssociatedContact(userIds);                    
        }
        test.stopTest(); 
        
        Contact c = [SELECT IsActiveCommunityUser__c from Contact where Id =: con.Id];                        
        System.assertEquals(TRUE, c.IsActiveCommunityUser__c);
        
    }
}