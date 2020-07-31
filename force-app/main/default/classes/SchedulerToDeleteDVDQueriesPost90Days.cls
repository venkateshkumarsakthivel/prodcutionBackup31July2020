global class SchedulerToDeleteDVDQueriesPost90Days implements Schedulable{
    public static final String ERROR ='Error';//logging level
    global void execute(SchedulableContext ctx) {
        
        BatchToDeleteDVDQueriesPost90Days b = new BatchToDeleteDVDQueriesPost90Days(); 
        Id ctxBatchId = database.executebatch(b); 
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}