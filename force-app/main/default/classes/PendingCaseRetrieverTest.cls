@isTest
public class PendingCaseRetrieverTest {
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @isTest
    private static void retrieveAllCasesTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Account ac2 = new Account(name ='testAcc2', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac2;
        
        
        
        Test.startTest();
        List<Case> resultList = new List<Case>();
        
        
        
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            Case c = new Case(AccountId = ac2.Id, Service_Type__c = 'Taxi', Status = 'New');
            caseList.add(c);
        }
        insert caseList;
        
        resultList = PendingCaseRetriever.retrieveAllCases();
        Test.stopTest();
        
        system.assertEquals(5, resultList.size());
    }
    
    // while inserting case, case assignment rule is fired, since dmloptions are turned off.
    // also updating case causes to fire assignment rule.
    // since it is not matching the owners and hence dose not cover the class.
    
    @isTest
    private static void retrieveMyCasesTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Test.startTest();
        List<Case> caseList = new List<Case>();
        List<Case> resultList = new List<Case>();
        
        Case c = new Case(AccountId = accountId ,ContactId = conId, OwnerId = UserInfo.getUserId(),Service_Type__c = 'Taxi', Status = 'New', Sub_Status__c = '', Type='', Sub_Type__c='');

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        dmo.assignmentRuleHeader.assignmentRuleID = null;
        c.setOptions(dmo);
        insert(c);
       
        List<case> s =[Select OwnerId FROM Case];
        
        s[0].OwnerId=UserInfo.getUserId();
        
        update s;
        
        system.debug('OwnerId: '+s[0].OwnerId+':CaseOwner Id: '+UserInfo.getUserId());
        resultList = [SELECT Id, CaseNumber, Status, Sub_Status__c, Type, Sub_Type__c, Date_Submitted__c, AccountId, Account.Name 
                            FROM Case 
                            WHERE OwnerId = :UserInfo.getUserId()
                            LIMIT 20];
        resultList = PendingCaseRetriever.retrieveMyCases();
        system.assertEquals(1, resultList.size());
        Test.stopTest();
    }
}