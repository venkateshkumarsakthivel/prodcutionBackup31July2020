@isTest
public class LevyFormSectionDataControllerTest {

    @testSetup 
    static void setup() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
    }
    
    @isTest
    private static void getAccountNameSuccessTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            
            String accountName = LevyFormSectionDataController.getAccountName('');
            System.assertEquals('testAcc', accountName);
            Boolean hasAccountNoticeAddress = LevyFormSectionDataController.hasAccountNoticeAddress(accountId);
            String accountEntityType = LevyFormSectionDataController.getAccountEntityType(accountId);
            
        }
        
        String accountName = LevyFormSectionDataController.getAccountName(accountId);
        System.assertEquals('testAcc', accountName);
            
        test.stopTest();
    }
    
    @isTest
    private static void getAccountContactsSuccessTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user){
            
            List<contact> testContact= LevyFormSectionDataController.getAccountContacts('');
            System.assertEquals(1, testContact.size());
        }
        
        List<contact> testContact= LevyFormSectionDataController.getAccountContacts(accountId);
        System.assertEquals(1, testContact.size());
        
        testContact= LevyFormSectionDataController.getAccountContacts('');
        System.assertEquals(0, testContact.size());
            
        Test.stopTest();
    }
    
    @isTest
    private static void getAccountAuthorisationsSuccessTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user) {
           
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                         Contact__c = conId,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY);
            insert auth;
           
            List<Authorisation__c> testAuth= LevyFormSectionDataController.getAccountAuthorisations('');
            System.assertEquals(1, testAuth.size());
            
        }
        
        List<Authorisation__c> testAuth= LevyFormSectionDataController.getAccountAuthorisations(accountId);
        System.assertEquals(1, testAuth.size());
        
        testAuth = LevyFormSectionDataController.getAccountAuthorisations('');
        System.assertEquals(NULL, testAuth);
            
        Test.stopTest();       
    }
    
    @isTest
    private static void updateRegistrationRecordTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
         User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            
            Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);
            taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
            insert taxPayerData;
            
            Tax_Payer_Registration__c testtaxPayerData = (Tax_Payer_Registration__c)JSON.deserialize(LevyFormSectionDataController.getSectionData(taxPayerData.Id), Tax_Payer_Registration__c.class);
            testtaxPayerData.ABN__c = '123454321';
            
            LevyFormSectionDataController.updateRegistrationRecord(JSON.serialize(testtaxPayerData));
            
            testtaxPayerData = (Tax_Payer_Registration__c)JSON.deserialize(LevyFormSectionDataController.getSectionData(taxPayerData.Id), Tax_Payer_Registration__c.class);
            System.assertEquals('123454321', testtaxPayerData.ABN__c);
            
            List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Status__c FROM Tax_Payer_Registration__c 
                                                                       WHERE Service_Provider_Name__c = :accountId
                                                                       AND Status__c = :GlobalConstants.STATUS_SUPERSEDED]; 
                                                                      
            System.assertEquals(0, supersededRegistrations.size());  
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void updateRegistrationRecordAndCloneTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
         User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            
            Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);
            taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
            insert taxPayerData;
            
            Tax_Payer_Registration__c testtaxPayerData = (Tax_Payer_Registration__c)JSON.deserialize(LevyFormSectionDataController.getSectionData(taxPayerData.Id), Tax_Payer_Registration__c.class);
            testtaxPayerData.ABN__c = '123454321';
            
            LevyFormSectionDataController.updateRegistrationRecord(JSON.serialize(testtaxPayerData));
            
            testtaxPayerData = (Tax_Payer_Registration__c)JSON.deserialize(LevyFormSectionDataController.getSectionData(taxPayerData.Id), Tax_Payer_Registration__c.class);
            System.assertEquals('123454321', testtaxPayerData.ABN__c);
            
            List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Status__c FROM Tax_Payer_Registration__c 
                                                                       WHERE Service_Provider_Name__c = :accountId
                                                                       AND Status__c = :GlobalConstants.STATUS_SUPERSEDED]; 
                                                                      
            System.assertEquals(1, supersededRegistrations.size());  
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void updateRegistrationRecordTestFailure(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        
        System.runAs(user){
        
          System.assertEquals(NULL, LevyFormSectionDataController.updateRegistrationRecord(JSON.serialize(NULL)));
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void submitRegistrationRecordSuccessTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
         User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user){
            
           /* When Contact is Not Null */
           Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.YES_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.NO_VALUE, Levy_Contact__c = conId);
           insert taxPayerData;
                                                                             
           LevyFormSectionDataController.submitRegistrationRecord(JSON.serialize(taxPayerData));
            
           Tax_Payer_Registration__c testtaxPayerData = [SELECT Id, Levy_Contact_Last_Name__c FROM Tax_Payer_Registration__c WHERE Id =: taxPayerData.Id];
           System.assert(testtaxPayerData.Levy_Contact_Last_Name__c == 'testCon');
          
           /* When Contact is Null */
           Tax_Payer_Registration__c taxPayerData2 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.YES_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.NO_VALUE);
           insert taxPayerData2;
            
           LevyFormSectionDataController.submitRegistrationRecord(JSON.serialize(taxPayerData2));
           
           Tax_Payer_Registration__c taxPayerData3 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.NO_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.YES_VALUE, Levy_Contact__c = conId);
                                                                                   
           LevyFormSectionDataController.submitRegistrationRecord(JSON.serialize(taxPayerData3));                                                                        
        }
        Test.stopTest();
    }
    
    @isTest
    private static void submitRegistrationRecordFailureTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
         User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        System.runAs(user){
            
           Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.YES_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.NO_VALUE, Levy_Contact__c = conId);
           insert taxPayerData;
            
           System.assertEquals(NULL, LevyFormSectionDataController.submitRegistrationRecord(NULL));
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getDDRServiceAgreementTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
         User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        
        System.runAs(user) {
           
           System.assertNotEquals('', LevyFormSectionDataController.getDDRServiceAgreement());
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void getSectionDataForAccountTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.YES_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.NO_VALUE, Levy_Contact__c = conId);
        insert taxPayerData;
           
        System.assertNotEquals(NULL, LevyFormSectionDataController.getSectionDataForAccount(accountId));
        
        Test.stopTest();
    }
    
    @isTest
    private static void getEstimatedTransactionsCountsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
           
        System.assertNotEquals(NULL, LevyFormSectionDataController.getEstimatedTransactionsCounts(GlobalConstants.AUTHORISATION_TYPE_TSP));
        System.assertNotEquals(NULL, LevyFormSectionDataController.getEstimatedTransactionsCounts(GlobalConstants.AUTHORISATION_TYPE_BSP));
        
        Test.stopTest();
    }
    
    @isTest
    private static void hasExistingActiveRegistrationsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Test.startTest();
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',
                                                                                   Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                   Status__c = GlobalConstants.STATUS_ACTIVE, Applied_For_Rebate__c = GlobalConstants.YES_VALUE,
                                                                                   Applied_For_Exemption__c = GlobalConstants.NO_VALUE, Levy_Contact__c = conId);
        insert taxPayerData;
        
        System.assertEquals(TRUE, LevyFormSectionDataController.hasExistingActiveRegistrations(accountId));
        System.assertEquals(FALSE, LevyFormSectionDataController.hasExistingActiveRegistrations(''));
        
        Test.stopTest();
    }
    
    @isTest
    private static void hasLevyRegistrationAccessTest() {
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester123' + System.now().getTime() +'@noemail.com');
        insert user;
        
        System.runAs(user) {
          
          System.assertEquals(TRUE, LevyFormSectionDataController.hasLevyRegistrationAccess());
        }
         
        //System.assertEquals(FALSE, LevyFormSectionDataController.hasLevyRegistrationAccess());
    }
    
    @isTest
    private static void checkIfPortalUserTest() {
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester123' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id portalProfile = GlobalUtility.getASPProfile().Id;
        
        User portalUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = portalProfile, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert portalUser;
        
        System.runAs(user) {
          
          System.assertEquals(FALSE, LevyFormSectionDataController.checkIfPortalUser());
        }
        
        System.runAs(portalUser) {
          
          System.assertEquals(TRUE, LevyFormSectionDataController.checkIfPortalUser());
        }
    }
    
    @isTest
    private static void checkIfConsolelUserTest() {
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester123' + System.now().getTime() +'@noemail.com');
        insert user;
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id portalProfile = GlobalUtility.getASPProfile().Id;
        
        User portalUser = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = portalProfile, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester' + System.now().getTime() +'@noemail.com');
        insert portalUser;
        
        System.runAs(user) {
          
          System.assertEquals(TRUE, LevyFormSectionDataController.isConsoleUser());
        }
        
        System.runAs(portalUser) {
          
          System.assertEquals(FALSE, LevyFormSectionDataController.isConsoleUser());
        }
    }
}