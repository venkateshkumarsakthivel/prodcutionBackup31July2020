/*
* Scheduler class which runs on daily basis at 04:00 am.
* Calls GetPaymentStatusRecordCount and GetPaymentStatusReportRequest api method.
*/
global class P2POSRGetPaymentStatusScheduler implements Schedulable, Database.AllowsCallouts {
    
    global void execute(SchedulableContext schedulableContext)  {
        Id P2POSRGetPaymentStatusBatchableJobId = Database.executeBatch(new P2POSRGetPaymentStatusRCBatchable(), 2000);
        if(!Test.isRunningTest()){FlexQueue.moveJobToFront(P2POSRGetPaymentStatusBatchableJobId);}
    }
}