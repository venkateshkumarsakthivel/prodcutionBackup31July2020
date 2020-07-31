/*
* Helper class to handle exemption/rebate related approval/rejection automation
*/
public with sharing class ExemptionRebateApprovalHelper {
    
    private Map<Id, Tax_Payer_Registration__c> newRegistrations;
    private Map<Id, Tax_Payer_Registration__c> oldRegistrations;
    
    public ExemptionRebateApprovalHelper(Map<Id, Tax_Payer_Registration__c> newRegistrations, Map<Id, Tax_Payer_Registration__c> oldRegistrations){
        
        this.newRegistrations = newRegistrations;
        this.oldRegistrations = oldRegistrations;
    }
    
    /*
*  Method to identify if exemption/rebate request is approved or rejected
*  and accordingly perform the required automation like updating related case, etc.
*/
    public void processApprovalRejectionActions() {
        
        try {
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;

            Set<Id> targetRegistrationIds = newRegistrations.keySet();
            
            //Map<Id, List<Case>> registrationIdVsRelatedOpenCases = new Map<Id, List<Case>>();
            List<Case> registrationIdVsRelatedOpenCasesToUpdate = new List<Case>();
            
            for(Case tempOpenExemptionRebateCase : [SELECT Status, Sub_Status__c, Tax_Payer_Registration__c
                                                    FROM Case
                                                    WHERE Tax_Payer_Registration__c IN :targetRegistrationIds
                                                    AND isClosed = FALSE
                                                    AND Type = :GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                                                    AND (Sub_Type__c = :GlobalConstants.Levy_Rebate_Case_SUB_TYPE
                                                         OR Sub_Type__c = :GlobalConstants.Levy_Exemption_Case_SUB_TYPE)]) {
                                                             
             
                                                             
           Tax_Payer_Registration__c relatedRegistration = newRegistrations.get(tempOpenExemptionRebateCase.Tax_Payer_Registration__c);
           
                                                      
             //if exemption/rebate request is in decision pending
             if(relatedRegistration.Approval_Status__c == GlobalConstants.REGISTRATION_DECISION_PENDING
               && oldRegistrations.get(relatedRegistration.Id).Approval_Status__c != GlobalConstants.REGISTRATION_DECISION_PENDING) {
                                                                    
               tempOpenExemptionRebateCase.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING;
               tempOpenExemptionRebateCase.setOptions(dmo);
               
               registrationIdVsRelatedOpenCasesToUpdate.add(tempOpenExemptionRebateCase);  
              
               relatedRegistration.Exemption_Approved__c = FALSE;
               relatedRegistration.Rebate_Approved__c = FALSE;
             }
                                                             
                                                             
             //if exemption/rebate request is approved 
             if(relatedRegistration.Approval_Status__c == GlobalConstants.REGISTRATION_APPROVED
               && oldRegistrations.get(relatedRegistration.Id).Approval_Status__c != GlobalConstants.REGISTRATION_APPROVED) {
                                                                    
               tempOpenExemptionRebateCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
               tempOpenExemptionRebateCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
               registrationIdVsRelatedOpenCasesToUpdate.add(tempOpenExemptionRebateCase);       
                   
               if(relatedRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE){
                relatedRegistration.Exemption_Approved__c = TRUE;
                relatedRegistration.Exemption_Approval_Date__c = System.Today();
               }
                   
               if(relatedRegistration.Applied_For_Rebate__c == GlobalConstants.YES_VALUE) {
                
                relatedRegistration.Rebate_Approved__c = TRUE;
                relatedRegistration.Rebate_Approval_Date__c = System.Today();
                relatedRegistration.Rebate_Rejected__c = FALSE;
                 
                relatedRegistration.Levy_Rebate_Exempted__c = TRUE;   
                   
               }
             }                                                  
                                                             
             //if exemption/rebate request is rejected
             if(relatedRegistration.Approval_Status__c == GlobalConstants.REGISTRATION_REJECTED
               && oldRegistrations.get(relatedRegistration.Id).Approval_Status__c != GlobalConstants.REGISTRATION_REJECTED) {
                                                                    
               tempOpenExemptionRebateCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
               tempOpenExemptionRebateCase.Sub_Status__c = GlobalConstants.DECLINED_CASE_SUB_STATUS;
               registrationIdVsRelatedOpenCasesToUpdate.add(tempOpenExemptionRebateCase);  
               
               relatedRegistration.Exemption_Approved__c = FALSE;
               relatedRegistration.Exemption_Approval_Date__c = NULL;
               relatedRegistration.Rebate_Approved__c = FALSE;
               relatedRegistration.Rebate_Approval_Date__c = NULL;
               relatedRegistration.Rebate_Rejected__c = TRUE;
                   
                   
             } relatedRegistration.Levy_Rebate_Exempted__c = TRUE;
                                                          
                                                             
           }
            
           if(registrationIdVsRelatedOpenCasesToUpdate.size() > 0)
            Database.Update(registrationIdVsRelatedOpenCasesToUpdate, FALSE); 
            
            for(Tax_Payer_Registration__c tpr: newRegistrations.values()){
                if(registrationIdVsRelatedOpenCasesToUpdate.size() == 0) {
                   tpr.Levy_Rebate_Exempted__c = TRUE;
                    
                }
                
            }
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ExemptionRebateApprovalHelper', 'processApprovalRejectionActions', e.getMessage(), e);
        }
    }
}