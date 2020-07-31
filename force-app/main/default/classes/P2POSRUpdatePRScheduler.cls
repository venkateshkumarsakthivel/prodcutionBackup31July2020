global class P2POSRUpdatePRScheduler implements Schedulable, Database.AllowsCallouts{
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
        	Id P2POSRUpdatePRBatchableJobId = Database.executeBatch(new P2POSRUpdatePRBatchable(), Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
    		FlexQueue.moveJobToFront(P2POSRUpdatePRBatchableJobId);
        }else 
            Database.executeBatch(new P2POSRUpdatePRBatchable());
    }
}