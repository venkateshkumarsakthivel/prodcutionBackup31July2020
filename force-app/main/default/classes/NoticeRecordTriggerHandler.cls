public with sharing class NoticeRecordTriggerHandler {
    
    public static void beforeInsert(List<Notice_Record__c> newNoticeRecords){
        //AuditNoticeCongaValidator auditNoticeCongaValidator =  new AuditNoticeCongaValidator();
        //auditNoticeCongaValidator.validateNoticeRecordBeforeSendingCongaEmail(newNoticeRecords);
        
        NoticeRecordAuthNumberFieldUpdater authNumberFieldUpdator = new NoticeRecordAuthNumberFieldUpdater(newNoticeRecords);
        authNumberFieldUpdator.updateAuthNumbersField();
        
        NoticeRecordIssuedToEmailUpdator issuedToEmailUpdator = new NoticeRecordIssuedToEmailUpdator();
        issuedToEmailUpdator.updateEmailOnCreate(newNoticeRecords);
    }
    
    public static void beforeUpdate(Map<Id, Notice_Record__c> newNoticeRecords, Map<Id, Notice_Record__c> oldNoticeRecords){
        //AuditNoticeCongaValidator auditNoticeCongaValidator =  new AuditNoticeCongaValidator();
        //auditNoticeCongaValidator.validateNoticeRecordBeforeSendingCongaEmail(newNoticeRecords.values());
        
        NoticeRecordIssuedToEmailUpdator issuedToEmailUpdator = new NoticeRecordIssuedToEmailUpdator();
        issuedToEmailUpdator.updateEmailOnUpdate(newNoticeRecords, oldNoticeRecords);
    }
    
}