//scheduler class for batch "BatchToDeleteAgreementCases" to delete Agreement Case
global class SchedulerToDeleteAgreementCases implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        String query;
        query = 'SELECT Id, CaseNumber, Status, Date_Submitted__c, LastModifiedDate, RecordType.DeveloperName, (SELECT Id, Name FROM Attachments)' + 
                ' FROM Case' + 
                ' WHERE Date_Submitted__c = null AND RecordType.DeveloperName = \'Agent_Registration\'';
        
        BatchToDeleteAgreementCases newBatch = new BatchToDeleteAgreementCases(query);
        Id ctxBatchId = Database.executeBatch(newBatch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
    
}