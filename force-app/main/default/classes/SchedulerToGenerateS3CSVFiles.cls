//scheduler class for batch "BatchToGenerateCsvFiles" to upload csv files in S3
global class SchedulerToGenerateS3CSVFiles implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        String query;
        query = 'SELECT Id, MasterLabel, DeveloperName, Key__c, Secret__c, Bucket__c, Host__c, Directory__c, ' + 
                'FileName__c, ClassName__c FROM LPC_Config__mdt ORDER BY Id ASC';
        
        BatchToGenerateS3CSVFiles newBatch = new BatchToGenerateS3CSVFiles(query);
        Id ctxBatchId = Database.executeBatch(newBatch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
    
}