global class SchedulerBatchCreateExpiryCase implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        BatchToCreateExpiryCase b = new BatchToCreateExpiryCase(); 
        Id ctxBatchId = database.executebatch(b);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        
    }
}