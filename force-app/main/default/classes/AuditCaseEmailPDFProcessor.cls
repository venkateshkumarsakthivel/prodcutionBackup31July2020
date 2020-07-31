/*
* Helper class to send audit PDF
* to Case Contact, Visit Owner and Case Owner based on Auditer type selected {Internal of external}
* when Case sub status is updated to Finding Pending and Finding Completed. 
*/
public without sharing class AuditCaseEmailPDFProcessor{
    
    public AuditCaseEmailPDFProcessor(){
        
        
    }
    /*
    /*
private Map<Id, Case> newCases;
private Map<Id, Case> oldCases;

public AuditCaseEmailPDFProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){

this.newCases = newCases;
this.oldCases = oldCases;
}

public void sendPDFEmails() {

try {

Set<String> targetAuditCaseIds = new Set<String>();

for(Case tempCase : newCases.values()) {

if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
&& tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS
&& tempCase.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_AUDIT_COMPLETED
&& tempCase.Sub_Status__c != oldCases.get(tempCase.Id).Sub_Status__c) {

targetAuditCaseIds.add(tempCase.Id);
}
}

if(targetAuditCaseIds.size() > 0)
sendPDF(targetAuditCaseIds);

}
catch(Exception ex) {

ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseEmailPDFProcessor','sendPDFEmails',ex.getMessage(),ex);                        
}
}
*/
    /*
    public static void sendPDF(List<String> auditCompletedCaseIds) {
        List<Messaging.SingleEmailMessage> auditCompletionEmails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> pdfAttachmentsToInsert = new List<Attachment>();
        List<Attachment> internalPDFAttachmentsToInsert = new List<Attachment>();
        
        Map<String, ArxxusRFMv1__Visit__c> caseIdVsVisit = new Map<String, ArxxusRFMv1__Visit__c>();
        
        EmailTemplate auditEmailTemplate = [SELECT Name FROM EmailTemplate WHERE DeveloperName = 'Audit_Report_Email_Notification'];
        
        for(ArxxusRFMv1__Visit__c tempVisit : [SELECT Id, Audit_Case__c, Audit_Case__r.Lead_Auditor__r.Email, Audit_Case__r.Audit_Vendor__r.Auditor_Type__c,
                                               Audit_Case__r.Owner.Email, Name, Audit_Case__r.Assigned_Reviewer__r.Email, Audit_Case__r.Contact.Email,
                                               Audit_Case__r.Sub_Status__c, Audit_Case__r.ContactId
                                               FROM ArxxusRFMv1__Visit__c
                                               WHERE Audit_Case__c IN :auditCompletedCaseIds
                                               AND ArxxusRFMv1__Status__c = :GlobalConstants.VISIT_STATUS_COMPLETED
                                               ORDER BY CreatedDate ASC]) {
                                                   
                                                   caseIdVsVisit.put(tempVisit.Audit_Case__c, tempVisit);
                                               }
        
        for(String tempAuditCase : auditCompletedCaseIds) {
            if(caseIdVsVisit.containsKey(tempAuditCase)) {
                
                List<String> emailIds = new List<String>();
                
                
                if((caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING) && 
                    (caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Audit_Vendor__r.Auditor_Type__c == GlobalConstants.AUDITOR_TYPE_INTERNAL)){
                        PageReference auditPDFPage =  Page.AuditSurveyPDF;
                        auditPDFPage.getParameters().put('id', (String)caseIdVsVisit.get(tempAuditCase).Id);
                        auditPDFPage.setRedirect(true);
                        Attachment attachment = new Attachment();    
                        attachment.body = test.isRunningTest() ? blob.valueof('test') : auditPDFPage.getContentAsPdf();
                        attachment.Name = 'Initial Finding_'+caseIdVsVisit.get(tempAuditCase).Name+' PDF '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.pdf';
                        attachment.IsPrivate = false;
                        attachment.ParentId = caseIdVsVisit.get(tempAuditCase).Id;
                        attachment.ContentType = 'application/pdf';
                        internalPDFAttachmentsToInsert.add(attachment);
                    
                }
                else{
                    if((caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING)){
                        if(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Audit_Vendor__r.Auditor_Type__c == GlobalConstants.AUDITOR_TYPE_EXTERNAL){
                            if(String.isNotBlank(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Lead_Auditor__r.Email))
                                emailIds.add(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Lead_Auditor__r.Email);
                            
                            if(String.isNotBlank(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Assigned_Reviewer__r.Email))
                                emailIds.add(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Assigned_Reviewer__r.Email);
                            
                        }
                    }
                    PageReference auditPDFPage =  Page.AuditSurveyPDF;
                    auditPDFPage.getParameters().put('id', (String)caseIdVsVisit.get(tempAuditCase).Id);
                    auditPDFPage.setRedirect(true);
                    
                    if(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING){
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(caseIdVsVisit.get(tempAuditCase).Name);
                        efa.setInline(false);
                        efa.setContentType('application/pdf');
                        
                        if(!test.isRunningTest()){
                            
                            efa.setBody(auditPDFPage.getContentAsPdf());
                        }
                        else{
                            
                            blob body = blob.valueof('test');
                            efa.setBody(body);
                        }
                        
                        System.debug('Email Ids: '+emailIds);
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(emailIds);
                        //email.setSubject(caseIdVsVisit.get(tempAuditCase).Name+' Report');
                        //email.setPlainTextBody('Please find attached PDF copy of submitted report.');
                        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                        email.setTemplateId(auditEmailTemplate.Id);
                        email.setWhatId(tempAuditCase);
                        email.setTargetObjectId(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.ContactId);
                        email.setTreatTargetObjectAsRecipient(FALSE);
                        
                        
                        auditCompletionEmails.add(email);
                        
                        Attachment attachment = new Attachment();    
                        attachment.body = test.isRunningTest() ? blob.valueof('test') : auditPDFPage.getContentAsPdf();
                        
                        if(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING)
                            attachment.Name = 'Initial Finding_'+caseIdVsVisit.get(tempAuditCase).Name+' PDF '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.pdf';
                        else
                            attachment.Name = 'Final_'+caseIdVsVisit.get(tempAuditCase).Name+' PDF '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.pdf';
                        
                        attachment.IsPrivate = false;
                        attachment.ParentId = caseIdVsVisit.get(tempAuditCase).Id;
                        attachment.ContentType = 'application/pdf';
                        pdfAttachmentsToInsert.add(attachment);
                    }
                    else{
                        Attachment attachment = new Attachment();    
                        attachment.body = test.isRunningTest() ? blob.valueof('test') : auditPDFPage.getContentAsPdf();
                        
                        if(caseIdVsVisit.get(tempAuditCase).Audit_Case__r.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING)
                            attachment.Name = 'Initial Finding_'+caseIdVsVisit.get(tempAuditCase).Name+' PDF '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.pdf';
                        else
                            attachment.Name = 'Final_'+caseIdVsVisit.get(tempAuditCase).Name+' PDF '+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.pdf';
                        
                        attachment.IsPrivate = false;
                        attachment.ParentId = caseIdVsVisit.get(tempAuditCase).Id;
                        attachment.ContentType = 'application/pdf';
                        pdfAttachmentsToInsert.add(attachment);
                    }
                    
                    
                }
            }
        }
        
        if(internalPDFAttachmentsToInsert.size() > 0 ){
            Database.insert(internalPDFAttachmentsToInsert, FALSE);
        }
        
        //Code Commented out as per AUD-636 (No automated mails will be sent out on inital findings, only attachements are attached to the visit record).
        //if(pdfAttachmentsToInsert.size() > 0 && auditCompletionEmails.size() > 0){
        //    Messaging.sendEmail(auditCompletionEmails);
        // }
        
        
        if(pdfAttachmentsToInsert.size() > 0)
            Database.insert(pdfAttachmentsToInsert, FALSE);
    }
*/
}