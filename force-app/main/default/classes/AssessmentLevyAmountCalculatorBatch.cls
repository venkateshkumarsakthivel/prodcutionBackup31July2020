/*
* Batch class to calculate the levy amount for qualified assessments.
*/ 
global class AssessmentLevyAmountCalculatorBatch implements Database.Batchable<SObject> {
    
    // Constructor
    public AssessmentLevyAmountCalculatorBatch() {
        
    }
    
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String assessmentStatusOpen = GlobalConstants.ASSESSMENT_STATUS_OPEN; //'Open';
        String assessmentTypeAssessment = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT; //Assessment';
        
        String strQuery = 'SELECT Id, Status__c, Assessment_Type__c, Taxpayer_Registration__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c, Taxpayer_Registration__r.Booking_Service_Provider_Number__c, '
            + 'Period_Start_Date__c, Period_End_Date__c, Manual_Assessment_Required__c, Manual_Assessment_Comments__c, Rebate_Approved__c, Rebate_Approval_Date__c, Annual_Estimates__c, Exemption_Approved__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Levy__c, Estimated_BSP_Transactions__c, Estimated_TSP_Transactions__c '
            + 'FROM Assessment__c '
            + 'WHERE Status__c = :assessmentStatusOpen ' 
            + 'AND Assessment_Type__c = :assessmentTypeAssessment';
        
        System.debug(LoggingLevel.INFO, '== AssessmentLevyAmountCalculatorBatch Generated Query ==' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    // Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Assessment__c> scopeList) {
        
        try {
            
            System.debug(LoggingLevel.INFO, '== AssessmentLevyAmountCalculatorBatch execute - scope size ==' + scopeList.size());
            
            // Filter Assessments according to following criteria
            // Check Assessment Dates -
            // Period End Date = Last day of penultimate month  
            // Period Start Date = First day of penultimate month or or Rebate Approved Scenario - A Date year before Last day of penultimate month
            // So we check only Period End Date here
            Date lastDateOfSecondLastMonth = System.today().addMonths(-1).toStartOfMonth().addDays(-1);
            System.debug(LoggingLevel.INFO, '== lastDateOfSecondLastMonth ==' + lastDateOfSecondLastMonth);
            
            List<Assessment__c> listAssessments = new List<Assessment__c>();
            
            for(Assessment__c assessmentRecord : scopeList) {
                
                if(assessmentRecord.Period_End_Date__c == lastDateOfSecondLastMonth) {
                       
                       listAssessments.add(assessmentRecord);
                   }
            }
            
            AssessmentLevyAmountCalculator.calculate(listAssessments, true);
            
        } catch(Exception ex) {
            System.debug('AssessmentLevyAmountCalculatorBatch::execute' + ex);
        }
    }
    
    // Batch Finish Method
    global void finish(Database.BatchableContext BC) {
        // do nothing
    }
}