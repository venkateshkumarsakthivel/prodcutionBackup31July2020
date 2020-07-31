// This class is executed from CaseTriggerHandler
// Check if Renewal Case is in progress on Authorisation related to Expiry-Renewable Case for ASP, if yes display error message
public with sharing class ASPExpiryCaseClosePreProcessor {
    
    private Map<Id, Case> newApplications;
    
    public ASPExpiryCaseClosePreProcessor(Map<Id, Case> newApplications){
        this.newApplications = newApplications;
    }
    
    public void checkRenewalCaseIsInProgress() {    
        
        try {
            for(Case tempCase : newApplications.values()) {

                if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME
                   && (tempCase.Type == GlobalConstants.AUTHORISATION_TYPE_TSP || tempCase.Type == GlobalConstants.AUTHORISATION_TYPE_BSP )
                   && tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE
                   && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && (tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS
                       || tempCase.Sub_Status__c == GlobalConstants.DECLINED_CASE_SUB_STATUS)) 
                {

                    Id originalAuthorisationId = tempCase.Authorisation__c;  

                    List<Authorisation__c> relatedDraftAuthorisationList = [SELECT Id, Application__c FROM Authorisation__c
                                                                  WHERE Related_Authorisation__c =: originalAuthorisationId];
                    
                    Authorisation__c relatedDraftAuthorisation = null;
                    if(relatedDraftAuthorisationList.size() > 0) {
                        relatedDraftAuthorisation = relatedDraftAuthorisationList.get(0);  // There will be only one authorisation linked
                    }

                    Id relatedRenewalCaseId = null;
                    
                    if(relatedDraftAuthorisation != null) {
                        
                        relatedRenewalCaseId = relatedDraftAuthorisation.Application__c;

                        if(relatedRenewalCaseId != null) {
                            List<Case> listCases = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c FROM Case 
                                                    WHERE Id =: relatedRenewalCaseId
                                                    AND Status =: GlobalConstants.APPLICATION_STATUS_LODGED];
                            
                            // Renewal Case Present
                            // Display Error Message
                            if(listCases.size() > 0) {
                                Case renewalCaseRecord = listCases.get(0);
                                if(renewalCaseRecord != null) {
                                    tempCase.addError(System.Label.Expiry_Renewable_Case_Close_Error);
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPExpiryCaseClosePreProcessor','checkRenewalCaseIsInProgress',ex.getMessage(),ex);
        }
    }
}