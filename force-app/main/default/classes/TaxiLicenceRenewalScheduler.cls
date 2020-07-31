/*
 * @Description: Scheduler class to initiate taxi licence renewal
 */
public with sharing class TaxiLicenceRenewalScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Id ctxBatchId = Database.executeBatch(new TaxiLicenceRenewalBatch(), 200);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}