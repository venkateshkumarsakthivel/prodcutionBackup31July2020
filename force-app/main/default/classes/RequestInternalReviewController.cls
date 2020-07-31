public class RequestInternalReviewController {
    
    //This function retrives Account and Contact details of logged in user. 
    @AuraEnabled
    public static String getAccountAndContactDetails(){
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            
            List<Contact> contact = [SELECT Id, Email, Phone, Account.Id, Account.Name, Account.Notice_Email__c, 
                                     Account.Notice_Address_Street__c, Account.Notice_Address_City__c, Account.Notice_Address_State__c, Account.Notice_Address_Postal_Code__c, Account.Notice_Address_Country__c 
                                     FROM Contact WHERE Id =: user.ContactId AND Account.Id =: user.AccountId];
            
            String str = contact.size() > 0 ? JSON.serialize(contact[0]) : NULL;
            return str;
        }
        catch(Exception ex) {
           
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'RequestInternalReviewController','getAccountAndContactDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveAuthorisationRequestForInternalReview(String caseData) {
        
        try {
            
            System.debug('RequestInternalReviewController saveAuthorisationRequestForInternalReview');
            
            Case caseRecord = (Case)JSON.deserialize(caseData, Case.class);
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName() 
                .get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
            caseRecord.RecordTypeId = caseRecordTypeId;
            
            if(GlobalUtility.getLoggedInUser() != null) {
                caseRecord.ContactId = GlobalUtility.getLoggedInUser().ContactId; 
                caseRecord.AccountId = GlobalUtility.getLoggedInUser().AccountId; 
            }
            
            insert caseRecord;
            
            Case createdCase = [SELECT CaseNumber FROM Case WHERE Id = :caseRecord.Id];
            
            System.debug('[caseRecord] : ' + caseRecord);
            System.debug('[caseNumber] : ' + Json.serialize(createdCase.CaseNumber));
            
            return Json.serialize(createdCase.CaseNumber);
            
        } catch(Exception e)  {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RequestInternalReviewController', 'saveAuthorisationRequestForInternalReview', e.getMessage(), e);
            return NULL;
        }
    }
    
}