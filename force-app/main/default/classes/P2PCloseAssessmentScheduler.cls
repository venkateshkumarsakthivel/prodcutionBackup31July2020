/*
* Schedualer class which runs on 21th of every month 4pm to Submit assessment details to Revenue NSW.
* this will run after P2POSRCreateAssessmentScheduler has executed
* Calls createAssessment api method.
* Criteria:
* Assessment Type = "Assessment"
* Status = "Assessed"
* Payment Due Date is on 26th of current month or first business day after 26th.
*/
global class P2PCloseAssessmentScheduler implements Schedulable, Database.AllowsCallouts {
        
    global void execute(SchedulableContext schedulableContext)  {
        Id P2PCloseAssessmentBatchJobId = Database.executeBatch(new P2PCloseAssessmentBatch(), 100);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(P2PCloseAssessmentBatchJobId);}
    }

}