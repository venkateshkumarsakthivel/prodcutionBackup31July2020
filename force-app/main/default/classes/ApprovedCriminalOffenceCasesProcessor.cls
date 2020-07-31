/*
 * calling from case trigger
 * if all child cases are approved then change sub status of parent case and assign the case to serviceDeliveryQueue
 */

public class ApprovedCriminalOffenceCasesProcessor {
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public ApprovedCriminalOffenceCasesProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
    }
    
    public void processApprovedCases() {
        
        try {
            //for storing parent case id of approved cases of type Criminal_Offence
            Set<Id> approvedCaseParentIds = new Set<Id>();
            
            for(Case newCase : newCases.values()) {
                
                //if case is closed and approved
                if( newCase.Record_Type_Dev_Name__c == GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_DEV_NAME 
                   && newCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && newCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS
                   && newCase.Status != oldCases.get(newCase.Id).Status
                   && newCase.Sub_Status__c != oldCases.get(newCase.Id).Sub_Status__c) {
                       
                       approvedCaseParentIds.add(newCase.ParentId);
                   }
            }
            
            if(approvedCaseParentIds.size() > 0) {
                
                List<Case> parentCasesToUpdate = new List<Case>();
                
                Map<Id,Case> parentCaseIdVsParentCase = new Map<Id,Case>();
                Map<Id,List<Case>> parentCaseIdVsChildCases = new Map<Id,List<Case>>();
                
                Id serviceDeliveryQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Service_Delivery'].Id;
                
                //create map of Parent Case id vs Parent Case
                for(Case parent : [SELECT Id, Sub_Status__c FROM Case WHERE Id IN :approvedCaseParentIds]) {
                    
                    parentCaseIdVsParentCase.put(parent.id, parent);
                }
                
                //Create map of Parent Case Id vs List of all child cases of type Criminal_Offence
                for(Case child : [SELECT Id, Status, Sub_Status__c, ParentId 
                                  FROM Case
                                  WHERE ParentId IN :parentCaseIdVsParentCase.keySet()
                                  AND Record_Type_Dev_Name__c = :GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_DEV_NAME]) {
                                      
                                      if(parentCaseIdVsChildCases.containsKey(child.ParentId)) {
                                          parentCaseIdVsChildCases.get(child.ParentId).add(child);
                                      } else {
                                          parentCaseIdVsChildCases.put(child.ParentId, new List<Case>{child});
                                      }
                                  }
                
                //iterate over all parent case ids
                Boolean isAllCasesApproved;
                for(String parentId : parentCaseIdVsChildCases.keySet()) {
                    
                    isAllCasesApproved = true;
                    
                    //iterate over all child cases of parent and check whether all are approved or not
                    for(Case childCase : parentCaseIdVsChildCases.get(parentId)) {
                        
                        if(childCase.Status != GlobalConstants.CLOSED_CASE_STATUS
                           || childCase.Sub_Status__c != GlobalConstants.APPROVED_CASE_SUB_STATUS) {
                               
                               isAllCasesApproved = false;
                           }
                    }
                    
                    //if all child cases are approved then 
                    //change sub status of parent case and assign the case to serviceDeliveryQueue
                    if(isAllCasesApproved) {
                        
                        Case parentCase = parentCaseIdVsParentCase.get(parentId);
                        parentCase.Sub_Status__c = GlobalConstants.DECISION_COMPLETE_SUB_STATUS;
                        parentCase.OwnerId = serviceDeliveryQueueId;
                        parentCasesToUpdate.add(parentCase);
                    }
                }
                
                update parentCasesToUpdate;
            }
        }
        catch (Exception ex) {
            //Insert Application Log
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ApprovedCriminalOffenceCasesProcessor', 'processApprovedCases', ex.getMessage(), null, ex, null, null, null, null);
            
        }
    }
}