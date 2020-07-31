//Test class for TaxiAgentRegistrationDetailsForm Controller

@isTest
public class TaxiAgentRegistrationDetailsFormTest {
    
    @testSetup
    private static void setupTestData(){
        
        /*---Create Case Data--*/
        Id taxiAgentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE).getRecordTypeId();
        
        Case cas = new Case(RecordtypeId=taxiAgentRecordTypeId,Postcode__c='2000',City__c='Sydney',Sub_Type__c='Agent Registration',Status = 'New',Sub_Status__c='Review Pending',State__c='NSW');
        insert cas;
        
        /*---Create Related Contact Data--*/
        Id individualRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_CORPORATE_RECORD_TYPE).getRecordTypeId();
        
        Related_Contact__c individualrelatedcnt = new Related_Contact__c(RecordtypeId=individualRecordTypeId,Related_Application__c = cas.id,Date_of_Birth__c=system.today(), First_Given_Name__c='Test', Family_Name__c='Test Family',Email__c='abc@abc.com');
        insert individualrelatedcnt;
        Related_Contact__c corporaterelatedcnt = new Related_Contact__c(RecordtypeId=corporateRecordTypeId,Related_Application__c = cas.id,First_Given_Name__c='Test',Date_of_Birth__c=system.today(), Family_Name__c='Test Family',Email__c='abc@abc.com');
        insert corporaterelatedcnt;
    }
    
    @isTest
    private static void getCaseDetailsTest() {  
        
        Case caseDetails = TaxiAgentRegistrationDetailsForm.getCaseDetails();
        System.assertEquals('New', caseDetails.Status);
    }
    
    @isTest
    private static void getRelatedContactDetailsTest() {
        
        string entityType = 'Corporation';
        Related_Contact__c relatedContactDetails = TaxiAgentRegistrationDetailsForm.getRelatedContactDetails(entityType);
    }
    
    @isTest
    private static void saveCaseRecordTest() {
        
        Case Cse = [SELECT Id,Status,Sub_Status__c FROM Case LIMIT 1];
        Case caseRecord = TaxiAgentRegistrationDetailsForm.saveCaseRecord(Cse);
        System.assertNotEquals('Lodged', caseRecord.Status);
        System.assertEquals('Review Pending', caseRecord.Sub_Status__c);
    } 
    
    @isTest
    private static void saveRelatedContactRecordTest() {
        
        string entityType = 'Corporation';
        string relatedContactType = 'General Contact';
        Related_Contact__c relatedContactRecord = [SELECT Id,Family_Name__c,Date_of_Birth__c FROM Related_Contact__c LIMIT 1];
        Case Cse = [SELECT Id,Status,Sub_Status__c FROM Case LIMIT 1];
        Related_Contact__c relatedCntRecord = TaxiAgentRegistrationDetailsForm.saveRelatedContactRecord(entityType, Cse, relatedContactRecord, relatedContactType);
        System.assertNotEquals('Test', relatedCntRecord.Family_Name__c);
    } 
    
    @isTest
    private static void saveAgentCaseRecordTest() {
        
        Case Cse = [SELECT Id,Status,Sub_Status__c FROM Case LIMIT 1];
        String cseRecord = TaxiAgentRegistrationDetailsForm.saveAgentCaseRecord(Cse);
    } 
}