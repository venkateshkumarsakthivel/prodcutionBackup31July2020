global class SchedulerForAppExpirationPost90Days implements Schedulable{
    
    public static final String ERROR ='Error';//logging level
    global void execute(SchedulableContext ctx) {
        
            BatchForApplicationExpirationPost90Days b = new BatchForApplicationExpirationPost90Days(); 
            Id ctxBatchId = database.executebatch(b); 
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}