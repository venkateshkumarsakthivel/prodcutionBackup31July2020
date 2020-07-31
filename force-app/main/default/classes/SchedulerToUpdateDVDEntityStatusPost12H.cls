global class SchedulerToUpdateDVDEntityStatusPost12H implements Schedulable{
 public static final String ERROR ='Error';//logging level
    global void execute(SchedulableContext ctx) {
        
            BatchToUpdateDVDEntityStatusPost12Hours b = new BatchToUpdateDVDEntityStatusPost12Hours(); 
            Id ctxBatchId = database.executebatch(b); 
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}