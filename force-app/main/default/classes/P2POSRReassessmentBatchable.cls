global class P2POSRReassessmentBatchable implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
        
    public final String strQuery;
    public final String ASSESSMENT_TYPE_REASSESSMENT = 'Reassessment';
    public final String ASSESSMENT_TYPE_REASSESSMENT_COMPROMISE = 'Reassessment-Compromise';
    public final String ASSESSED = 'Assessed';
    
    global P2POSRReassessmentBatchable() {
        strQuery = 'SELECT Id, Name, Account__r.Customer_Number__c, ' + 
                        'Period_Start_Date__c, Period_End_Date__c, ' + 
                        'TSP_Assessment_Number__c, BSP_Assessment_Number__c, '+
                        'Revenue_Assessment_Number_TSP__c, Revenue_Assessment_Number_BSP__c, ' + 
                        'TSP_Levy_Amount__c, BSP_Levy_Amount__c, ' + 
                        'Taxpayer_Registration__r.Taxi_Service_Provider_Number__c, '+
                        'Taxpayer_Registration__r.Booking_Service_Provider_Number__c, '+
                        'Related_Assessment__c, Related_Assessment__r.Revenue_Assessment_Number_TSP__c, Related_Assessment__r.Revenue_Assessment_Number_BSP__c '+ 
                    'FROM Assessment__c '+ 
                    'WHERE (Assessment_Type__c =: ASSESSMENT_TYPE_REASSESSMENT OR Assessment_Type__c =: ASSESSMENT_TYPE_REASSESSMENT_COMPROMISE) '+ 
                        'AND Payment_via_Sweep__c = FALSE '+
                        'AND Status__c = :ASSESSED ' +
                        'AND Related_Assessment__r.Is_Closed__c = TRUE ' + 
            			'AND Revenue_Assessment_Number_TSP__c = \'\' AND Revenue_Assessment_Number_BSP__c = \'\' ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Assessment__c> assessments){
        P2POSRReassessmentHandler reassessmentHandler = new P2POSRReassessmentHandler(assessments);
        reassessmentHandler.process();       
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}