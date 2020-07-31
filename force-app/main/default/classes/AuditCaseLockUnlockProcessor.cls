/*
 * Helper class to lock audit related records 
 * when audit case is closed. Also to unlock audit related records
 * when audit case is opened.
 */
public without sharing class AuditCaseLockUnlockProcessor {
/*
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public AuditCaseLockUnlockProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
    
        this.newCases = newCases;
        this.oldCases = oldCases;
    }   
    
    public void processAuditCasesLockUnlock() {    
       
     try {
      
        Map<String, Case> idsVsCasesToLock = new Map<String, Case>();
        Map<String, Case> idsVsCasesToUnlock = new Map<String, Case>();
        
        List<ArxxusRFMv1__Visit__c> visitsToLock = new List<ArxxusRFMv1__Visit__c>();
        List<ArxxusRFMv1__Visit__c> visitsToUnlock = new List<ArxxusRFMv1__Visit__c>();
        
        List<ArxxusRFMv1__Tasks__c> tasksToLock = new List<ArxxusRFMv1__Tasks__c>();
        List<ArxxusRFMv1__Tasks__c> tasksToUnlock = new List<ArxxusRFMv1__Tasks__c>();
        
        List<ArxxusRFMv1__taskSurvey__c> taskSurveysToLock = new List<ArxxusRFMv1__taskSurvey__c>();
        List<ArxxusRFMv1__taskSurvey__c> taskSurveysToUnlock = new List<ArxxusRFMv1__taskSurvey__c>();
        
        List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswersToLock = new List<ArxxusRFMv1__taskSurveyAnswer__c>();
        List<ArxxusRFMv1__taskSurveyAnswer__c> taskSurveyAnswersToUnlock = new List<ArxxusRFMv1__taskSurveyAnswer__c>();
        
        for(Case tempCase : newCases.values()) {
          
           if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
               && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
               && tempCase.Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED
               && tempCase.Status != oldCases.get(tempCase.Id).Status
               && tempCase.Sub_Status__c != oldCases.get(tempCase.Id).Sub_Status__c) {
               
               idsVsCasesToLock.put(tempCase.Id, tempCase);
           }
           
           if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
               && tempCase.Status != GlobalConstants.CLOSED_CASE_STATUS
               && tempCase.Sub_Status__c != GlobalConstants.SUB_STATUS_COMPLETED
               && oldCases.get(tempCase.Id).Status == GlobalConstants.CLOSED_CASE_STATUS
               && oldCases.get(tempCase.Id).Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED) {
               
               idsVsCasesToUnLock.put(tempCase.Id, tempCase);
           }
        }
        
        if(idsVsCasesToLock.size() > 0) {
          
          Approval.lock(idsVsCasesToLock.values(), false);
          
          visitsToLock = [SELECT ArxxusRFMv1__Store__c, Audit_Case__c, ArxxusRFMv1__Status__c
                           FROM ArxxusRFMv1__Visit__c
                           WHERE Audit_Case__c IN :idsVsCasesToLock.keySet()];
          
          tasksToLock = [SELECT ArxxusRFMv1__TaskStatus__c, ArxxusRFMv1__Visit__c 
                          FROM ArxxusRFMv1__Tasks__c
                          WHERE ArxxusRFMv1__Visit__c IN :visitsToLock];
                          
          taskSurveysToLock = [SELECT ArxxusRFMv1__status__c, ArxxusRFMv1__task__c  
                                FROM ArxxusRFMv1__taskSurvey__c
                                WHERE ArxxusRFMv1__task__c IN :tasksToLock];
          
          taskSurveyAnswersToLock = [SELECT ArxxusRFMv1__answer__c, ArxxusRFMv1__taskSurvey__c 
                                      FROM ArxxusRFMv1__taskSurveyAnswer__c
                                      WHERE ArxxusRFMv1__taskSurvey__c IN :taskSurveysToLock];
          
          Approval.lock(taskSurveyAnswersToLock, false);
          Approval.lock(taskSurveysToLock, false);                
          Approval.lock(tasksToLock, false);   
          Approval.lock(visitsToLock, false);                            
        }
        
        if(idsVsCasesToUnLock.size() > 0) {
          
          Approval.unlock(idsVsCasesToUnLock.values(), false);
          
          visitsToUnlock = [SELECT ArxxusRFMv1__Store__c, Audit_Case__c, ArxxusRFMv1__Status__c
                             FROM ArxxusRFMv1__Visit__c
                             WHERE Audit_Case__c IN :idsVsCasesToUnlock.keySet()];
          
          tasksToUnlock = [SELECT ArxxusRFMv1__TaskStatus__c, ArxxusRFMv1__Visit__c FROM ArxxusRFMv1__Tasks__c
                            WHERE ArxxusRFMv1__Visit__c IN :visitsToUnlock];
                          
          taskSurveysToUnlock = [SELECT ArxxusRFMv1__status__c, ArxxusRFMv1__task__c FROM ArxxusRFMv1__taskSurvey__c
                                  WHERE ArxxusRFMv1__task__c IN :tasksToUnlock];
                                  
          taskSurveyAnswersToUnlock = [SELECT ArxxusRFMv1__answer__c, ArxxusRFMv1__taskSurvey__c 
                                        FROM ArxxusRFMv1__taskSurveyAnswer__c
                                        WHERE ArxxusRFMv1__taskSurvey__c IN :taskSurveysToUnlock];
          
          Approval.UnlockResult[] lrList = Approval.unlock(taskSurveyAnswersToUnlock, false);
          System.debug('Unlock Result: '+lrList);
          Approval.unlock(taskSurveysToUnlock, false);                
          Approval.unlock(tasksToUnlock, false);   
          Approval.unlock(visitsToUnlock, false);                            
        }
     }
     catch(Exception ex) {
        
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseLockUnlockProcessor','processAuditCasesLockUnlock',ex.getMessage(),ex);                        
     }
    }
*/
}