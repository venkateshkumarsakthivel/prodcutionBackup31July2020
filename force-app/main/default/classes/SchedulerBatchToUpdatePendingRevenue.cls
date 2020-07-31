global class SchedulerBatchToUpdatePendingRevenue implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        BatchToUpdatePendingRevenue bpm = new BatchToUpdatePendingRevenue(); 
        Id ctxBatchId = database.executebatch(bpm);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        // system.schedule('BatchToUpdatePendingRevenue', '0 0 0 1 8 ?, new BatchToUpdatePendingRevenue());  
    }
}