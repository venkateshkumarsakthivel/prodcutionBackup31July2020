@isTest
public class LevyNewAssessmentControllerTest {

    @testSetup 
    static void setup() {
    
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Authorisation__c tempAuth = new Authorisation__c();
        tempAuth.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        tempAuth.Service_Provider__c = ac.Id;
        insert tempAuth;
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, Levy_Contact__c = con.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayerData;
            
        Assessment__c tempRelatedAssessment = new Assessment__c();
        tempRelatedAssessment.Account__c = ac.Id;
        tempRelatedAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_OPEN;
        tempRelatedAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT;
        tempRelatedAssessment.Period_Start_Date__c = System.Today().addMonths(-2);
        tempRelatedAssessment.Taxpayer_Registration__c = taxPayerData.Id;
        insert tempRelatedAssessment;
    }
    
    @isTest
    private static void getTPRDetailsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
          
          System.assertNotEquals(NULL, LevyNewAssessmentController.getTPRDetails(accountId));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void getTPRDetailsFailureTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
          
          System.assertEquals(NULL, LevyNewAssessmentController.getTPRDetails(NULL));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void retrieveMatchingAssessmentsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
           
           System.assertNotEquals(0, LevyNewAssessmentController.retrieveMatchingAssessments(System.Today().addMonths(-2).toStartOfMonth().format(), LevyNewAssessmentController.getTPRDetails(accountId)).size());
        }
        
        Test.stopTest();
    }
     
    @isTest
    private static void retrieveMatchingAssessmentsFailureTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
           
           System.assertEquals(NULL, LevyNewAssessmentController.retrieveMatchingAssessments(NULL, NULL));
        }
        
        Test.stopTest();
    }
     
    @isTest
    private static void createCaseRecordTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
          
          System.assertNotEquals(NULL, LevyNewAssessmentController.createCaseRecord(System.Today().addMonths(-2).toStartOfMonth().format(), LevyNewAssessmentController.getTPRDetails(accountId), 'Audit & Compliance', 'Other', 'Test Description'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void createCaseRecordFailureTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
          
          System.assertEquals(NULL, LevyNewAssessmentController.createCaseRecord(NULL, NULL, 'Audit & Compliance', 'Other', 'Test Description'));
        }
        
        Test.stopTest();
    }
     
    @isTest
    private static void hasLevyAssessmentAccessTest() {
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        Profile p2 = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 1'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester123' + System.now().getTime() +'@noemail.com');
        insert user;
        
        User user2 = new User(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_AU', profileid = p2.Id, country='Australia', IsActive =true,
                              timezonesidkey='Australia/Sydney', username='tester1234' + System.now().getTime() +'@noemail.com');
        
        insert user2;
        
        Test.startTest();
        
        System.runAs(user) {
          
          System.assertEquals(TRUE, LevyNewAssessmentController.hasLevyAssessmentAccess());
        }
        
        System.runAs(user2) {
        
          System.assertEquals(FALSE, LevyNewAssessmentController.hasLevyAssessmentAccess());
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void retrieveLevyEndDateTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        Profile p2 = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 1'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester123' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        
        System.runAs(user) {
          
          System.assertNotEquals(NULL, LevyNewAssessmentController.retrieveLevyEndDate(System.Today().addMonths(-2).toStartOfMonth().format(), LevyNewAssessmentController.getTPRDetails(accountId)));
        }
        
        Test.stopTest();
    }
}