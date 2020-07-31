/*
 * Description : Assessment Trigger handler class
 */ 
public with Sharing class AssessmentTriggerHandler {
    
    //before insert handlers
    public static void beforeInsert(List<Assessment__c> newAssessments) {
        
        System.debug(LoggingLevel.INFO, 'Invoking before insert process for Assessment');
        
        //auto populate assessment record data from tax payer registration
        AssessmentInitialiser assessmentInitialiser = new AssessmentInitialiser();
        assessmentInitialiser.initialiseAssessmentFromTPR(newAssessments);
        
        //calculate assessment start and end period dates
        AssessmentPeriodCalculator periodCalculator = new AssessmentPeriodCalculator();
        periodCalculator.calculatePeriod(newAssessments);
        //Calculate final return reminder date 
        periodCalculator.calculateReminderReturnDates(newAssessments);
        
        //calculate Payment Due Date and Issue Date for Assessment if Status is 'Open' and Assessment Type is 'Assessment'
        //Added condition to check Assessment Type = "Reassessment" for PLEVY-556
        AssessmentPaymentDueDateCalculator assessmentPaymentDueDateCalculator =  new AssessmentPAymentDueDateCalculator();
        assessmentPaymentDueDateCalculator.setAssessmentPaymentDueDate(newAssessments, NULL);
        
        //validate if matching assessment already exists for specified assessment period and related levy registration
        MatchingAssessmentValidator matchingAssessmentValidator = new MatchingAssessmentValidator();
        matchingAssessmentValidator.findMatchingAssessments(newAssessments);
        
        //Calculate Total Levy Amount
        AssessmentLevyAmountCalculationHandler levyAmountCalculationHandler = new AssessmentLevyAmountCalculationHandler();
        levyAmountCalculationHandler.filterAssessmentRecordsToCalculateTotalLevyAmount(newAssessments, NULL);
    }
    
    //before insert handlers
    public static void beforeUpdate(Map<Id, Assessment__c> newAssessmentsMap, Map<Id, Assessment__c> oldAssessmentsMap) {
        
        //calculate assessment start and end period dates
        AssessmentPeriodCalculator periodCalculator = new AssessmentPeriodCalculator();
        periodCalculator.calculatePeriod(newAssessmentsMap.values());
        //Calculate final return reminder date 
        periodCalculator.calculateReminderReturnDates(newAssessmentsMap.values());

        //validate if matching assessment already exists for specified assessment period and related levy registration
        MatchingAssessmentValidator matchingAssessmentValidator = new MatchingAssessmentValidator();
        matchingAssessmentValidator.findMatchingAssessments(newAssessmentsMap.values());
        
        //calculate Payment Due Date and Issue Date for Assessment if Status is 'Open' and Assessment Type is 'Assessment'
        //Added condition to check Assessment Type = "Reassessment" for PLEVY-556
        AssessmentPaymentDueDateCalculator assessmentPaymentDueDateCalculator =  new AssessmentPAymentDueDateCalculator();
        assessmentPaymentDueDateCalculator.setAssessmentPaymentDueDate(newAssessmentsMap.values(), oldAssessmentsMap);
        
        // Calculate Total Levy Amount if TSP Transaction Count or BSP Transaction Count is changed
        AssessmentLevyAmountCalculationHandler levyAmountCalculationHandler = new AssessmentLevyAmountCalculationHandler();
        levyAmountCalculationHandler.filterAssessmentRecordsToCalculateTotalLevyAmount(newAssessmentsMap.Values(), oldAssessmentsMap);
        
        EstimateReasonCodeCalculator calculator = new EstimateReasonCodeCalculator(oldAssessmentsMap, newAssessmentsMap);
        calculator.calculate();
    }
    
}