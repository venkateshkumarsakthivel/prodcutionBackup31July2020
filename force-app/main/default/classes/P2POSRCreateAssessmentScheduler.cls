/*
* Schedualer class which runs on 21th of every month to Submit assessment details to Revenue NSW.
* Calls createAssessment api method.
* Criteria:
* Assessment Type = "Assessment"
* Status = "Issued"
* Payment Due Date is on 26th of current month or first business day after 26th.
*/
global class P2POSRCreateAssessmentScheduler implements Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext schedulableContext)  {
        // We are setting batch size using label to make it configurable
        // Currently set to 1
        if(!Test.isRunningTest()) {
        	Id  P2POSRCreateAssessmentBatchableJobId = Database.executeBatch(new P2POSRCreateAssessmentBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
        	FlexQueue.moveJobToFront(P2POSRCreateAssessmentBatchableJobId); 
        }
    	else 
            Database.executeBatch(new P2POSRCreateAssessmentBatchable());
            
    }
}