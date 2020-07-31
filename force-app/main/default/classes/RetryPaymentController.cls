/*
 * @Description: Controller class for RetryPayment component.
 * This class is responsible for identifying the qualified payment for retry and scheduling it for next batch
 */
public with sharing class RetryPaymentController {
    
    @TestVisible
    private static DateTime CURRENT_DATETIME = System.now();
    private static final Integer THREE_PM_OF_THE_DAY = 15;
    @AuraEnabled
    public static String verifyPaymentDetails(String paymentId){
        //retrieve payment details.
        List<Order> payments = [SELECT Id, Status, AccountId, Authorisation__c, Received_Date__c,
                                    Authorisation__r.Payment_Frequency__c, Payment_Method__c, Processing_Date__c
                                FROM Order
                                WHERE Id = :paymentId];
        String returnStr;
        if(!payments.isEmpty()){
            //validate if the payment is rejected with payment method as direct debit for recurring payment
            if(payments[0].Status == GlobalConstants.PAYMENT_REJECTED_STATUS 
                    && payments[0].Payment_Method__c == GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT 
                    && payments[0].Authorisation__r.Payment_Frequency__c == GlobalConstants.MONTHLY_PAYMENT_FREQUENCY 
                    && payments[0].Processing_Date__c < System.today()){
                System.debug(LoggingLevel.INFO, 'Payment is qualified for resend.');
                
                //identify next schedule day for resend.
                Date nextScheduledDate = retrieveNextScheduleDay();
                if(nextScheduledDate != null){
                    returnStr = 'Payment request will be scheduled to be sent on ' + nextScheduledDate.format() + '.';
                }
            }
        }
        
        //return null if payment is not qualified for resend.
        return returnStr;
    }
    
    @AuraEnabled
    public static String resendPaymentRequest(String paymentId){        
        //identify the next schedule time for resend.
        Date nextScheduledDate = retrieveNextScheduleDay();
        
        List<Order> payments = [SELECT Id, Status, Received_Date__c, Processing_Date__c FROM Order WHERE Id = :paymentId];
        for(Order payment : payments){
            payment.Status = GlobalConstants.PAYMENT_DUE_STATUS ;
            payment.Processing_Date__c = nextScheduledDate;
            payment.Payment_Summary_Code__c = '';
            payment.Payment_Response_Code__c  = '';
            payment.Payment_Response_Description__c = '';
        }
        update payments;
        
        return 'SUCCESS';
    }
    
    private static Date retrieveNextScheduleDay(){
        List<BusinessHours> bhr = [SELECT Id, MondayEndTime, MondayStartTime FROM BusinessHours 
                                WHERE Name = :GlobalConstants.NSW_BUSINESS_HRS_NAME];
        Date returnDate;
        if(!bhr.isEmpty()){
            if(BusinessHours.isWithin(bhr[0].Id , CURRENT_DATETIME.date())){             
                if(CURRENT_DATETIME.hour() < THREE_PM_OF_THE_DAY){
                    //if current day is business day and current time is before 3:00pm, then payment is scheduled for current day.
                    returnDate = CURRENT_DATETIME.date() ;
                } else {
                    //if current day is business day and current time is past 3:00pm, then payment is scheduled for next business day.
                    returnDate = BusinessHours.nextStartDate(bhr[0].Id, CURRENT_DATETIME.date().addDays(1)).date();
                }               
            } else {
                //if current day is non-business day, then payment is scheduled for next business day.
                returnDate = BusinessHours.nextStartDate(bhr[0].Id, CURRENT_DATETIME.date()).date();
            }           
        }
        
        return returnDate;
    }
}