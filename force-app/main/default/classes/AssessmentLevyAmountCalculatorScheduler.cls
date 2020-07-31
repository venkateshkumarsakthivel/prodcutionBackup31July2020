/*
* Scheduler class to run on 1st of every month to calculate the levy amount for qualified assessments.
*/
global class AssessmentLevyAmountCalculatorScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        AssessmentLevyAmountCalculatorBatch batch = new AssessmentLevyAmountCalculatorBatch(); 
        Id ctxBatchId = database.executebatch(batch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}