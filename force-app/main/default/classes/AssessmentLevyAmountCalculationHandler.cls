/*
* This class filters assesment records on basic of following criteria -
* 1. Calculate Total Levy Amount if TSP Transaction Count or BSP Transaction Count is changed
* 2. Assessment Status = 'Open'
* 3. Assessment Type = 'Assessment'
*/

public with sharing class AssessmentLevyAmountCalculationHandler {
    
    public void filterAssessmentRecordsToCalculateTotalLevyAmount(List<Assessment__c> newAssessments, Map<Id, Assessment__c> oldAssessmentsMap) {
        
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        
        for(Assessment__c assessmentRecNew : newAssessments) {
            
            if(oldAssessmentsMap != NULL) {
            
              Assessment__c assessmentRecOld = oldAssessmentsMap.get(assessmentRecNew.Id);
            
              // check if BSP_Transaction_Count__c or TSP_Transaction_Count__c is updated
              if(assessmentRecNew.BSP_Transaction_Count__c != assessmentRecOld.BSP_Transaction_Count__c
                 || assessmentRecNew.TSP_Transaction_Count__c != assessmentRecOld.TSP_Transaction_Count__c) {
                       
                       // Filter Assessments according to following criteria
                       // check Assessment type is Assessment and Status is Open
                       if(assessmentRecNew.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT
                          && (assessmentRecNew.Status__c == GlobalConstants.ASSESSMENT_STATUS_OPEN
                             || assessmentRecNew.Status__c == GlobalConstants.ASSESSMENT_STATUS_HELD
                             || assessmentRecNew.Status__c == GlobalConstants.ASSESSMENT_STATUS_ASSESSED))
                           
                           listAssessments.add(assessmentRecNew);
              }
            }
            else {
              
              
              if((assessmentRecNew.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT
                   || assessmentRecNew.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_REASSESSMENT
                   || assessmentRecNew.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_REASSESSMENT_COMPROMISED
                   || assessmentRecNew.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED)
                  && (assessmentRecNew.Status__c == GlobalConstants.ASSESSMENT_STATUS_ASSESSED
                       || assessmentRecNew.Status__c == GlobalConstants.ASSESSMENT_STATUS_ISSUED))
                 listAssessments.add(assessmentRecNew);
            }
        }
        
        if(listAssessments.size() > 0)
         AssessmentLevyAmountCalculator.calculate(listAssessments, false);
    }
}