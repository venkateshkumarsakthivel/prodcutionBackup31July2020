//batch class for scheduler "SchedulerToGenerateCsvFiles" to upload csv files in S3
global class BatchToGenerateS3CSVFiles implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {
    
    String query;
    Map<Id, Attachment> attachementParentIdVsAttachemntMap = new Map<Id, Attachment>();

    global BatchToGenerateS3CSVFiles(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LPC_Config__mdt> lpcConfigMetadataList) {
        
        attachementParentIdVsAttachemntMap = new BatchToGenerateS3CSVFilesHelper().generateS3CSVFiles(lpcConfigMetadataList);
    }
    
    //finish method to upload CSV file file to S3
    global void finish(Database.BatchableContext BC) {
        
        Map<String, LPC_Config__mdt> fileNameVsLpcConfigMdtMap = new BatchToGenerateS3CSVFilesHelper().fetchLpcConfigMetadatasList();
        
        if(fileNameVsLpcConfigMdtMap != null && fileNameVsLpcConfigMdtMap.size() > 0) {
            
            if(attachementParentIdVsAttachemntMap != null && attachementParentIdVsAttachemntMap.size() > 0) {
                Set<Id> applicationLogIdSet = new BatchToGenerateS3CSVFilesHelper().fetchApplicationLogIdSet(attachementParentIdVsAttachemntMap);
                Map<Id, Application_Log__c> idVsApplicationLogMap = new BatchToGenerateS3CSVFilesHelper().fetchIdVsApplicationLogMap(applicationLogIdSet);
                Map<Id, Law_Part_Code__c> idVsLawPartCodeMap = new Map<Id, Law_Part_Code__c>();
                
                for(Id parentId : attachementParentIdVsAttachemntMap.keySet()) {
                    HTTPResponse res = new HTTPResponse();
                    try {
                        res = new BatchToGenerateS3CSVFilesHelper().uploadFileToS3(attachementParentIdVsAttachemntMap.get(parentId), fileNameVsLpcConfigMdtMap);
                        idVsApplicationLogMap = new BatchToGenerateS3CSVFilesHelper().fetchUpdateApplicationLog(res, idVsApplicationLogMap, parentId);
                        idVsLawPartCodeMap = new BatchToGenerateS3CSVFilesHelper().fetchLawPartCodeListToUpdate(res, idVsLawPartCodeMap, attachementParentIdVsAttachemntMap.get(parentId), fileNameVsLpcConfigMdtMap);
                    } 
                    catch(Exception ex) {
                        idVsApplicationLogMap = new BatchToGenerateS3CSVFilesHelper().fetchUpdateApplicationLog(res, idVsApplicationLogMap, parentId);
                    }
                }
                
                if(idVsApplicationLogMap != null && idVsApplicationLogMap.size() > 0) {
                    update idVsApplicationLogMap.values();
                }
                if(idVsLawPartCodeMap != null && idVsLawPartCodeMap.size() > 0) {
                    update idVsLawPartCodeMap.values();
                }
            }
        }
        
    }
    
}