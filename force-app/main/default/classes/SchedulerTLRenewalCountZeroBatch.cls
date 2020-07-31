/*
 * * * created by : Srikanth Sunkara
 * Created Date: 21/11/2019 (JIRA- 224)
*Scheduler class to call batch class:TaxiLicenceRenewalCountZeroBatch->  Create Non Renewal expiry Case before 28 days of expiry date.
* 
Test Class: SchedulerTLRenewalCountZeroBatchTest
*/ 
global class SchedulerTLRenewalCountZeroBatch implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        TaxiLicenceRenewalCountZeroBatch tlr = new TaxiLicenceRenewalCountZeroBatch(); 
        Id ctxBatchId = database.executebatch(tlr);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        // system.schedule('TaxiLicenceRenewalCountZeroBatch', '0 0 0 1 8 ?, new SchedulerAuthFeeBatch());  
    }
}