@isTest
public class TakeOwnershipAuditControllerTest {
    @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    @isTest
    public  static void getNewOwnerNameTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        insert user;                
        String userName;
        test.startTest();
        System.runAs(user) {
            userName = TakeOwnershipAuditController.getNewOwnerName();                                    
        }
        test.stopTest();        
        System.assertEquals('Testing', userName);
    }
    @isTest
    public static void takeOwnershipTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='P2P Operations Level 1'].id;
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        User user = new User(alias = 'test123', email='newtest123@noemail.com',
                             emailencodingkey='UTF-8', lastname='newTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='newtester@noemail.com', UserRoleId = r.Id);
        insert user;
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        System.runAs(loggedInUser) {
            Account tempAcc = [SELECT OwnerId FROM Account];
            tempAcc.OwnerId = user.Id;
            update tempAcc;
        }
        String caseRec;
        test.startTest();
        System.runAs(user) {
            Case caseRecord = new Case(AccountId = accountId, Status = 'Draft', Sub_Status__c = 'Review Pending', Service_Type__c = 'Taxi', Type = 'Taxi', Sub_Type__c = 'New Application');
            insert caseRecord;
            String caseId = caseRecord.Id;
            system.debug('This is new case id'+caseId);
            caseRec = TakeOwnershipAuditController.takeOwnership(caseId);                                    
        }
        test.stopTest();
        System.assertEquals('SUCCESS', caseRec);
    }
    
}