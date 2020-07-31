/*
 * @Description: Scheduler class for TaxiBatchToUpdateAllegedBreachTime
 */
public with sharing class UpdateAllegedBreachTimeScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
      Id ctxBatchId = Database.executeBatch(new TaxiBatchToUpdateAllegedBreachTime());
      if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}