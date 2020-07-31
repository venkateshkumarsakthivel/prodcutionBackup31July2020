public with sharing class NoticeWATComplianceCloneController {
    
    @AuraEnabled
    public static Notice_Record__c getNoticeRecord(String recordId){
        System.debug('recordId:'+recordId);
        return ([SELECT Id, Name, Case__r.Id, Notice_Type__c, Notice_Sub_Type__c, Next_Compliance_Notice__c FROM Notice_Record__c WHERE Id= :recordId LIMIT 1]);
    }
    
}