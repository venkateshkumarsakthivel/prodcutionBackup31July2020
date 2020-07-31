global class P2POSRUpdateARScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
            Id P2POSRUpdateARBatchableJobId = Database.executeBatch(new P2POSRUpdateARBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
        	FlexQueue.moveJobToFront(P2POSRUpdateARBatchableJobId);
       	 }else
            Database.executeBatch(new P2POSRUpdateARBatchable());
    }
}