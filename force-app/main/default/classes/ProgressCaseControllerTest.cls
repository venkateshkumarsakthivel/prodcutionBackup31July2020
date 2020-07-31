@isTest
public class ProgressCaseControllerTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @isTest
    public static void getNewOwnerNameTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;                
        
        String userName;
        
        test.startTest();
        System.runAs(user) {
            userName = ProgressCaseController.getNewOwnerName();                                    
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
        //Id p = GlobalUtility.getASPProfile().id;  
        User user = new User(alias = 'test123', email='newtest123@noemail.com',
                             emailencodingkey='UTF-8', lastname='newTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             
                             timezonesidkey='America/Los_Angeles', username='newtester@noemail.com', UserRoleId = r.Id);
        
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
            caseRec = ProgressCaseController.takeOwnership(caseId);
            Case caseRecord1 = new Case(AccountId = accountId, Status = 'Draft', Sub_Status__c = 'Assessment Pending', Service_Type__c = 'Taxi', Type = 'Taxi', Sub_Type__c = 'New Application');
            insert caseRecord1;
            caseRec = ProgressCaseController.takeOwnership(caseRecord1.Id);
            Case caseRecord2 = new Case(AccountId = accountId, Status = 'Draft', Sub_Status__c = 'Decision Pending', Service_Type__c = 'Taxi', Type = 'Taxi', Sub_Type__c = 'New Application');
            insert caseRecord2;
            caseRec = ProgressCaseController.takeOwnership(caseRecord2.Id);
            
        }
        test.stopTest();
        
        System.assertEquals('SUCCESS', caseRec);
    }
    
    
    
    
    @isTest
    public static void takeOwnershipOnBehalfTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='P2P Operations Level 1'].id;
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        User user = new User(alias = 'test123', email='newtest123@noemail.com',
                             emailencodingkey='UTF-8', lastname='newTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,                             
                             timezonesidkey='America/Los_Angeles', username='newtester@noemail.com', UserRoleId = r.Id);
        
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
            Case caseRecord = new Case(AccountId = accountId, Status = 'Lodged', Sub_Status__c = 'Review Pending', OwnerId = user.Id, Type = 'Service Provider', Sub_Type__c = 'New Application');
            insert caseRecord;
            
            String caseId = caseRecord.Id;
            caseRec = ProgressCaseController.takeOwnership(caseId);                                    
        }
        test.stopTest();        
        
        System.assertEquals('ON-BEHALF OF APPLICANT ERROR', caseRec);
    }
    
    @isTest
    public static void takeOwnershipExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='newtest123@noemail.com',
                             emailencodingkey='UTF-8', lastname='newTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,                             
                             timezonesidkey='America/Los_Angeles', username='newtester@noemail.com');
        
        insert user;                
        
        
        String caseRec;
        
        test.startTest();
        System.runAs(user) {
            Case caseRecord = new Case();
            String caseId = caseRecord.Id;
            caseRec = ProgressCaseController.takeOwnership(caseId);                                    
        }
        test.stopTest();        
        
        System.assertEquals('ERROR', caseRec);
    }
}