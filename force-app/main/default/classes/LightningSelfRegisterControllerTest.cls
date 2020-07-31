@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {
    
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() { 
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
    }
    
    /* Verifies the default value of siteAsContainerEnabled method. */
    @IsTest
    static void testSiteAsContainerEnabled() {
        String networkId = Network.getNetworkId();
        Id nwId = [select id from Network limit 1].id;
        LightningSelfRegisterController.siteAsContainerEnabled(nwId);
        //System.assertNotEquals(null, );
    }
        
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //  System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null,paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals('Fail', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Full Access user'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration1() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        // System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null,paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals('Fail', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Full Access user'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration3() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        // System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        // System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null,paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals('Fail', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Full Access user'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration4() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        // System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null,paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals('Fail', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Full Access user'));
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration5() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        // System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        // System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null,paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        //System.assertEquals('Fail', LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true , null,'Full Access user'));
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Full Access user'));
    }
    
    @IsTest
    static void testSelfRegistration6() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'DVD User'));
    }
    
    @IsTest
    static void testSelfRegistration7() {
        Map < String, String > paramsMap = initializeParams();      
        System.assertNotEquals(null, paramsMap);
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false , null,'Manage Account user'));
    }
    
    @IsTest
    static void LightningSelfRegisterControllerInstantiation() {
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        System.assertNotEquals(controller, null);
    }
    
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    
    @isTest
    private static void validatePasswordTest() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc2',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
        
        Id accountId = [select id from Account where name = 'testAcc2' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id profileId = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        test.startTest();
        System.runAs(user){
            LightningSelfRegisterController.validatePassword(user, 'password?@12334', 'password?@12334');
        }
        test.stopTest();
    }
    
    @isTest
    private static void getContactInformationTest() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
          Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc1',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact contact = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert contact;
        
        Id accountId = [select id from Account where name = 'testAcc1' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id profileId = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        test.startTest();
        System.runAs(user){
            String result = LightningSelfRegisterController.getContactInformation(contactId);
            System.assert(result.contains(accountId) == true);
        }
        test.stopTest();
        
    }
}