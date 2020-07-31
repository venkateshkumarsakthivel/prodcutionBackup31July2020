global class P2POSRCreateARScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext schedulableContext)  {
            
        if(!Test.isRunningTest()) {
            Id P2POSRCreateARBatchableJobId = Database.executeBatch(new P2POSRCreateARBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
            FlexQueue.moveJobToFront(P2POSRCreateARBatchableJobId);
        } else {
            Database.executeBatch(new P2POSRCreateARBatchable());        
        }
    }
    
}