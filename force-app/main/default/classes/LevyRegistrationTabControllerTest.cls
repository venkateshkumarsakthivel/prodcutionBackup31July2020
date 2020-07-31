@isTest
public class LevyRegistrationTabControllerTest {
    
    @testSetup 
    static void setup() {
    
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerID=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
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
        System.runAs(user){
        
            Account testAcc = LevyRegistrationTabController.getAccountDetails();
            Boolean hasAccountNoticeAddress = LevyRegistrationTabController.hasAccountNoticeAddress();
            System.assertEquals('123456789', testAcc.ABN__c);
            
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getAccountDetailsTestFailure(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        Test.startTest();
        Account testAcc = LevyRegistrationTabController.getAccountDetails();
        System.assertEquals(NULL, testAcc);
        Test.stopTest();
    }
      
    @isTest
    private static void updateExistingTaxPayerRegistrationDetailsTest(){
        
        Id accountId = [select id,OwnerId from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        Test.startTest();
        System.runAs(user) {
            
            Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c=conId, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
            taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
            insert taxPayerData;
            
            taxPayerData = LevyRegistrationTabController.getTaxPayerRegistrationDetails();
            taxPayerData.ABN__c = '123454321';
            LevyRegistrationTabController.updateTaxPayerRegistrationContactDetails(taxPayerData);
            
            Tax_Payer_Registration__c testTaxPayerData = LevyRegistrationTabController.getTaxPayerRegistrationDetails();
            System.assertEquals('123454321', testTaxPayerData.ABN__c);
            
        }
        Test.stopTest();
    }
  
    @isTest
    private static void updateExistingTaxPayerRegistrationDetailsTestFailure(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
       
        Test.startTest();
            
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,Levy_Contact__c=conId,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);
        insert taxPayerData;
            
        taxPayerData= [select Id,Service_Provider_Name__c,ABN__c,Service_Provider_Name__r.OwnerId, Levy_Contact__c from Tax_Payer_Registration__c where id =: taxPayerData.Id];
        taxPayerData.ABN__c='123454321';
        LevyRegistrationTabController.updateTaxPayerRegistrationContactDetails(taxPayerData);
            
        Tax_Payer_Registration__c testTaxPayerData = LevyRegistrationTabController.getTaxPayerRegistrationDetails();
        System.assertEquals(NULL, testTaxPayerData);
        
        Test.stopTest();
    }
    
    @isTest
    private static void getAccountAuthorisationsTest(){
        
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
        
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                         Contact__c = conId,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY);
            insert auth;
            
            
            List<Authorisation__c> testAuth= LevyRegistrationTabController.getAccountAuthorisations();
            System.assertEquals(1, testAuth.size());
            
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void getAccountContactsTest(){
        
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
            
            List<contact> testContact= LevyRegistrationTabController.getAccountContacts();
            System.assertEquals(1, testContact.size());
            
        }
        Test.stopTest();
    }
      
    @isTest
    private static void updateTaxPayerRegistrationAndCloneTest(){
        
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
        
        System.runAs(user) {
            
            Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Levy_Contact_Last_Name__c = 'LastName', Levy_Contact_First_Name__c = 'FirstName', 
                                                                                   Levy_Contact_Email__c = 'test@test.com', Levy_Contact_Phone__c = '02222222');
                                                                                   
            taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
            insert taxPayerData;
            
            taxPayerData = LevyRegistrationTabController.getTaxPayerRegistrationDetails();
            taxPayerData.ABN__c = '123454321';
            LevyRegistrationTabController.updateTaxPayerRegistrationContactDetails(taxPayerData);
            
            taxPayerData = LevyRegistrationTabController.getTaxPayerRegistrationDetails();
           // System.assertEquals(taxPayerData.ABN__c, '123454321');  
            
            List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Status__c FROM Tax_Payer_Registration__c 
                                                                       WHERE Service_Provider_Name__c = :accountId
                                                                       AND Status__c = :GlobalConstants.STATUS_SUPERSEDED]; 
                                                                      
            System.assertEquals(1, supersededRegistrations.size());       
        }
        Test.stopTest();
    }
   
    @isTest
    private static void updateTaxPayerRegistrationAndCloneFailureTest(){
    
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
       
        System.runAs(user) {
            
            Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_SUPERSEDED);
            taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
            insert taxPayerData;
            
            taxPayerData.ABN__c = '123454321';
            LevyRegistrationTabController.updateTaxPayerRegistrationContactDetails(taxPayerData);
            
            List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT ABN__c, Status__c FROM Tax_Payer_Registration__c 
                                                                       WHERE Service_Provider_Name__c = :accountId]; 
            
            //validate if only one registration record exists and no superseded clone is created                                                         
            System.assertEquals(1, supersededRegistrations.size());
            System.assertEquals('123456789', supersededRegistrations[0].ABN__c);    
        }
        Test.stopTest();
    }
    
    @isTest
    private static void checkOpenCasesTest(){
        
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
       
        System.runAs(user) {
          
          Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_SUPERSEDED);
          taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
          insert taxPayerData;
          
          System.assertEquals(FALSE, LevyRegistrationTabController.checkOpenCases(taxPayerData));
        }
        Test.stopTest();
    }
    
    @isTest
    private static void checkOpenCasesFailureTest(){
        
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
       
        System.runAs(user) {
          
          Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_SUPERSEDED);
          taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
          insert taxPayerData;
          
          System.assertEquals(FALSE, LevyRegistrationTabController.checkOpenCases(NULL));
        }
        Test.stopTest();
    }
    
    @isTest
    private static void processTaxPayerRegistrationDetailsUpdateTest(){
        
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
       
        System.runAs(user) {
          
          Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_SUPERSEDED);
          taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
          insert taxPayerData;
          
          taxPayerData = LevyRegistrationTabController.processTaxPayerRegistrationDetailsUpdate(taxPayerData);
          System.assertEquals('No', taxPayerData.New_Levy_Contact_Added__c);
        }
        Test.stopTest();
    }
}