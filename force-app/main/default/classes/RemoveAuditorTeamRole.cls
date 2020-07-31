public without sharing class RemoveAuditorTeamRole {
    
    public RemoveAuditorTeamRole(){
        
        
    }
    /*
    private static Profile auditUserProfile;
    private static List<User> tempAuditUsers;    
    
    static {
        auditUserProfile = [SELECT Name, Id FROM Profile WHERE Name = :Label.External_Audit_User_Profile_Name];
        tempAuditUsers = [SELECT Audit_Contact_Id__c 
                           FROM User
                           WHERE ProfileId = :auditUserProfile.Id];
    }
    
    //Constructor method to find eligible cases.
    public RemoveAuditorTeamRole(Map<Id, Case> newCases, Map<Id, Case> oldCases) {
        
        Map<String, ArxxusRFMv1__Visit__c> caseAndAuditorIdVsVisit = new Map<String, ArxxusRFMv1__Visit__c>();
        Map<String, String> auditUserIdVsAuditContactId = new Map<String, String>();
        
        Set<String> openVisitStatusValues = new Set<String>();
        openVisitStatusValues.add(GlobalConstants.VISIT_STATUS_NOT_STARTED);
        openVisitStatusValues.add(GlobalConstants.VISIT_STATUS_IN_PROGRESS);
        
        Set<String> relatedAccounts = new Set<String>();
        
        List<AccountTeamMember> accountTeamMembersToDelete = new List<AccountTeamMember>();
        List<AccountShare> accountManualSharingToDelete = new List<AccountShare>();
               
        for(User tempAuditUser : tempAuditUsers) {
              
               auditUserIdVsAuditContactId.put(tempAuditUser.Id, tempAuditUser.Audit_Contact_Id__c);                          
        }
        
        System.debug('Map Formed: '+auditUserIdVsAuditContactId);
        
        for(Case tempCase : newCases.values()) {
          
          if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
              && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
              && tempCase.Status != oldCases.get(tempCase.Id).Status
              && tempCase.AccountId != NULL) {
              
              relatedAccounts.add(tempCase.AccountId);
          }
        }
        
        if(!relatedAccounts.isEmpty()){
            for(ArxxusRFMv1__Visit__c tempVisit : [SELECT ArxxusRFMv1__Store__c, ArxxusRFMv1__Status__c, Audit_Case__c,
                                                    Audit_Case__r.Lead_Auditor__c, Audit_Case__r.AccountId
                                                    FROM ArxxusRFMv1__Visit__c
                                                    WHERE ArxxusRFMv1__Status__c IN :openVisitStatusValues
                                                    AND Audit_Case__c NOT IN :newCases.keySet()
                                                    AND ArxxusRFMv1__Store__c IN :relatedAccounts]) {
              
                caseAndAuditorIdVsVisit.put(tempVisit.Audit_Case__r.AccountId+'-'+tempVisit.Audit_Case__r.Lead_Auditor__c, tempVisit);
            }
            
            System.debug('Map Formed: '+caseAndAuditorIdVsVisit);
            
            for(AccountTeamMember accTeamMember: [SELECT Id, AccountId, UserId, TeamMemberRole 
                                                   FROM AccountTeamMember 
                                                   WHERE AccountId IN :relatedAccounts  
                                                   AND TeamMemberRole = :GlobalConstants.TEAM_ACCOUNT_AUDITOR_ROLE_NAME]) {
                
                System.debug('AccountId: '+accTeamMember.AccountId);
                System.debug('UserId: '+accTeamMember.UserId);
                System.debug('ContactId: '+auditUserIdVsAuditContactId.get(accTeamMember.UserId));
                
                //check if no open visit exists for related lead auditor for same account 
                if(!caseAndAuditorIdVsVisit.containsKey(accTeamMember.AccountId+'-'+auditUserIdVsAuditContactId.get(accTeamMember.UserId)))
                  accountTeamMembersToDelete.add(accTeamMember);                                   
            }
            
            
            for(AccountShare tempAccShare : [SELECT AccountId, UserOrGroupId, AccountAccessLevel
                                             FROM AccountShare
                                             WHERE AccountId IN :relatedAccounts
                                             AND UserOrGroupId IN :auditUserIdVsAuditContactId.keySet()]) {
                 
                //check if no open visit exists for related lead auditor for same account 
                if(!caseAndAuditorIdVsVisit.containsKey(tempAccShare.AccountId+'-'+auditUserIdVsAuditContactId.get(tempAccShare.UserOrGroupId)))
                  accountManualSharingToDelete.add(tempAccShare);                                   
            }
             
            System.debug('Manual Sharing List Formed: '+accountManualSharingToDelete);
            
            Database.DeleteResult[] sr;
            
            
            if(accountManualSharingToDelete.size() > 0)
              sr = Database.delete(accountManualSharingToDelete, FALSE);
            
            System.debug('Manual Sharing Deletion Result: '+sr);
            
            if(accountTeamMembersToDelete.size() > 0)
              Database.delete(accountTeamMembersToDelete, FALSE);   
        }       
        
    }
*/
}