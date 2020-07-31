public with sharing class EstimateReasonCodeCalculator {

    private Map<Id, Assessment__c> oldAssessments;
    private Map<Id, Assessment__c> newAssessments;
    
    public EstimateReasonCodeCalculator(Map<Id, Assessment__c> oldAssessments, Map<Id, Assessment__c> newAssessments){
        this.oldAssessments = oldAssessments;
        this.newAssessments = newAssessments;
    }
    
    public void calculate(){
        for(Id assessmentId : newAssessments.keyset()){
            if(isQualified(newAssessments.get(assessmentId))){
                //update reason code
                updateReasonCode(newAssessments.get(assessmentId));
            }
        }
    }
    
    private void updateReasonCode(Assessment__c assessment){
        if(assessment.Levy_Calculation_Method__c == GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF){
            //update reason code to 'Return is not received'
            assessment.Estimate_Reason_Code__c = assessment.Is_Average_Calculation_Used__c? 
                GlobalConstants.RETURN_NOT_RECEIVED : GlobalConstants.INADEQUATE_ASSESSMENT_RECORDS;
        } else if(assessment.Levy_Calculation_Method__c == GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY  
                  || assessment.Levy_Calculation_Method__c == GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF){
                      //update reason code to blank
                      assessment.Estimate_Reason_Code__c = null;
                  }
    }
    
    private Boolean isQualified(Assessment__c assessment){
        if(assessment.Status__c == GlobalConstants.ASSESSMENT_STATUS_ASSESSED && oldAssessments.get(assessment.Id) != null
                && oldAssessments.get(assessment.Id).Status__c != assessment.Status__c){
            return true;
        }
        return false;
    }
}