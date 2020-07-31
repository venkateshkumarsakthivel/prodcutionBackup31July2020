/*
 * Test class for: LevyRegistrationUpdateInternalFormCon
 */
@isTest
public class LevyRegistrationUpdateInternalFormTest {

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
    private static void getTaxPayerRegistrationDetailsSuccessTest(){
      
      Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
      Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
      Id p = GlobalUtility.getASPProfile().Id;
        
      User user = new User(alias = 'test123', email = 'test123@noemail.com',
                             emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                             localesidkey = 'en_AU', profileid = p, country = 'Australia', IsActive = true,
                             contactId = conId,
                             timezonesidkey = 'Australia/Sydney', username = 'tester' + System.now().getTime() +'@noemail.com');
      insert user;
     
      Test.startTest();
      System.runAs(user) {
         
       Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);      
       insert taxPayerData;
       
       System.assertNotEquals(NULL, LevyRegistrationUpdateInternalFormCon.getTaxPayerRegistrationDetails(taxPayerData.Id));
      }
      Test.stopTest();
    }
    
    @isTest
    private static void getTaxPayerRegistrationDetailsFailureTest(){
      
      Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
      Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
      Id p = GlobalUtility.getASPProfile().Id;
        
      User user = new User(alias = 'test123', email = 'test123@noemail.com',
                             emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                             localesidkey = 'en_AU', profileid = p, country = 'Australia', IsActive = true,
                             contactId = conId,
                             timezonesidkey = 'Australia/Sydney', username = 'tester' + System.now().getTime() +'@noemail.com');
      insert user;
     
      Test.startTest();
      System.runAs(user) {
         
       Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);      
       insert taxPayerData;
       
       System.assertEquals(NULL, LevyRegistrationUpdateInternalFormCon.getTaxPayerRegistrationDetails(''));
      }
      Test.stopTest();
    }
    
    @isTest
    private static void setupTaxPayerRegistrationDetailsUpdateTest(){
    
      Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
      Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
      Id p = GlobalUtility.getASPProfile().Id;
        
      User user = new User(alias = 'test123', email = 'test123@noemail.com',
                             emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                             localesidkey = 'en_AU', profileid = p, country = 'Australia', IsActive = true,
                             contactId = conId,
                             timezonesidkey = 'Australia/Sydney', username = 'tester' + System.now().getTime() +'@noemail.com');
      insert user;
      
      Test.startTest();
      System.runAs(user) {
        
       Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);      
       insert taxPayerData;
       
       System.assertNotEquals(NULL, LevyRegistrationUpdateInternalFormCon.setupTaxPayerRegistrationDetailsUpdate(taxPayerData));
       System.assertEquals(NULL, LevyRegistrationUpdateInternalFormCon.setupTaxPayerRegistrationDetailsUpdate(NULL));
      }
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
          
          System.assertEquals(TRUE, LevyRegistrationUpdateInternalFormCon.hasLevyRegistrationAccess());
        }
        
        System.assertEquals(FALSE, LevyRegistrationUpdateInternalFormCon.hasLevyRegistrationAccess());
    }
}