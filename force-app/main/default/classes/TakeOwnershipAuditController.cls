public without sharing class TakeOwnershipAuditController {

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
             
            update tempCase;

            return 'SUCCESS';
        }                
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TakeOwnershipAuditController','takeOwnership',ex.getMessage(),ex);
            return 'ERROR';
        }
    }}