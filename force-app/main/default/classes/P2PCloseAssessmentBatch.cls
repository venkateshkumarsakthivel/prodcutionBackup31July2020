global class P2PCloseAssessmentBatch implements Database.Batchable<sObject>,Database.Stateful {
     
	private BusinessHours businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
	
    global String strQuery;
    public final Set<String> assessmentTypes = new Set<String>{GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT, GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED};
    public final String assessmentStatusAssessed = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
    public Date businessPaymentDueDayCurrentMonth;
    
    global P2PCloseAssessmentBatch() {
        
        // Get payment due date from custom settings
        AssesmentPaymentDueDate__c payDueDate = AssesmentPaymentDueDate__c.getInstance();
        Decimal dueDate = payDueDate.PaymentDuedate__c;
        system.debug('dueDate---------->'+integer.valueof(dueDate));
        
        
        // Get 26th of current month
        businessPaymentDueDayCurrentMonth = System.today();
        businessPaymentDueDayCurrentMonth = Date.newInstance(businessPaymentDueDayCurrentMonth.year(), businessPaymentDueDayCurrentMonth.month(), integer.valueof(dueDate));
        // Check if date is business day else return next business day
        businessPaymentDueDayCurrentMonth = getBusinessDayOfCurrentMonth(businessPaymentDueDayCurrentMonth);
        businessPaymentDueDayCurrentMonth = Date.newInstance(businessPaymentDueDayCurrentMonth.year(), businessPaymentDueDayCurrentMonth.month(), businessPaymentDueDayCurrentMonth.day());
        strQuery = 'SELECT Id, Name, Status__c, Assessment_Type__c, Payment_Due_Date__c, '
            + 'Account__r.Customer_Number__c, Total_Levy_Amount__c, Period_Start_Date__c, Period_End_Date__c, '
            + 'TSP_Assessment_Number__c, BSP_Assessment_Number__c, TSP_Levy_Amount__c, BSP_Levy_Amount__c, '
            + 'Taxpayer_Registration__r.Booking_Service_Provider_Number__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c '
            + 'FROM Assessment__c '
            + 'WHERE Status__c = : assessmentStatusAssessed ' 
            + 'AND Assessment_Type__c IN : assessmentTypes ' +
            + 'AND (Total_Levy_Amount__c = 0 OR Total_Levy_Amount__c = NULL) '
            + 'AND Payment_Due_Date__c = : businessPaymentDueDayCurrentMonth ';
        
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(strQuery);
    }
   
    //Execute method
    global void execute(Database.BatchableContext BC, List<Assessment__c> scope) {
        
        List<Assessment__c> assessmentsToBeMarkedAsClosed = new List<Assessment__c>();
        for(Assessment__c assessmentRecord : scope) {
            System.debug('assessmentRecord: '+assessmentRecord);
            assessmentRecord.Status__c = 'Closed';
            assessmentRecord.Is_Closed__c = true;
            assessmentsToBeMarkedAsClosed.add(assessmentRecord);
        }
        try{
            update assessmentsToBeMarkedAsClosed;
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage('Error','P2PCloseAssessmentBatch','execute',ex.getMessage(),ex);
        }
        
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    }
    
    // Get first business day on or after 26th of current month
    public Date getBusinessDayOfCurrentMonth(Date twentySixthOfCurrentMonth) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, twentySixthOfCurrentMonth);
        
        if(isInBusinessHours) {
            return twentySixthOfCurrentMonth;
        } else {
            twentySixthOfCurrentMonth = twentySixthOfCurrentMonth.addDays(1);
            return getBusinessDayOfCurrentMonth(twentySixthOfCurrentMonth);
        }
    }
}