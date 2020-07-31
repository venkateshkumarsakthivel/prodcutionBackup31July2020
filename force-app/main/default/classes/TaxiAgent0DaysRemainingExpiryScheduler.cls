//scheduler class for batch "BatchToIdentifyExpiryingAgreements"
global class TaxiAgent0DaysRemainingExpiryScheduler implements Schedulable {
    
    global String query;
      
    global void execute(SchedulableContext sc) {
      
      query = 'SELECT Notice_Email__c FROM Account WHERE No_of_Licences_Managed__c > 0';
      
      //-1 means agents access has expired on the licences
      BatchToIdentifyExpiryingAgreements newBatch = new BatchToIdentifyExpiryingAgreements(query, -1);
      Id ctxBatchId = Database.executeBatch(newBatch, 1);
      if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
}