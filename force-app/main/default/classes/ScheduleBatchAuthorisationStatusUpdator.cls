/*
Scheduled class for updating authorisations which are in already in approval process.
For Scheduling batch, please execute below code in execute anonymous window.

ScheduleBatchAuthorisationStatusUpdator batchUpdator = new ScheduleBatchAuthorisationStatusUpdator();
system.schedule('Update Authorisations', '0 0 * * * ?', batchUpdator);

*/ 

global class ScheduleBatchAuthorisationStatusUpdator implements Schedulable{
    public static final String ERROR ='Error';//logging level
    global void execute(SchedulableContext ctx) {
        
        ExecuteBatchAuthorisationStatusUpdater b = new ExecuteBatchAuthorisationStatusUpdater(); 
        Id ctxBatchId = Database.executebatch(b);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        
    }
}