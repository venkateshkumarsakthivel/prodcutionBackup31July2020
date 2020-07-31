/*
 *  Description: Helper class to process uncleared payments after T+3 days
 */
public with sharing class TPlusThreePaidPaymentProcessor {
    private static final Integer T_MINUS_3_DAYS = -3; 
    private static final Integer SECS_IN_MIN = 60;
    private static final Integer MINS_IN_HR = 60;
    private static final Integer MILLIS_IN_SEC = 1000;
    
    @TestVisible
    private static Date paymentReceivedDate;
    @TestVisible
    private static Date startDateToProcess;
    private static BusinessHours bhr;
    
    public static void process(Date receivedDate){
        paymentReceivedDate = receivedDate;
        //we assume start and end time of every business day will be same and hence using monday as a reference
        if(bhr == null) bhr = [SELECT Id, MondayEndTime, MondayStartTime FROM BusinessHours 
                                WHERE Name = :GlobalConstants.NSW_BUSINESS_HRS_NAME];
    
        //identify if the current day is a business day
        if(isBusinessDay()){
            //identify the date for which payments are to be updated.
            startDateToProcess = getStartDateToProcess();
            
            //initiate batch to process uncleared payments
            TPlusThreePaidPaymentProcessorBatch batchProcessor = new TPlusThreePaidPaymentProcessorBatch(startDateToProcess);
            Id ctxBatchId = Database.executeBatch(batchProcessor, 1000);
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        }
        
    }
    
    private static Boolean isBusinessDay(){
        return BusinessHours.isWithin(bhr.Id , paymentReceivedDate);
    } 
    
    private static Date getStartDateToProcess(){
        Date startDate = GlobalUtility.retrieveBusinessDay(paymentReceivedDate, T_MINUS_3_DAYS, bhr);
        System.debug(startDate);
        
        return startDate;
    }
}