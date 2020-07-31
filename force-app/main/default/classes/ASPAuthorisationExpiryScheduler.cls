/**
* Scheduler class to Create Case for Authorisations that are due for Expiry within next 7 days
* This Batch runs run Daily.
* 
* Criteria -
* Authorisation Type: BSP or TSP
* Status: Granted Unconditionally, Granted With Conditions or Suspended
* End Date in the next 7 days
* 
*/
public with sharing class ASPAuthorisationExpiryScheduler implements Schedulable {
    
    public void execute(SchedulableContext schedulableContext) {
        Id ctxBatchId = Database.executeBatch(new ASPAuthorisationExpiryBatch());
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}