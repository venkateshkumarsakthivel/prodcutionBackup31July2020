global class AuditReportPDFGenerationScheduler implements Schedulable {
    List<Id> listofAuditCaseId;
    global AuditReportPDFGenerationScheduler(List<Id> auditCaseId){
        this.listofAuditCaseId = auditCaseId;
    }
    
    global void execute(SchedulableContext sc) {
        AuditReportPDFGenerationBatch newBatch = new AuditReportPDFGenerationBatch(listofAuditCaseId);
        Id ctxBatchId = Database.executeBatch(newBatch);
        if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
    }
    
}