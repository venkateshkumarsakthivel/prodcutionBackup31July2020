global class ScheduleBatchToCloseAssessment implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
            BatchToCloseAssessments b = new BatchToCloseAssessments(); 
            Id ctxBatchId = database.executebatch(b);
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}