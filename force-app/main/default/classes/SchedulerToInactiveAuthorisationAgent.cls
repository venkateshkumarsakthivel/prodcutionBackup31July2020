//scheduler class for batch "BatchToInactiveAuthorisationAgent" to update Authorisation_Agent__c records "Staus" as "Inactive"
global class SchedulerToInactiveAuthorisationAgent implements Schedulable {
	global void execute(SchedulableContext sc) {
        
		 String query ;
         query = 'SELECT Id, Name, Status__c, Expiry_Date__c FROM Authorisation_Agent__c WHERE Expiry_Date__c = YESTERDAY';  
            
         BatchToInactiveAuthorisationAgent newBatch = new BatchToInactiveAuthorisationAgent(query);
         Id ctxBatchId = Database.executeBatch(newBatch);
         if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
	}

}