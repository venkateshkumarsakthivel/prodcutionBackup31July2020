global class SchedulerAuthFeeBatch implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        AuthorisationFeeCalculationBatch auth = new AuthorisationFeeCalculationBatch(); 
        Id ctxBatchId = database.executebatch(auth);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
      // system.schedule('AuthorisationFeeCalculationBatch', '0 0 0 1 8 ?, new SchedulerAuthFeeBatch());  
    }
}