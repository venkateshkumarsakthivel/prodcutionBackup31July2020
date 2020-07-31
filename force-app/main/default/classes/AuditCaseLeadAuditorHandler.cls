/*
* Helper class to change ownership not started visit records
* when lead auditor is changed on the case record.
*/
public without sharing class AuditCaseLeadAuditorHandler {
    
    /*
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public AuditCaseLeadAuditorHandler(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
    }   
    
    public void updateLeadAuditors() {    
        
        try {
            
            Map<String, String> auditCaseIdVsLeadAuditorsId = new Map<String, String>();
            Map<String, String> leadAuditorContactIdVsUserId = new Map<String, String>();
            Set<Case> leadAuditorCase = new Set<Case>();
            List<AccountTeamMember> accountTeamMembersToUpsert = new List<AccountTeamMember>();

            
            
            List<ArxxusRFMv1__Visit__c> visitsToUpdate = new List<ArxxusRFMv1__Visit__c>();
            
            for(Case tempCase : newCases.values()) {
                
                if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
                   && tempCase.Lead_Auditor__c != NULL
                   && tempCase.Lead_Auditor__c != oldCases.get(tempCase.Id).Lead_Auditor__c) {
                       
                       String mapValue = String.isBlank(tempCase.Lead_Auditor_Internal_User__c) ? tempCase.Lead_Auditor__c : tempCase.Lead_Auditor_Internal_User__c;
                       auditCaseIdVsLeadAuditorsId.put(tempCase.Id, mapValue);
                       leadAuditorCase.add(tempCase);
                   }
            }
            
            if(auditCaseIdVsLeadAuditorsId.size() == 0){
                
                return;
            }
            
            for(User tempLeadAuditor : [SELECT Id, FirstName, LastName, Audit_Contact_Id__c
                                        FROM User
                                        WHERE (Audit_Contact_Id__c IN :auditCaseIdVsLeadAuditorsId.values()
                                               OR Id IN :auditCaseIdVsLeadAuditorsId.values())]) {
                                                   
                                                   String mapKey = String.isBlank(tempLeadAuditor.Audit_Contact_Id__c) ? tempLeadAuditor.Id : tempLeadAuditor.Audit_Contact_Id__c;
                                                   leadAuditorContactIdVsUserId.put(mapKey, tempLeadAuditor.Id);                              
                                               }
            
            for(ArxxusRFMv1__Visit__c tempVisit : [SELECT Audit_Case__c 
                                                   FROM ArxxusRFMv1__Visit__c
                                                   WHERE Audit_Case__c IN :auditCaseIdVsLeadAuditorsId.keySet()
                                                   AND ArxxusRFMv1__Status__c = :GlobalConstants.VISIT_STATUS_NOT_STARTED]) {
                                                       
                                                       tempVisit.ArxxusRFMv1__Sales_Representative__c = leadAuditorContactIdVsUserId.get(auditCaseIdVsLeadAuditorsId.get(tempVisit.Audit_Case__c));
                                                       visitsToUpdate.add(tempVisit); 
                                                   }
            
            if(visitsToUpdate.size() > 0)
                Database.update(visitsToUpdate, FALSE);
            
            
            for(Case tempAccoutMember : leadAuditorCase){
                String mapKey = String.isBlank(tempAccoutMember.Lead_Auditor_Internal_User__c) ? tempAccoutMember.Lead_Auditor__c : tempAccoutMember.Lead_Auditor_Internal_User__c;
                AccountTeamMember accountTeamMember = new AccountTeamMember();
                accountTeamMember.AccountId = tempAccoutMember.AccountId;
                accountTeamMember.UserId = leadAuditorContactIdVsUserId.get(mapKey);
                accountTeamMember.AccountAccessLevel = 'Read';
          		accountTeamMember.TeamMemberRole = 'Auditor';
                accountTeamMembersToUpsert.add(accountTeamMember); 
            }
            
            if(accountTeamMembersToUpsert.size() > 0){
              List<Database.UpsertResult> accountTeamMemberUpsertResult = Database.upsert(accountTeamMembersToUpsert, FALSE);
            }
                
                
                }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseLeadAuditorHandler','updateLeadAuditors',ex.getMessage(),ex);                        
        }
    }
*/
}