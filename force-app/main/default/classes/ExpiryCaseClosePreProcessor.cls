// This class is executed from CaseTriggerHandler
// Check if Renewal Case is in progress on Authorisation related to Expiry-Renewable Case, if yes display error message
public with sharing class ExpiryCaseClosePreProcessor {
    private Map<Id, Case> newApplications;
    
    public ExpiryCaseClosePreProcessor(Map<Id, Case> newApplications){
        this.newApplications = newApplications;
    }
    
    public void checkRenewalCaseIsInProgress() {    
        
        try {
            for(Case tempCase : newApplications.values()) {
                
                if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_ADMINISTRATION_RECORD_TYPE_DEV_NAME
                   && tempCase.Type == GlobalConstants.TAXI_CASE_TYPE 
                   && tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE
                   && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && (tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS
                      || tempCase.Sub_Status__c == GlobalConstants.DECLINED_CASE_SUB_STATUS)) {
                       
                       Id originalAuthorisationId = tempCase.Authorisation__c;  
                       
                       List<Case> listCases = [SELECT Id, CaseNumber, Authorisation__c, Status, Sub_Status__c FROM Case 
                                               WHERE Authorisation__r.Related_Authorisation__c =: originalAuthorisationId
                                               AND Status =: GlobalConstants.APPLICATION_STATUS_LODGED];
                       
                       //Renewal Case Present
                       // Display Error Message
                       if(listCases.size() > 0) {
                           Case renewalCaseRecord = listCases.get(0);
                           if(renewalCaseRecord != null) {
                               tempCase.addError(System.Label.Expiry_Renewable_Case_Close_Error);
                           }
                       }
                   }
            }
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ExpiryCaseClosePreProcessor','checkRenewalCaseIsInProgress',ex.getMessage(),ex);
        }
    }
}