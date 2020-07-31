@isTest
public class ExpiryCaseClosePostProcessorTest {
    
    @testSetup
    private static void setupTestData()
    {
        Id ownerid = GlobalUtility.getOwnerId();
        
        /* Account ------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert ac;
        
        /* Contact ------ */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
    }
    
    @isTest
    private static void checkRenewalCaseIsInProgressTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU',profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester25@noemail.com', UserRoleId = r.Id);
        insert user;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        Test.startTest();
        
        System.runAs(user) {
            
            Authorisation__c originalAuth = new Authorisation__c(Service_Provider__c = accountId, Licence_Class__c = 'TX08', Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                 Contact__c = conId, Status__c = 'Granted', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            insert originalAuth;
            
            Authorisation__c draftAuth = new Authorisation__c(Service_Provider__c = accountId, Status__c = 'Draft', Related_Authorisation__c = originalAuth.Id);
            insert draftAuth;
            
            Case expiryRenewableCase = new Case(Authorisation__c = originalAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE, Status= GlobalConstants.CASE_NEW, RecordTypeId = taxiLicenseAdministrationRecordTypeId);
            insert expiryRenewableCase;
            
            Case renewalCase = new Case(Authorisation__c = draftAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = 'Renewal Application', Status= 'Draft', Sub_Status__c = 'Draft', RecordTypeId = TaxiLicenseAdministrationRecordTypeId);
            insert renewalCase;
            
            expiryRenewableCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
            expiryRenewableCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
            update expiryRenewableCase;
            
            Case renewalCaseRec = [SELECT Status, Sub_Status__c, Authorisation__c FROM Case WHERE Id =: renewalCase.Id LIMIT 1];
            System.assertEquals(GlobalConstants.CANCELLED_CASE_STATUS, renewalCaseRec.Status);
            System.assertEquals(GlobalConstants.CASE_SUB_STATUS_EXPIRED, renewalCaseRec.Sub_Status__c);
                
            Authorisation__c draftAuthorisationRec = [SELECT ID, Name, Status__c FROM Authorisation__c 
                                                         WHERE Id =: renewalCaseRec.Authorisation__c];
            System.assertEquals(GlobalConstants.AUTHORISATION_STATUS_DISCARDED, draftAuthorisationRec.Status__c);
            
        }
        Test.stopTest();
    }
}