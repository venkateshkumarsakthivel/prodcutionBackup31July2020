/*
* Schedualer class which runs everyday to Submit reassessment details to Revenue NSW.
* Calls updateAssessments api method.
* Criteria:
* Assessment Type = "ReAssessment"
* Status = "Assessed"
* Related previous assessment "Is Closed" is true.
*/
global class P2POSRReassessmentScheduler implements Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
            Id p2POSRReassessmentBatchableJobId = Database.executeBatch(new P2POSRReassessmentBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
            FlexQueue.moveJobToFront(p2POSRReassessmentBatchableJobId); 
        }
        else 
            Database.executeBatch(new P2POSRReassessmentBatchable());
    }
}