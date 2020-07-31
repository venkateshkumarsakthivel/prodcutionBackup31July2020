public with sharing class NoticeRecordIssuedToEmailUpdator {
    
    public void updateEmailOnCreate(List<Notice_Record__c> newNoticeRecords) {    
        
        try {
            
            for(Notice_Record__c noticeRecord : newNoticeRecords) {
                
                if(noticeRecord.Method_of_Service__c == NULL 
                   || noticeRecord.Method_of_Service__c == 'Email') {
                       
                       if(noticeRecord.Issued_To__c != NULL) {
                           List<Account> listAccounts = [SELECT Id, Notice_Email__c, Notice_Address__c FROM Account 
                                                         WHERE Id =: noticeRecord.Issued_To__c];
                           
                           if(listAccounts.size() > 0) {
                               noticeRecord.Issued_to_Email__c = listAccounts.get(0).Notice_Email__c;
                           }
                       }
                   } else {
                       
                       User loggedInUser = GlobalUtility.getLoggedInUser();
                       noticeRecord.Issued_to_Email__c = loggedInUser.Email;
                   }
            }
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NoticeRecordIssuedToEmailUpdator','updateEmailOnCreate',ex.getMessage(),ex);                        
        }
    } 
    
    public void updateEmailOnUpdate(Map<Id, Notice_Record__c> newNoticeRecords, Map<Id, Notice_Record__c> oldNoticeRecords) {    
        
        try {
            
            for (Id recordId : newNoticeRecords.keySet()) {
                
                Notice_Record__c newNoticeRecord = newNoticeRecords.get(recordId);
                Notice_Record__c oldNoticeRecord = oldNoticeRecords.get(recordId);
                
                if(newNoticeRecord.Method_of_Service__c != NULL 
                   && newNoticeRecord.Method_of_Service__c != oldNoticeRecord.Method_of_Service__c
                   && newNoticeRecord.Method_of_Service__c == 'Email') {
                       
                       if(newNoticeRecord.Issued_to_Email__c == oldNoticeRecord.Issued_to_Email__c) {
                           if(newNoticeRecord.Issued_To__c != NULL) {
                               List<Account> listAccounts = [SELECT Id, Notice_Email__c, Notice_Address__c FROM Account 
                                                             WHERE Id =: newNoticeRecord.Issued_To__c];
                               
                               if(listAccounts.size() > 0) {
                                   newNoticeRecord.Issued_to_Email__c = listAccounts.get(0).Notice_Email__c;
                                   system.debug('Ch');
                               }
                           }
                       }
                       
                   } else if(newNoticeRecord.Method_of_Service__c != NULL 
                             && newNoticeRecord.Method_of_Service__c != oldNoticeRecord.Method_of_Service__c
                             && newNoticeRecord.Method_of_Service__c != 'Email') {
                                 
                                 if(newNoticeRecord.Issued_to_Email__c == oldNoticeRecord.Issued_to_Email__c) {
                                     User loggedInUser = GlobalUtility.getLoggedInUser();
                                     newNoticeRecord.Issued_to_Email__c = loggedInUser.Email;
                                 }
                             }
            }
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NoticeRecordIssuedToEmailUpdator','updateEmailOnUpdate',ex.getMessage(),ex);                        
        }
    } 
}