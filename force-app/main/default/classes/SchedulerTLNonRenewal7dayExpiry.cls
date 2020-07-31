/*
 * * * created by : Srikanth Sunkara
 * Created Date: 21/11/2019 (JIRA- 224)
*Scheduler class to call batch class:TaxiLicenceNonRenewal7dayExpiry
* 
Test Class: SchedulerTLNonRenewal7dayExpiryTest
*/ 
global class SchedulerTLNonRenewal7dayExpiry implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        TaxiLicenceNonRenewal7dayExpiry tlr = new TaxiLicenceNonRenewal7dayExpiry(); 
        Id ctxBatchId = database.executebatch(tlr);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        // system.schedule('TaxiLicenceNonRenewal7dayExpiry', '0 0 0 1 8 ?, new SchedulerAuthFeeBatch());  
    }
}