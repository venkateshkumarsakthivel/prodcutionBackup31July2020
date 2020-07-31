@isTest
public class PaymentEnquiryDeletionBatchTest {
    
    @testSetup
    private static void setupTestData() {
        
        String customerEnquiryDevName = 'Customer Enquiry';
        Id agentRegistrationCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(customerEnquiryDevName).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con1 = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con1;  
        Contact con2 = new Contact(LastName ='testContact',AccountId = ac.Id, Email='testcontact@contest.com');
        insert con2; 
        
        List<case> caseList = new List<Case>();
        Case c1 = new Case(Family_name__c = 'Family Name 1',Birthdate__c= Date.parse('01/01/1985'),Contact_Type__c = 'Nominated Director/Manager',
                           Email__c='Test@test.com',First_given_name__c='First Name 1',Residential_Address_City__c='Test City',
                           Residential_Address_Country__c='Test Country',Residential_Address_State__c='Test state',Residential_Address_Street__c='Test street',
                           Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = ac.Id, Service_Type__c = 'Taxi', Status = 'Draft',
                           Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                           Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = agentRegistrationCaseRecordTypeId);
        caseList.add(c1);
        
        Case c2 = new Case(Family_name__c = 'Family Name 2',Birthdate__c= Date.parse('01/01/1982'),Contact_Type__c = 'Nominated Director/Manager',
                           Email__c='Test2@test.com',First_given_name__c='First Name 2',Residential_Address_City__c='Test City2',
                           Residential_Address_Country__c='Test2 Country',Residential_Address_State__c='Test2 state',Residential_Address_Street__c='Test2 street',
                           Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = ac.Id, Service_Type__c = 'Taxi', Status = 'Draft',
                           Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                           Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = agentRegistrationCaseRecordTypeId);
        caseList.add(c2);
        
        insert caseList;
    }
    
    @isTest
    private static void startTest() { 
        
        Test.startTest();
        PaymentEnquiryDeletionScheduler s = new PaymentEnquiryDeletionScheduler();
        s.execute(null);
        Test.stopTest();
        
        List<Case> cases = [SELECT Id FROM Case];
        
        System.assertEquals(0, cases.size());
    }
    
}