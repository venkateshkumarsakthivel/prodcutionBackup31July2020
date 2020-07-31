global class AuthorisationFeeCalculationScheduler implements Schedulable{
    
    global void execute(SchedulableContext schedulableContext)  {
        if(!Test.isRunningTest()) {
            Id AuthorisationFeeCalculationBatchJobId = Database.executeBatch(new AuthorisationFeeCalculationBatch(), 100);
            FlexQueue.moveJobToFront(AuthorisationFeeCalculationBatchJobId);
        }
        else
            Database.executeBatch(new AuthorisationFeeCalculationBatch());
    }
}