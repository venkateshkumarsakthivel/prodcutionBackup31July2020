global class SchedulerASPRegisterLevyExpiryBatch implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        ASPRegisterLevyExpiryBatch b = new ASPRegisterLevyExpiryBatch(); 
        Id ctxBatchId = database.executebatch(b);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        
    }
}