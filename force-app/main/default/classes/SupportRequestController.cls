//Class for creating support request.

public with sharing class SupportRequestController {
    
    public class HelpRequestException extends Exception{}
    
    //Add new contact from Portal -
    //1 - Create case of Type - Service Provider and Sub Type - Maintain Authorisation
    //2 - Create Related Contact
    @AuraEnabled
    public static String submitSupportRequest(Case caseRecord, Related_Contact__c newContact) {
        
        String caseNumber;
        try {
            User user = GlobalUtility.getLoggedInUser();
            
            Id sapRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            caseRecord.RecordTypeId = sapRecordTypeId;
            caseRecord.AccountId = user.Contact.AccountId;
            //set dml options to trigger case assignment
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            caseRecord.setOptions(dmo);
            insert caseRecord;
            
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_RECORD_TYPE_INDIVIDUAL).getRecordTypeId();
            
            newContact.RecordTypeId = indivRecordTypeId;
            newContact.Related_Application__c = caseRecord.Id;
            insert newContact;
            
            Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
            caseNumber = caseRec.CaseNumber;
            return caseNumber;
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'SupportRequestController','submitSupportRequest',ex.getMessage(),ex);
            return null; 
        }
    }
}