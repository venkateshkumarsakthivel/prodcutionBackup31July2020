//scheduler class for batch "BatchToRemoveAuthAgentForTaxi" to Remove Agency and Agreement Type for Authorisations of Trasferred Taxi Licence
global class SchedulerToRemoveAuthAgentForTaxi implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        String query;
        query = 'SELECT Id, Agency__c, Agreement_Type__c, Application__c, Application__r.Sub_Type__c, Record_Type_Dev_Name__c ' + 
                'FROM Authorisation__c ' + 
                'WHERE Agency__c != null ' + 
                'AND Record_Type_Dev_Name__c = \'Taxi_Licence\' ' +
                'AND ((Application__c !=null AND Application__r.Sub_Type__c = \'Transfer - Proposed Owner\') OR Status__c = \'Surrendered\')';
        
        BatchToRemoveAuthAgentForTaxi newBatch = new BatchToRemoveAuthAgentForTaxi(query);
        Id ctxBatchId = Database.executeBatch(newBatch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
    
}