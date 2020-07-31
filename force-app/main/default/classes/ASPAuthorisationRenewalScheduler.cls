/**
* Scheduler class to Create Case for Authorisations (along with Draft Authorisation(s)) that are due for Renewal within next 30 days
* This Batch runs run Daily.
* 
* Criteria -
* Authorisation Type: BSP or TSP
* Status: Granted Unconditionally, Granted With Conditions or Suspended
* End Date in the next 30 days
* No cases with type: Service Provider and sub-type: Renewal Application which are in Draft or Lodged status associated to the authorisation
* 
*/
public with sharing class ASPAuthorisationRenewalScheduler implements Schedulable {
    
    public void execute(SchedulableContext schedulableContext) {
       Id ctxBatchId = Database.executeBatch(new ASPAuthorisationRenewalBatch());
       if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}