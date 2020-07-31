/**
* Server side rest resource controller for audit internal review functionality
*/
public with sharing class AuditInternalReviewController {
    
    public AuditInternalReviewController(){
        
        
    }
   /*
   @AuraEnabled
   public static Case fetchAuditCase(String auditCaseId){
     
     return [SELECT Status, Sub_Status__c, Assigned_Reviewer__c, Assigned_Reviewer__r.Audit_User__c 
             FROM Case WHERE Id =:auditCaseId];
   }
   
   /*
   @AuraEnabled
   public static Boolean isAuditManager(){
     
     return GlobalUtility.isUserHasAssignedPermissionSet('Compliance_Manager_Audit_Intelligence_and_Analytics');
   } 
   */
   /*
   @AuraEnabled
   public static Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>> getAuditDetails(String auditCaseId){
     
     Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>> sectionNameVsAuditAnswersMap = new Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>>();
     
     List<ArxxusRFMv1__Visit__c> relatedAuditVisit = [SELECT ArxxusRFMv1__Store__c, Audit_Case__c, ArxxusRFMv1__Status__c
                                                       FROM ArxxusRFMv1__Visit__c
                                                       WHERE ArxxusRFMv1__Status__c = :GlobalConstants.VISIT_STATUS_COMPLETED
                                                       AND Audit_Case__c =:auditCaseId];
     
     List<ArxxusRFMv1__taskSurveyAnswer__c> auditAnswers = [SELECT ArxxusRFMv1__answer__c, ArxxusRFMv1__Answer_Index__c, ArxxusRFMv1__question__c,
                                                             ArxxusRFMv1__questionDefinition__c, ArxxusRFMv1__Question_Values__c,
                                                             ArxxusRFMv1__taskSurvey__c, ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.Name,
                                                             ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c, Review_Comments__c,
                                                             Detailed_Findings__c, Return_Requested__c, ArxxusRFMv1__Task_Survey_Answer__c, ArxxusRFMv1__Task_Survey_Answer__r.Name
                                                             FROM ArxxusRFMv1__taskSurveyAnswer__c
                                                             WHERE ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Visit__c = :relatedAuditVisit[0].Id
                                                             AND ArxxusRFMv1__Task_Survey_Answer__c = NULL
                                                             ORDER BY ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c, ArxxusRFMv1__Answer_Index__c ASC];
                                                             
     for(ArxxusRFMv1__taskSurveyAnswer__c tempAuditAnswer : auditAnswers) {
         
         List<ArxxusRFMv1__taskSurveyAnswer__c> auditAnswersList = new List<ArxxusRFMv1__taskSurveyAnswer__c>();
         if(sectionNameVsAuditAnswersMap.containsKey(tempAuditAnswer.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.Name))
           auditAnswersList = sectionNameVsAuditAnswersMap.get(tempAuditAnswer.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.Name);
           
         auditAnswersList.add(tempAuditAnswer);
         sectionNameVsAuditAnswersMap.put(tempAuditAnswer.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.Name, auditAnswersList);
     }                                                         
     
     return sectionNameVsAuditAnswersMap;
   }
   
   @AuraEnabled
   public static Boolean saveAuditReviewComments(List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswers, String auditCaseId) {
     
     try {
       
       Database.update(taskSurveyAnswers, FALSE);
       
       Case auditCase = [SELECT Sub_Status__c FROM Case WHERE Id =:auditCaseId];
       auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_AUDIT_COMPLETED;
       update auditCase;
         
       return true;
     }
     catch(Exception e) {
            
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AuditInternalReviewController', 'saveAuditReviewComments', e.getMessage(), e);
       return false;
     }
   }
   
   @AuraEnabled
   public static Case returnCaseForDetailedFindings(String auditCaseId, List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswers){
     
     Database.update(taskSurveyAnswers, FALSE);
       
     Case auditCase = [SELECT Sub_Status__c, Lead_Auditor_Internal_User__c, OwnerId FROM Case WHERE Id =:auditCaseId];
     auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING;
     auditCase.OwnerId = String.isNotBlank(auditCase.Lead_Auditor_Internal_User__c) ? auditCase.Lead_Auditor_Internal_User__c : auditCase.OwnerId;   
     
     update auditCase;
      
     return auditCase;
   }
    */
}