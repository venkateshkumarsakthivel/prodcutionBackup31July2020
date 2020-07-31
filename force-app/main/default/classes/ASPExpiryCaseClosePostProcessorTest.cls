@isTest
public class ASPExpiryCaseClosePostProcessorTest {
	
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
    private static void closeRenewalCaseTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI,ContactId = conId, Status = GlobalConstants.APPLICATION_STATUS_LODGED,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION, RecordTypeId = rtIdforIndividual);
        insert c;
        Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Id serviceProviderAdministrationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU',profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester22@noemail.com');
        insert user;
        
        Test.startTest();
           	list<Authorisation__c> listAuthorisations = new list<Authorisation__c>();

            Authorisation__c originalAuth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                             ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id); 
            insert originalAuth;
            listAuthorisations.add(originalAuth);
            
            Case lodgedCase = new Case(Type = GlobalConstants.AUTHORISATION_TYPE_TSP, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE, Status= GlobalConstants.APPLICATION_STATUS_LODGED, RecordTypeId = taxiLicenseAdministrationRecordTypeId); 
            insert lodgedCase;
            
            Authorisation__c draftAuth = new Authorisation__c(Service_Provider__c = accountId, Status__c = 'Draft', Related_Authorisation__c = originalAuth.Id, Application__c = lodgedCase.Id);
            insert draftAuth;
        
        	Case renewalCase = new Case(Authorisation__c = draftAuth.Id, Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION, Status= GlobalConstants.APPLICATION_STATUS_LODGED, Sub_Status__c = 'Review Pending', RecordTypeId = serviceProviderAdministrationRecordType);
            insert renewalCase;
        
        	ASPExpiryCaseClosePostProcessor.closeRenewalCase(listAuthorisations);
        
        Test.stopTest();
    }
}