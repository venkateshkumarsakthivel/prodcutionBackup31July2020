public class AuditCaseAssignedReviewerPostApproval {
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    Map<String, List<Case>> contactIdVsCases;
    
    public AuditCaseAssignedReviewerPostApproval(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
        this.contactIdVsCases = new Map<String, List<Case>>(); 
    }  
    
    public void updateCaseOwnertoAssignedReviewer(){
        //Updated references for Assigned_Reviewer__c → Audit_Reviewer__c as per new requirements
        try {
            for(Case tempCase : newCases.values()) {
                // Check is Case is Approved
                if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT 
                    && tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS 
                    && (tempCase.Sub_Status__c == GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING || tempCase.Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_REPORT_APPROVAL)
                    && (oldCases.get(tempCase.Id).Sub_Status__c != GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING && oldCases.get(tempCase.Id).Sub_Status__c != GlobalConstants.CASE_SUB_STATUS_REPORT_APPROVAL))) {
                        
                        if(contactIdVsCases.containsKey(tempCase.Audit_Reviewer__c)){
                            
                            contactIdVsCases.get(tempCase.Audit_Reviewer__c).add(tempCase);
                        }else{
                            
                            contactIdVsCases.put(tempCase.Audit_Reviewer__c, new List<Case>{tempCase});
                        }
                        
                    }
                else if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT 
                        && tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS
                        && tempCase.Audit_Case_Rejected__c == true 
                        && oldCases.get(tempCase.Id).Audit_Case_Rejected__c == false) {
                            
                            // Check is Case is Rejected
                            
                            if(contactIdVsCases.containsKey(tempCase.Audit_Reviewer__c)){
                                
                                contactIdVsCases.get(tempCase.Audit_Reviewer__c).add(tempCase);
                            }else{
                                
                                contactIdVsCases.put(tempCase.Audit_Reviewer__c, new List<Case>{tempCase});
                            }
                            
                        }
            }
            /*
            if(!contactIdVsCases.isEmpty()){
                List<Contact> getAssignedReviewerContacts = [SELECT id, Audit_User__c FROM Contact WHERE Id IN: contactIdVsCases.keySet() AND Audit_User__c  != null]; 
                for(Contact assignedReviewer : getAssignedReviewerContacts){
                    List<Case> cases = contactIdVsCases.get(assignedReviewer.Id);
                    for(Case updateCase : cases){
                        updateCase.OwnerId = assignedReviewer.Audit_User__c;
                        
                        //if(updateCase.Audit_Case_Rejected__c) {
                        //    updateCase.Audit_Case_Rejected__c = false;
                        //}
                    }
                }
                
            }*/
            //Assigning Audit Reviewer as the Owner 
            if(!contactIdVsCases.isEmpty()){
                for(String auditReviewer :contactIdVsCases.keySet()){
                    List<Case> cases = contactIdVsCases.get(auditReviewer);
                    for(Case updateCase : cases){
                        updateCase.OwnerId = auditReviewer;
                    }
                }
            }
            
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseAssignedReviewerPostApproval','updateCaseOwnertoAssignedReviewer',ex.getMessage(),ex);                        
        }
    }
}