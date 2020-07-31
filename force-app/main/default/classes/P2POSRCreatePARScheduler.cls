global class P2POSRCreatePARScheduler implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
            Id P2POSRCreatePARBatchableJobId = Database.executeBatch(new P2POSRCreatePARBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
            FlexQueue.moveJobToFront(P2POSRCreatePARBatchableJobId);
        }
        else
            Database.executeBatch(new P2POSRCreatePARBatchable());
    }
}