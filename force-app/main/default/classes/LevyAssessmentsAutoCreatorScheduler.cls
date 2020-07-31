/*
* Scheduler class to be scheduled to run on 1st of every month and create assessment records for the previous month.

* Criteria: 1 AND 2 AND 3 AND 4
* 1. Status of Taxpayer registration is 'Active'
* 2. Sub Status of Taxpayer registration is 'Completed'
* 3. Status of authorisation is either "Granted Unconditionally" or "Granted Conditionally" or "Suspended"
* 4. Start date of authorisation linked to taxpayer registration is in past.
* 5. End date of authorisation linked to taxpayer registration is greater than or equal to 1st of previous month (either in future or in previous month)
*/
global class LevyAssessmentsAutoCreatorScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) 
    {
        LevyAssessmentsAutoCreatorBatch batch = new LevyAssessmentsAutoCreatorBatch(); 
        Id ctxBatchId = database.executebatch(batch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        
    }
}