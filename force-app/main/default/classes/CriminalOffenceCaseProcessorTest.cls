/*
 * Test class which covers : 1.ApprovedCriminalOffenceCasesProcessor,2. COInvestigationCloseCaseProcessor
 */
@isTest
public class CriminalOffenceCaseProcessorTest {

    @isTest
    private static void criminalOffenceTriggerTest()
    {
         /* Account ------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name');
        insert ac;
        
        /* Contact ------ */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Id coirecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_Investigation_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        Id corecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        
        Case parentCase= new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Correction', Status= 'Lodged', RecordTypeId = coirecordTypeId,Sub_Status__c = 'Review Pending');
        insert parentCase;
        
        Case childCase1 = new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Criminal Charge', 
                                   Status= 'Lodged', RecordTypeId = corecordTypeId,Sub_Status__c = 'Assessment In Progress',ParentId = parentCase.Id);
        insert childCase1;
        
        Case childCase2 = new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Criminal Charge', 
                                   Status= 'Lodged', RecordTypeId = corecordTypeId,Sub_Status__c = 'Assessment In Progress',ParentId = parentCase.Id);
        insert childCase2;
       
        //test for ApprovedCriminalOffenceCasesProcessor
        Case tempCase = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id = :childCase1.Id];
        tempCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
        tempCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        update tempCase;
        
        //Check if parent Sub_Status__c is NOT CHANGED because only one child is closed,approved
        Case checkParent1 = [SELECT Id, Sub_Status__c FROM Case WHERE Id = :parentCase.Id];
        System.assert(GlobalConstants.DECISION_COMPLETE_SUB_STATUS != checkParent1.Sub_Status__c);
        
        Case tempCase1 = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id = :childCase2.Id];
        tempCase1.Status = GlobalConstants.CLOSED_CASE_STATUS;
        tempCase1.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        update tempCase1; 
        
        //Check if parent Sub_Status__c is CHANGED because both childs are closed,approved
        Case checkParent2 = [SELECT Id, Sub_Status__c FROM Case WHERE Id = :parentCase.Id];
        System.assert(GlobalConstants.DECISION_COMPLETE_SUB_STATUS == checkParent2.Sub_Status__c);
        
        
        // test for COInvestigationCloseCaseProcessor
        Case coiCase = [SELECT Id, Status FROM Case WHERE Id = :parentCase.Id];
        coiCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
        update coiCase;
        
        //Parent case should be closed because all childs are closed
        Case coiCaseOutput = [SELECT Id, Status FROM Case WHERE Id = :parentCase.Id];
        System.assertEquals(GlobalConstants.CLOSED_CASE_STATUS, coiCaseOutput.Status); 
        
   }
}