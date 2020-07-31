//scheduler class for batch "BatchToIdentifyExpiryingAgreements"
global class TaxiAgent30DaysRemainingExpiryScheduler implements Schedulable {
    
    global static String query;
      
    public void execute(SchedulableContext sc) {
      
      query = 'SELECT Notice_Email__c FROM Account WHERE No_of_Licences_Managed__c > 0';
      
      //29 means agents access on licences will be expiring after 30 days
      BatchToIdentifyExpiryingAgreements newBatch = new BatchToIdentifyExpiryingAgreements(query, 29);
      Id ctxBatchId = Database.executeBatch(newBatch, 1);
      if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}