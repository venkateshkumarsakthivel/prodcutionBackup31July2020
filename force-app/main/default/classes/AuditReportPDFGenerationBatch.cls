global class AuditReportPDFGenerationBatch implements Database.Batchable<SObject>{
    List<Id> listofAuditCaseId;
    
    global AuditReportPDFGenerationBatch(List<Id> auditCaseId){
        this.listofAuditCaseId = auditCaseId;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id from Case LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList){
        
        //AuditCaseEmailPDFProcessor.sendPDF(listofAuditCaseId);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}