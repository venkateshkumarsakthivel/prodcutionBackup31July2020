// this class is used as BatchToDeleteAgreementCases's test class 
@isTest
public class BatchToDeleteAgreementCasesTest {
    
    @testSetup
    private static void setupTestData() {
        
        Id agentRegistrationCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE).getRecordTypeId();
        
        String caseJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},"Status":"Open","CreatedDate":"2018-03-03T17:54:26.000+0000","LastModifiedDate":"2018-03-04T17:54:26.000+0000"}'; 
        Case newTaxiCase = (Case) JSON.deserialize(caseJSON, Case.class ); 
        
        newTaxiCase.RecordTypeId = agentRegistrationCaseRecordTypeId;
        insert newTaxiCase; 
    }
    
    @isTest
    private static void startTest() { 
        
        String query ;
        query = 'SELECT Id, CaseNumber, Status, Date_Submitted__c, LastModifiedDate, RecordType.DeveloperName, (SELECT Id, Name FROM Attachments)' + 
                ' FROM Case' + 
                ' WHERE Date_Submitted__c = null AND RecordType.DeveloperName = \'Agent_Registration\'';  
        
        Test.startTest();
        BatchToDeleteAgreementCases newBatch = new BatchToDeleteAgreementCases(query);
        Database.executeBatch(newBatch);
        Test.stopTest();
    }

}