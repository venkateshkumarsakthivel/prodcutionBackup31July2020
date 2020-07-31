global class P2POSRCancelARScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
        	Id  P2POSRCancelARBatchableJobId = Database.executeBatch(new P2POSRCancelARBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
        	FlexQueue.moveJobToFront(P2POSRCancelARBatchableJobId);
        }
        else
            Database.executeBatch(new P2POSRCancelARBatchable());
    }
}