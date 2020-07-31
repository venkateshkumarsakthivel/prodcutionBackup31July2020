/*
 * * * created by : Srikanth Sunkara
 * Created Date: 02/03/2020 (JIRA- 293... hot fix)
*Scheduler class to call batch class:TaxiLicenceRenewalCountZeroBatch->  Create Non Renewal expiry Case before 28 days of expiry date.
* 
Test Class: SchedulerTLRenewalMaxYearsZeroBatchTest
*/ 
global class SchedulerTLRenewalMaxYearsZeroBatch implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        TaxiLicenceRenewalMaxYearsZeroBatch tlr = new TaxiLicenceRenewalMaxYearsZeroBatch(); 
        Id ctxBatchId = database.executebatch(tlr);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        // system.schedule('TaxiLicenceRenewalCountZeroBatch', '0 0 0 1 8 ?, new SchedulerAuthFeeBatch());  
    }
}