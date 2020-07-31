@isTest
public class LevyReturnTabControllerTest {

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
        tempRelatedAssessment.Period_Start_Date__c = System.Today().addMonths(-1);
        tempRelatedAssessment.Taxpayer_Registration__c = taxPayerData.Id;
        insert tempRelatedAssessment;
    }
    
    @isTest
    private static void getAccountDetailsTest() {
        
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
        
        System.assertEquals(NULL, LevyReturnTabController.getAccountDetails());
        
        System.runAs(user){
        
            Account testAcc = LevyReturnTabController.getAccountDetails();
            System.assertEquals('123456789', testAcc.ABN__c);
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getAccountAuthorisationsTest() {
        
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
        
            System.assertNotEquals(0, LevyReturnTabController.getAccountAuthorisations().size());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getTaxPayerRegistrationDetailsTest() {
        
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
        
            System.assertNotEquals(NULL, LevyReturnTabController.getTaxPayerRegistrationDetails());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getAssessmentDetailsTest() {
        
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
        
            System.assertNotEquals(NULL, LevyReturnTabController.getAssessmentDetails());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void submitLevyReturnTest() {
        
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
        
            Assessment__c tempAssessment = LevyReturnTabController.getAssessmentDetails();
            System.assertNotEquals(NULL, tempAssessment);
            System.assertEquals(TRUE, LevyReturnTabController.submitLevyReturn(tempAssessment));
            System.assertEquals(FALSE, LevyReturnTabController.submitLevyReturn(NULL));
        }
        Test.stopTest();
    }
    
    @isTest
    private static void hadTSPAuthorisationTest() {
       
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
          
          Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
          System.assertEquals(FALSE, LevyReturnTabController.hadTSPAuthorisation(tempRelatedAssessment));
          
          Authorisation__c tspAuth = new Authorisation__c(Service_Provider__c = accountId ,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                          Contact__c = conId,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
          
          tspAuth.Start_Date__c = System.Today() - 365;
          tspAuth.Term_in_Years__c = 5;   
          insert tspAuth;
          
          tspAuth.Start_Date__c = System.Today() - 365;
          update tspAuth;
          
          Tax_Payer_Registration__c taxPayerData = [SELECT Id FROM Tax_Payer_Registration__c];
          taxPayerData.Taxi_Service_Provider_Number__c = tspAuth.Id;
          update taxPayerData;
          
          tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
          System.assertEquals(TRUE, LevyReturnTabController.hadTSPAuthorisation(tempRelatedAssessment));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void hadBSPAuthorisationTest() {
       
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
          
          Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
          System.assertEquals(FALSE, LevyReturnTabController.hadBSPAuthorisation(tempRelatedAssessment));
          
          Authorisation__c bspAuth = new Authorisation__c(Service_Provider__c = accountId ,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                          Contact__c = conId ,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_BSP);
          
          bspAuth.Start_Date__c = System.Today() - 365;
          bspAuth.Term_in_Years__c = 5;                                             
          insert bspAuth;
          
          bspAuth.Start_Date__c = System.Today() - 365;
          update bspAuth;
          
          bspAuth = [SELECT Start_Date__c, End_Date__c FROM Authorisation__c WHERE Id = :bspAuth.Id];
          System.debug('In Test: '+bspAuth); 
          
          Tax_Payer_Registration__c taxPayerData = [SELECT Id FROM Tax_Payer_Registration__c];
          taxPayerData.Booking_Service_Provider_Number__c = bspAuth.Id;
          update taxPayerData;
          
          tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
          System.debug('In Test Assessment: '+tempRelatedAssessment); 
          System.assertEquals(TRUE, LevyReturnTabController.hadBSPAuthorisation(tempRelatedAssessment));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void wasRebateApprovedTest() {
       
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
          
          Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
          System.assertEquals(TRUE, LevyReturnTabController.wasRebateApproved(tempRelatedAssessment));
          
        }
        
        Test.stopTest();
    }
}