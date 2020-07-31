/*
 * Test class for OverturnCriminalOffenceApprovalProcessor
 */
@isTest
public class OverturnCriminalOffenceAppProcessorTest {
   
   @testsetup
   private static void setupTestData() {
     
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name');
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Id coirecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_Investigation_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        Id corecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        
        Case parentCase= new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Correction', Status= 'Lodged', RecordTypeId = coirecordTypeId,Sub_Status__c = 'Review Pending');
        insert parentCase;
        
        Case childCase1 = new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Criminal Charge', 
                                   Status= 'Lodged', RecordTypeId = corecordTypeId,Sub_Status__c = 'Assessment In Progress',ParentId = parentCase.Id);
        insert childCase1;
        
        
   }
   
   @isTest
   private static void processCriminalOffenceCasesTest() {
        
        Case criminalOffenceCase = [SELECT Sub_Status__c, Decision__c, RMS_Response__c, RMS_Response_DateTime__c
                                     FROM Case
                                     WHERE Sub_Type__c = 'Criminal Charge'];
        
        System.assertEquals(NULL, criminalOffenceCase.RMS_Response__c);
        System.assertEquals(NULL, criminalOffenceCase.RMS_Response_DateTime__c);
                         
        criminalOffenceCase.Decision__c= GlobalConstants.CHARGE_CORRECTED;
        criminalOffenceCase.Sub_Status__c = GlobalConstants.DECISION_COMPLETE_SUB_STATUS;
        
        Test.startTest();
        
        P2PRMSOvtMockImplementation.reandomCode1 = 50;
        update criminalOffenceCase;
        
        Test.stopTest();
        
        criminalOffenceCase = [SELECT Sub_Status__c, Decision__c, RMS_Response__c, RMS_Response_DateTime__c
                                     FROM Case
                                     WHERE Sub_Type__c = 'Criminal Charge'];
 
 
        System.assertNotEquals(NULL, criminalOffenceCase.RMS_Response__c);
        System.assertNotEquals(NULL, criminalOffenceCase.RMS_Response_DateTime__c);
   }
}