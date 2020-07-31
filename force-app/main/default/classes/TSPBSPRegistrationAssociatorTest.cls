@isTest
public class TSPBSPRegistrationAssociatorTest {
    
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
    private static void testAssociateRelatedAuthorisations() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Authorisation__c tspAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = conId,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY,
                                                        Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert tspAuth;
        
        Authorisation__c bspAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = conId,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY,
                                                        Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_BSP);
        insert bspAuth;
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId,Levy_Contact__c=conId,ABN__c='123456789',
                                                                               Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW,
                                                                               Status__c = GlobalConstants.STATUS_ACTIVE);
        Test.startTest();
        
        insert taxPayerData;
        taxPayerData = [select Id, Taxi_Service_Provider_Number__c, Booking_Service_Provider_Number__c from Tax_Payer_Registration__c where id =: taxPayerData.Id];
        
        System.assertEquals(taxPayerData.Taxi_Service_Provider_Number__c, tspAuth.Id);
        System.assertEquals(taxPayerData.Booking_Service_Provider_Number__c, bspAuth.Id);
        
        Test.stopTest();
    }
    
}