/*
* Description: Class to calculate Payment Due Date and Issue Date for Assessment if -
* 1] Status is Open/Held and Assessment type is Assessment.
* 2] Status is updated to Assessed 
* This method gets called from before insert and before update trigger on Assessment.
* Payment due date for an open/held assessment at creation is a business day on or after 26th of second month from assessment period 
* and should use Revenue NSW public holiday list to calculate the business day.
* Issue Date is 14 days prior to Payment Due Date.
*/ 
public with sharing class AssessmentPaymentDueDateCalculator {
    
    public BusinessHours businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
    
    public void setAssessmentPaymentDueDate(List<Assessment__c> newAssessments, Map<Id, Assessment__c> oldAssessments) {
        
        for(Assessment__c assessmentRecord : newAssessments) {
            
            //Check Assessment Status is 'Open' and Assessment Type is 'Assessment'
            if(assessmentRecord.Status__c == GlobalConstants.ASSESSMENT_STATUS_OPEN
               && assessmentRecord.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT
               && oldAssessments == NULL
               && assessmentRecord.Period_End_Date__c != NULL) {
                   
                   //Payment due date for an assessment is a business day on or after 26th of second month from assessment period
                   Date paymentDueDate = assessmentRecord.Period_End_Date__c.addMonths(2);
                   paymentDueDate = Date.newInstance(paymentDueDate.year(), paymentDueDate.month(), 26);
                   
                   //Check if date is business day else return next business day
                   paymentDueDate = checkBusinessDay(paymentDueDate);
                   
                   //Set Payment Due Date and Issue Date on Assessment Record
                   //Issue Date is 14 days prior to Payment Due Date
                   assessmentRecord.Payment_Due_Date__c = paymentDueDate;
                   assessmentRecord.Issue_Date__c = paymentDueDate.addDays(-14);
               }
            
            //Check Assessment Status is 'Assessed' 
            if(assessmentRecord.Status__c == GlobalConstants.ASSESSMENT_STATUS_ASSESSED
               && oldAssessments != NULL && oldAssessments.get(assessmentRecord.Id).Status__c != assessmentRecord.Status__c
               && assessmentRecord.Period_End_Date__c != NULL
               && String.isBlank(assessmentRecord.Revenue_Assessment_Number_BSP__c)
               && String.isBlank(assessmentRecord.Revenue_Assessment_Number_TSP__c)) {
                 
                   Date defaultPaymentDueDate = Date.newInstance(System.Today().Year(), System.Today().Month(), 26);
                   
                   //Check if date is business day else return next business day
                   defaultPaymentDueDate = checkBusinessDay(defaultPaymentDueDate);
                   
                   //if assessed 14 days prior calculate payment due date
                   if(System.Today().daysBetween(defaultPaymentDueDate) >= 14) {
                       assessmentRecord.Payment_Due_Date__c = defaultPaymentDueDate;
                       assessmentRecord.Issue_Date__c = defaultPaymentDueDate.addDays(-14);
                   } else {
                       
                       defaultPaymentDueDate = Date.newInstance(System.Today().addMonths(1).year(), System.Today().addMonths(1).month(), 26); 
                       assessmentRecord.Payment_Due_Date__c = checkBusinessDay(defaultPaymentDueDate);
                       assessmentRecord.Issue_Date__c = assessmentRecord.Payment_Due_Date__c.addDays(-14);
                   }
               }
        }
    }
    
    // Check if parameter date is business day else return next business day
    public Date checkBusinessDay(Date paymentDueDate) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, paymentDueDate);
        
        if(isInBusinessHours) {
            return paymentDueDate;
        } else {
            paymentDueDate = paymentDueDate.addDays(1);
            return checkBusinessDay(paymentDueDate);
        }
    }
}