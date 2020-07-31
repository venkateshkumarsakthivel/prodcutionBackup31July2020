/*
 * @Description: Scheduler class to initiate taxi licence non renewal processing
 */
public with sharing class TaxiLicenceNonRenewalProcessScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TaxiLicenceNonRenewalProcessingBatch(), 200);
    }
}