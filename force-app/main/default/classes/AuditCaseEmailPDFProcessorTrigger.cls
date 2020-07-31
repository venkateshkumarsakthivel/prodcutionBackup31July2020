public class AuditCaseEmailPDFProcessorTrigger {
    
    public AuditCaseEmailPDFProcessorTrigger() {
        
        
    }
    /*
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    Set<Id> getAuditCaseCompletedVisits;
    
    public AuditCaseEmailPDFProcessorTrigger(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
        this.getAuditCaseCompletedVisits = new Set<Id>();
    }
    
    public void sendAuditCaseReportEmailonVisitCompletion(){
        try{
            System.debug('In Audit Email trigger');
            for(Case tempCase : newCases.values()){
                if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
                    && tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS 
                    && ((tempCase.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING 
                         && oldCases.get(tempCase.Id).Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING)
                        || (tempCase.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_COMPLETED
                            && oldCases.get(tempCase.Id).Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_FINDINGS_PENDING)))){
                                System.debug('Inside Case iteration: '+tempCase.Id);
                                getAuditCaseCompletedVisits.add(tempCase.Id);
                            }
            } 

            
            for(ArxxusRFMv1__Visit__c auditCaseVisit : [SELECT Id, ArxxusRFMv1__Status__c, Audit_Case__c from ArxxusRFMv1__Visit__c 
                                                        WHERE ArxxusRFMv1__Status__c =: GlobalConstants.VISIT_STATUS_COMPLETED
                                                        AND Audit_Case__c IN: getAuditCaseCompletedVisits
                                                        ANd Audit_Case__c != null]){
                                                            if(!getAuditCaseCompletedVisits.contains(auditCaseVisit.Audit_Case__c)){
                                                                getAuditCaseCompletedVisits.remove(auditCaseVisit.Audit_Case__c);
                                                            }
                                                        }
            
            if(!getAuditCaseCompletedVisits.isEmpty()){
                List<Id> auditCaseId = new List<Id>(getAuditCaseCompletedVisits);
                AuditReportPDFGenerationScheduler schdulebatch = new AuditReportPDFGenerationScheduler(auditCaseId);
                DateTime currentdate = system.now().addMinutes(1);
                String day = string.valueOf(currentdate.day());
                String month = string.valueOf(currentdate.month());
                String hour = string.valueOf(currentdate.hour());
                String minute = string.valueOf(currentdate.minute());
                String second = string.valueOf(currentdate.second());
                String year = string.valueOf(currentdate.year());
                String strSchedule = second +' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                System.schedule('AuditReportPDFGenerationBatch_'+system.now()+':'+string.valueOf(system.now().millisecond()), strSchedule, schdulebatch);
              }
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseEmailPDFProcessorTrigger','sendAuditCaseReportEmailonVisitCompletion',ex.getMessage(),ex);                        
            
        }
    }
    */
}