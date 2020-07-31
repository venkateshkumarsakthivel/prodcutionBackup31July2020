@isTest
public class TaxiRenewalPaymentControllerTest {

    @testSetup 
    static void setup() {
     
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact con = new Contact(Title='Mr.', LastName ='testCon', AccountId = ac.Id, Birthdate = Date.parse('01/01/1992'), Email='test@contest.com', FirstName = 'Name');
        insert con;
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        
        Id taxiAuthRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = ac.Id);
        authRecord.Application__c = newTaxiCase.Id;
        insert authRecord;
        
        Order order = new Order(Name = 'Test Order', AccountId = ac.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card');
        order.Authorisation__c = authRecord.Id;
        order.Application__c = newTaxiCase.Id;
        insert order;
    }
    
    @isTest
    private static void testSubmitFailure() {
        
        Test.startTest();
        System.assertEquals(NULL, TaxiRenewalPaymentController.submit(NULL));
        Test.stopTest();
    }
    
    @isTest
    private static void testSubmitSucces() {
        
        Order order = [SELECT Status, TotalAmount, Application__c FROM Order];
        Test.startTest();
        System.assertNotEquals(NULL, TaxiRenewalPaymentController.submit(order));
        Test.stopTest();
    }
    
    @isTest
    private static void testRetrievePaymentDetailsFailure() {
      
        Case tempCase = [SELECT Id FROM Case];
        Test.startTest();
        System.assertEquals(NULL, TaxiRenewalPaymentController.retrievePaymentDetails(tempCase.Id));
        Test.stopTest();
    }
    
    @isTest
    private static void testIsInternalUser() {
      
        Test.startTest();
        System.assertEquals(TRUE, TaxiRenewalPaymentController.isInternalUser());
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessPaymentRequestFailure() {
     
        Test.startTest();
        System.assertEquals(NULL, TaxiRenewalPaymentController.processPaymentRequest(NULL, TRUE));
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessPaymentRequestSuccess() {
     
        Order order = [SELECT Status, TotalAmount, Application__c FROM Order];
        Test.startTest();
        System.assertNotEquals(NULL, TaxiRenewalPaymentController.processPaymentRequest(order.Id, TRUE));
        Test.stopTest();
    }
}