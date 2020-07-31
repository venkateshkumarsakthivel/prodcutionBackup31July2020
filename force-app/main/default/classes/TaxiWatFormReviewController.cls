/*
 * @Description: Controller class for taxi wat application review page.
 */
public with sharing class TaxiWatFormReviewController {

    @AuraEnabled
    public static String lodgeWATApplication(String caseData) {
        try {
            
            Case caseRecToSave = (Case)JSON.deserialize(caseData, Case.class);
            caseRecToSave.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
            caseRecToSave.Date_Submitted__c = System.now();
            upsert caseRecToSave;
            
            List<Authorisation__c> authsToUpdate = new List<Authorisation__c>();
            List<Authorisation__c> auth = [SELECT Id, Status__c FROM Authorisation__c WHERE Application__c = : caseRecToSave.Id];
            if(auth.size() > 0){
                auth[0].Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
                authsToUpdate.add(auth[0]);
            }
            upsert authsToUpdate;
            
            Case caseRec = [SELECT Id, CaseNumber,Sub_Status__c
                            FROM Case
                            WHERE Id = :caseRecToSave.Id];
            
            return JSON.serialize(caseRec);
            
        } catch(Exception e) {            
            System.debug('Exception: '+e.getMessage());
            System.debug('Exception: '+e.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static String getLoggedInUserProfile() {
        
        return [SELECT Profile.Name FROM USER WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
}