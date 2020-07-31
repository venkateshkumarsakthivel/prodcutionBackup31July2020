/*
 * Class to validate if matching assessment already exists for specified assessment
 * period and related levy registration
 */
public with sharing class MatchingAssessmentValidator {
  
    public void findMatchingAssessments(List<Assessment__c> newAssessments) {
      
      Map<String, Assessment__c> keyVsMatchingAssessments = new Map<String, Assessment__c>();
      Map<String, Id> keysToMatchVsId = new Map<String, Id>();
      
      //storing keys to match for all new assessments records being created/updated
      for(Assessment__c tempNewAssessment : newAssessments) {
      
       if(tempNewAssessment.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT)
        keysToMatchVsId.put(tempNewAssessment.Assessment_Key__c, tempNewAssessment.Id);
      }
      
      //collecting matching assessments and storing them in map against their keys
      for(Assessment__c tempMatchingAssessment : [SELECT Assessment_Key__c, Status__c, Period_Start_Date__c, Period_End_Date__c
                                                  FROM Assessment__c
                                                  WHERE Assessment_Key__c IN :keysToMatchVsId.keySet()
                                                  AND Id NOT IN :keysToMatchVsId.values()
                                                  AND Assessment_Type__c = :GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT
                                                  AND Status__c != :GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED]) {
        
         keyVsMatchingAssessments.put(tempMatchingAssessment.Assessment_Key__c, tempMatchingAssessment);                                           
      }
      
      //validating if new assessment has any matching assessment, if yes show error message
      for(Assessment__c tempNewAssessment : newAssessments) {
        
        if(tempNewAssessment.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT
            && keyVsMatchingAssessments.containsKey(tempNewAssessment.Assessment_Key__c))
          tempNewAssessment.addError(System.Label.Levy_Matching_Assessment_Error);
      } 
    }
}