/**
* Server side rest resource controller for audit internal review functionality
*/
public without sharing class AuditDetailedFindingsReviewController {
    
    public AuditDetailedFindingsReviewController(){
        
        
    }
   /*
   @AuraEnabled
   public static ArxxusRFMv1__Visit__c fetchAuditVisit(String auditVisitId){
     
     return [SELECT OwnerId, ArxxusRFMv1__Status__c, Audit_Case__c, Audit_Case_Sub_Status__c, Audit_Case__r.Sub_Status__c FROM ArxxusRFMv1__Visit__c WHERE Id =:auditVisitId];
   }
   
   @AuraEnabled
   public static Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>> getAuditDetails(String auditVisitId){
     
     List<ArxxusRFMv1__taskSurveyAnswer__c> orderedAuditAnswers = new List<ArxxusRFMv1__taskSurveyAnswer__c>();
     List<Integer> indexes = new List<Integer>();
     
     Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>> sectionNameVsAuditAnswersMap = new Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>>();
     Map<String, ArxxusRFMv1__taskSurveyAnswer__c> compositeKeyVsSurveyAns = new Map<String, ArxxusRFMv1__taskSurveyAnswer__c>();
     Map<Integer, String> indexVsCompositeKey = new Map<Integer, String>();
     Map<String, Decimal> surveyQuestionVsIndex = new Map<String, Decimal>();
     Map<String, ArxxusRFMv1__taskSurveyAnswer__c> parentVsChildMap = new Map<String, ArxxusRFMv1__taskSurveyAnswer__c>();
       
     Set<String> surveyIds = new Set<String>();
       
     List<ArxxusRFMv1__Visit__c> relatedAuditVisit = [SELECT ArxxusRFMv1__Store__c, Audit_Case__c, ArxxusRFMv1__Status__c
                                                       FROM ArxxusRFMv1__Visit__c
                                                       WHERE ArxxusRFMv1__Status__c = :GlobalConstants.VISIT_STATUS_COMPLETED
                                                       AND Id =:auditVisitId];
       
     List<ArxxusRFMv1__taskSurveyAnswer__c> unorderedAuditAnswers = [SELECT ArxxusRFMv1__answer__c, ArxxusRFMv1__Answer_Index__c, ArxxusRFMv1__question__c,
                                                                      ArxxusRFMv1__questionDefinition__c, ArxxusRFMv1__Question_Values__c,
                                                                      ArxxusRFMv1__taskSurvey__c, ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__survey__c, ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.Name,
                                                                      ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c, Review_Comments__c,
                                                                      Detailed_Findings__c, Return_Requested__c, ArxxusRFMv1__Task_Survey_Answer__c, ArxxusRFMv1__Task_Survey_Answer__r.Name
                                                                      FROM ArxxusRFMv1__taskSurveyAnswer__c
                                                                      WHERE ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Visit__c = :relatedAuditVisit[0].Id
                                                                      AND ArxxusRFMv1__Task_Survey_Answer__c = NULL
                                                                      ORDER BY ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__task__r.ArxxusRFMv1__Index__c, ArxxusRFMv1__Answer_Index__c ASC];
     
     /*
     for(ArxxusRFMv1__taskSurveyAnswer__c tempAuditAnswer : unorderedAuditAnswers) {
       
         surveyIds.add(tempAuditAnswer.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__survey__c);
         
         if(tempAuditAnswer.ArxxusRFMv1__Task_Survey_Answer__c != null)
             parentVsChildMap.put(tempAuditAnswer.ArxxusRFMv1__Task_Survey_Answer__c, tempAuditAnswer);
             
     }
     
     for(ArxxusRFMv1__surveyQuestion__c surveyQuestion : [SELECT Id, ArxxusRFMv1__survey__c, ArxxusRFMv1__questionDefinition__c, ArxxusRFMv1__Index__c
                                                            FROM ArxxusRFMv1__surveyQuestion__c 
                                                            Where ArxxusRFMv1__survey__c IN : surveyIds]) {
        
            String mapKey = String.valueOf(surveyQuestion.ArxxusRFMv1__survey__c)+String.valueOf(surveyQuestion.ArxxusRFMv1__questionDefinition__c);
            surveyQuestionVsIndex.put(mapKey, surveyQuestion.ArxxusRFMv1__Index__c);
     }
     
     for(ArxxusRFMv1__taskSurveyAnswer__c tempAuditAnswer : unorderedAuditAnswers) {
     
       String mapKey = String.valueOf(tempAuditAnswer.ArxxusRFMv1__taskSurvey__r.ArxxusRFMv1__survey__c)+String.valueOf(tempAuditAnswer.ArxxusRFMv1__questionDefinition__c);
       indexes.add(Integer.valueOf(surveyQuestionVsIndex.get(mapKey))); 
       compositeKeyVsSurveyAns.put(mapKey, tempAuditAnswer);
       indexVsCompositeKey.put(Integer.valueOf(surveyQuestionVsIndex.get(mapKey)), mapKey);
     }
       
     indexes.sort();
        
     for(Integer i : indexes) {
        
      String compositeKey = indexVsCompositeKey.get(i);
      ArxxusRFMv1__taskSurveyAnswer__c tempTskSurAns = compositeKeyVsSurveyAns.get(compositeKey);
      orderedAuditAnswers.add(tempTskSurAns); 
      String parentKey = tempTskSurAns.Id;
          
      while(parentVsChildMap.containsKey(parentKey)) {
            
       ArxxusRFMv1__taskSurveyAnswer__c childTaskSurAns = parentVsChildMap.get(parentKey);
       orderedAuditAnswers.add(childTaskSurAns);
       parentVsChildMap.remove(parentKey);
       parentKey = childTaskSurAns.Id;                
      }
         
     }
     */
       /*
     for(ArxxusRFMv1__taskSurveyAnswer__c tempAuditAnswer : unorderedAuditAnswers) {
         
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
       
       return true;
     }
     catch(Exception e) {
            
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AuditInternalReviewController', 'saveAuditReviewComments', e.getMessage(), e);
       return false;
     }
   }
   
   @AuraEnabled
   public static Boolean saveAuditCase(String auditCaseId) {
      
       Case auditCase = [SELECT Sub_Status__c FROM Case WHERE Id =:auditCaseId];
       auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_FINDINGS_COMPLETED;
       update auditCase;
         
       return true;       
   }
    
   @AuraEnabled
   public static Case returnCaseForDetailedFindings(String auditCaseId){
     
     Case auditCase = [SELECT Sub_Status__c FROM Case WHERE Id =:auditCaseId];
     auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING;
     update auditCase;
      
     return auditCase;
   }
*/
}