/**
* Server side rest resource controller for Progress Case custom quick action on case
*/
public with sharing class ProgressCaseController {

    @AuraEnabled
    public static String getNewOwnerName() { 

        Id userId = UserInfo.getUserId();

        return [SELECT Name FROM User WHERE Id = :userId].Name;
    }

    //method which assigns ownership of case to logged in user 
    //and updates sub-status values accordingly
    @AuraEnabled
    public static String takeOwnership(String caseId) { 

        try {
            Case tempCase = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c, OwnerId,
                             CreatedById
                             FROM Case
                             WHERE Id =:caseId];
            tempCase.OwnerId = UserInfo.getUserId();
            // Update case status from New to In Progress
            if(tempCase.Status==GlobalConstants.CASE_NEW){
                tempCase.Status = 'In Progress';
            }
            
            if(tempCase.Status == GlobalConstants.LODGED_CASE_STATUS
               && tempCase.Type == GlobalConstants.CASE_SERVICE_PROVIDER_TYPE
               && tempCase.Sub_Type__c == GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION
               && tempCase.OwnerId == tempCase.CreatedById) {
             
             
               return 'ON-BEHALF OF APPLICANT ERROR';
            }
            
            if(tempCase.Sub_Status__c == GlobalConstants.CASE_STATUS_REVIEW_PENDING){
                tempCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_IN_PROGRESS;
            } else if(tempCase.Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING ){
                tempCase.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS ;
            } else if(tempCase.Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING){
                tempCase.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_INPROGRESS  ;
            }
            
            update tempCase;

            return 'SUCCESS';
        }                
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ProgressCaseController','takeOwnership',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
}