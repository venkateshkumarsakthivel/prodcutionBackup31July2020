/*
 *  Description: Helper class to process to identify the date of payment that needs to be processed for recurring debit.
 */
public with sharing class DDPendingPaymentProcessor {
    private static final Long PREVIOUS_DAY = -1; 
    private static final Integer SECS_IN_MIN = 60;
    private static final Integer MINS_IN_HR = 60;
    private static final Integer MILLIS_IN_SEC = 1000;
    
    @TestVisible
    private static Date paymentReceivedDate;
    @TestVisible
    private static List<Date> startDatesToProcess;
    private static BusinessHours bhr;
    
    public static void process(Date receivedDate){
        paymentReceivedDate = receivedDate;
        //we assume start and end time of every business day will be same and hence using monday as a reference
        if(bhr == null) bhr = [SELECT Id, MondayEndTime, MondayStartTime FROM BusinessHours 
                                WHERE Name = :GlobalConstants.NSW_BUSINESS_HRS_NAME];
    
        //identify if the current day is a business day
        if(isBusinessDay()){
            startDatesToProcess = new List<Date>{paymentReceivedDate};
            
            //identify the missing dates between two consecutive business days.
            Date previousBusinessDate = getPreviousBusinessDate();
            
            Integer dayCount = 1;
            while(previousBusinessDate.addDays(dayCount).daysBetween(paymentReceivedDate) > 0){
                startDatesToProcess.add(previousBusinessDate.addDays(dayCount));
                dayCount++;
            }
            
            //initiate batch to process pending payments
            DDPendingPaymentProcessorBatch batchProcessor = new DDPendingPaymentProcessorBatch(startDatesToProcess);
            Id ctxBatchId = Database.executeBatch(batchProcessor, GlobalConstants.NUMBER_OF_DIRECT_DEBIT_PAYMENTS_TO_PROCESS );
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        }
        
    }
    
    private static Boolean isBusinessDay(){
        return BusinessHours.isWithin(bhr.Id , paymentReceivedDate);
    } 
    
    private static Date getPreviousBusinessDate(){
        Long startMillis = bhr.MondayStartTime.hour()* MINS_IN_HR* SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayStartTime.minute() * SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayStartTime.second() * MILLIS_IN_SEC + bhr.MondayStartTime.millisecond();
            
        Long endMillis = bhr.MondayEndTime.hour()* MINS_IN_HR* SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayEndTime.minute() * SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayEndTime.second() * MILLIS_IN_SEC + bhr.MondayEndTime.millisecond();
            
        Long millisToAdd = (endMillis - startMillis) * PREVIOUS_DAY;
        
        Date previousDate = BusinessHours.add(bhr.Id, paymentReceivedDate, millisToAdd).date();
        System.debug(previousDate);
        
        return previousDate;
    }
}