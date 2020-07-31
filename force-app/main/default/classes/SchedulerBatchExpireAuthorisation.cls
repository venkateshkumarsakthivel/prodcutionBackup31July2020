global class SchedulerBatchExpireAuthorisation implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        BatchForAuthExpiration b = new BatchForAuthExpiration(); 
        Id ctxBatchId = database.executebatch(b);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
    
}