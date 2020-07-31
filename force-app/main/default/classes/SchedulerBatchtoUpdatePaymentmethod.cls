global class SchedulerBatchtoUpdatePaymentmethod implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        BatchtoUpdatePaymentMethod bpm = new BatchtoUpdatePaymentMethod(); 
        Id ctxBatchId = database.executebatch(bpm);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        // system.schedule('BatchtoUpdatePaymentMethod', '0 0 0 1 8 ?, new SchedulerAuthFeeBatch());  
    }
}