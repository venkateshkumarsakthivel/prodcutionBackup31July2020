/*
Helper class for sending email with latest attachment to Auditor, ASP and Assigned reviewer of an Audit Case on Case closure.
*/


public class AuditCaseSendCloserReport {
    public  AuditCaseSendCloserReport(){
        
        
    }
    /*
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    Set<Id> getAuditCaseFindingsCompletedVisits;
    Set<Id> getAuditVisitId;
    public AuditCaseSendCloserReport(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        this.newCases = newCases;
        this.oldCases = oldCases;
        this.getAuditCaseFindingsCompletedVisits = new Set<Id>();
        this.getAuditVisitId = new Set<Id>();
    }
    
    public void sendAuditCaseSendCloserReport(){
        try{
            for(Case tempCase : newCases.values()){
                if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
                    && (tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS  && oldCases.get(tempCase.Id).Status == GlobalConstants.CASE_STATUS_IN_PROGRESS)
                    && ((tempCase.Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED 
                         && oldCases.get(tempCase.Id).Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_REPORT_APPROVAL)))){
                             System.debug('Inside Case Closer iteration: '+tempCase.Id);
                             getAuditCaseFindingsCompletedVisits.add(tempCase.Id);
                         }
            }
            
            for(ArxxusRFMv1__Visit__c auditCaseVisit : [SELECT Id, ArxxusRFMv1__Status__c, Audit_Case__c from ArxxusRFMv1__Visit__c 
                                                        WHERE ArxxusRFMv1__Status__c =: GlobalConstants.VISIT_STATUS_COMPLETED
                                                        AND Audit_Case__c IN: getAuditCaseFindingsCompletedVisits
                                                        ANd Audit_Case__c != null]){
                                                            if(!getAuditCaseFindingsCompletedVisits.contains(auditCaseVisit.Audit_Case__c)){
                                                                getAuditCaseFindingsCompletedVisits.remove(auditCaseVisit.Audit_Case__c);
                                                            }
                                                        }
            
            List<Messaging.SingleEmailMessage> auditCompletionEmails = new List<Messaging.SingleEmailMessage>();
            List<String> emailIds = new List<String>();
            
            if(!getAuditCaseFindingsCompletedVisits.isEmpty()){
                
                
                
                for(ArxxusRFMv1__Visit__c visitId : [SELECT Id, ArxxusRFMv1__Status__c, Audit_Case__c from ArxxusRFMv1__Visit__c WHERE Audit_Case__c IN: getAuditCaseFindingsCompletedVisits 
                                                     AND ArxxusRFMv1__Status__c =: GlobalConstants.VISIT_STATUS_COMPLETED AND Audit_Case__c != null]){
                                                         
                                                         
                                                         EmailTemplate auditEmailTemplate = [SELECT Name FROM EmailTemplate WHERE DeveloperName = 'Audit_Report_Email_Notification'];
                                                         
                                                         ArxxusRFMv1__Visit__c visitName = [Select Id, Name, Audit_Case__c, Audit_Case__r.ContactId, Audit_Case__r.Assigned_Reviewer__r.Email,
                                                                                            Audit_Case__r.Lead_Auditor__r.Email, Audit_Case__r.Contact.Email 
                                                                                            from ArxxusRFMv1__Visit__c where Id = : visitId.Id LIMIT 1];
                                                         List<Attachment> auditReportPDFId = [Select Id, Name, Body FROM Attachment 
                                                                                              where ParentID =: visitId.Id AND (NOT Name like 'Initial%') 
                                                                                              ORDER by CreatedDate DESC LIMIT 1];
                                                         
                                                         if(auditReportPDFId.isEmpty()){
                                                             System.debug('No Attachment found');
                                                             return;
                                                         }
                                                         
                                                         Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                                         efa.setFileName(visitName.Name);
                                                         efa.setInline(false);
                                                         efa.setContentType('application/pdf');
                                                         efa.setBody(auditReportPDFId[0].Body);
                                                         
                                                         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                                         if(String.isNotBlank(visitName.Audit_Case__r.Lead_Auditor__r.Email))
                                                             emailIds.add(visitName.Audit_Case__r.Lead_Auditor__r.Email);
                                                         
                                                         if(String.isNotBlank(visitName.Audit_Case__r.Contact.Email))
                                                             emailIds.add(visitName.Audit_Case__r.Contact.Email);
                                                         
                                                         if(String.isNotBlank(visitName.Audit_Case__r.Assigned_Reviewer__r.Email))
                                                             emailIds.add(visitName.Audit_Case__r.Assigned_Reviewer__r.Email);
                                                         
                                                         email.setToAddresses(emailIds);
                                                         
                                                         email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                                                         email.setTemplateId(auditEmailTemplate.Id);
                                                         email.setWhatId(visitName.Audit_Case__c);
                                                         email.setTargetObjectId(visitName.Audit_Case__r.ContactId);
                                                         email.setTreatTargetObjectAsRecipient(FALSE);
                                                         auditCompletionEmails.add(email);
                                                         
                                                         
                                                     } 
            }
            
            If(!auditCompletionEmails.isEmpty()){
                Messaging.sendEmail(auditCompletionEmails);
                System.debug('Email Sent Successfully');
                return;
            }
            else{
                System.debug('Email Failed');
                return;
            }            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseSendCloserReport','sendAuditCaseSendCloserReport',ex.getMessage(),ex);                        
            
        }
    }
*/
}