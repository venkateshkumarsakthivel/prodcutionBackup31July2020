/*
 * Scheduler class for AuditLowLicenceCountNotificationBatch class
 */
global class AuditLowLicenceCountNotificationSch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    
        AuditLowLicenceCountNotificationBatch batch = new AuditLowLicenceCountNotificationBatch(); 
        Id ctxBatchId = database.executebatch(batch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}