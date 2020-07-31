public with sharing class ASPAuthRenewalFormController {
    
    @AuraEnabled
    public static Case getRenewalCaseDetails(String accountId) {
        
        try {
            
            Id serviceProviderAdministrationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Case> listCases = [SELECT Id, CaseNumber, AccountId, ContactId, Service_Type__c
                                    FROM Case 
                                    WHERE AccountId =: accountId
                                    AND RecordTypeId =: serviceProviderAdministrationRecordType 
                                    AND Type =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
                                    AND Sub_Type__c =: GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                    AND Status !=: GlobalConstants.CLOSED_CASE_STATUS];
            
            if(listCases.size() > 0) {
                Case  renewalCaseRec = listCases.get(0); // There will be only one renewal case in progress on account
                return renewalCaseRec;
            }
            
            return NULL;
            
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPAuthRenewalFormController', 'getRenewalCaseDetails', ex.getMessage(), ex);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static List<Authorisation__c> getAuthorisationDetails(String caseId) {
        
        try {
            
            List<Authorisation__c> listAuths = [SELECT Id, Name, Authorisation_Number__c, Authorisation_Type__c, Start_Date__c, End_Date__c, Service_Provider__c, Application__c
                                                FROM Authorisation__c 
                                                WHERE Application__c =: caseId];
            return listAuths;
            
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPAuthRenewalFormController', 'getAuthorisationDetails', ex.getMessage(), ex);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static Case getASPAuthRenewalCaseData(String caseId) {
        try {
            
            Case caseRec = [SELECT Id, Status, Service_Type__c, Is_TSP_Auth_Renewal_Request__c, Is_BSP_Auth_Renewal_Request__c, Is_Privacy_Statement_Declared__c
                            FROM Case WHERE Id =: caseId];
            return caseRec;
            
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPAuthRenewalFormController', 'getASPAuthRenewalCaseData', ex.getMessage(), ex);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static Boolean updateASPAuthRenewalCase(String caseData, Boolean updateStatusToLodged) {
        try {
            
            Case caseRec = (Case)JSON.deserialize(caseData, Case.class);
            
            if(updateStatusToLodged) {
                // Lodge ASP Auth Renewal Application
                caseRec.Date_Submitted__c = DateTime.parse(DateTime.now().format());
                caseRec.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
                caseRec.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;

                // For ASP Auth Renewal application -
                // If Renewal Case had 2 Authorisations linked, but user has selected to renew only one licence 
                // then delete other draft authorisation linked to case
                ASPAuthRenewalLodger.deleteDraftAuthNotSelectedForRenewal(caseRec);
            }
            
            Database.update(caseRec, false);
            
            return true;
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPAuthRenewalFormController', 'updateASPAuthRenewalCase', ex.getMessage(), ex);
            return NULL;
        }
    }
    
}