@isTest
private class ASPManageAccountCasesTest {
    
    @testSetup 
    static void setup(){
          Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000'
                             ,OwnerId=ownerid);
        
        //changed ownerId = UserInfo.getUserId() to OwnerId=ownerid to remove exception
        
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void getLoggedInUserAccountTest(){
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
        Test.startTest();
        System.runAs(user) {
            accName = ASPManageAccountCases.getLoggedInUserAccount();
        }
        Test.stopTest();
        
        System.assert(accName != null);
        
    }
    
    @isTest
    private static void getNoticeDetailsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        String jsonString;
        
        Test.startTest();
        System.runAs(user) {
           
            List<Notice_Record__c> NoticeList = new List<Notice_Record__c>();
            for(Integer i = 0; i < 5; i++){
                Notice_Record__c nr = new Notice_Record__c(Who_issued_the_notice__c = 'ABC', Date_Issued__c = System.today() - 20, Method_of_Service__c = 'Email', Notice_Type__c = 'Authorisation expired notice', Issued_To__c = user.AccountId);
                //Notice_Record__c nr = new Notice_Record__c(Served_to__c = 'XYZ', Who_issued_the_notice__c = 'ABC', Date_Issued__c = System.today() - 20, Method_of_Service__c = 'Email', Notice_Type__c = 'Authorisation expired notice', Issued_To__c = user.AccountId);
                
                
                NoticeList.add(nr);
            }
            insert NoticeList;
            jsonString = ASPManageAccountCases.getNoticeDetails();
            
           
           
            System.assert(jsonString != null);
        }
        Test.stopTest();
        
    }
    
    
    
    @isTest
    private static void getApplicationCasesTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
       
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com' );
        
        insert user;
        String jsonString;
        List<Case> listCases = new List<Case>();
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Individual Application').getRecordTypeId();
        Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Corporation Application').getRecordTypeId();
        
        Test.startTest();
        System.runAs(user) {
            List<Case> caseList = new List<Case>();
            for(Integer i = 0; i < 5; i++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
                caseList.add(c);
            }
            for(Integer j = 0; j < 5; j++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', 
                                  Status = 'New' , RecordTypeId = rtIdforIndividual
                                 );
                caseList.add(c);
            }
            insert caseList;
            jsonString = ASPManageAccountCases.getApplicationCases();
        }
        Test.stopTest();
        listCases = (List<Case>)JSON.deserialize(jsonString, List<Case>.class);
        System.assertEquals(10, listCases.size());
    }
    
    @isTest
    private static void withdrawASPApplicationExceptionTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;        
        
        Case caseRec = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New');
        insert caseRec;                
        
        String withdrawReturn;
        Test.startTest();
        System.runAs(user) {
            withdrawReturn = ASPManageAccountCases.withdrawASPApplication(caseRec);
        }
        Test.stopTest();
        System.assertEquals(null, withdrawReturn);
        
    }
    
    @isTest
    private static void withdrawASPApplicationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Case caseRec = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'New');
        insert caseRec;  
        
        Authorisation__c authRec = new Authorisation__c(Application__c =caseRec.Id,Service_Provider__c = accountId);
        insert authRec;
        
        String withdrawReturn;
        Test.startTest();
        withdrawReturn = ASPManageAccountCases.withdrawASPApplication(caseRec);
        Test.stopTest();
        system.debug('withdrawReturn: '+withdrawReturn);
        //System.assertEquals(GlobalConstants.SUCCESS_MESSAGE_TO_BE_RETURNED, withdrawReturn);
        
    }
    
}