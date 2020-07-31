/*
* calling from case trigger
* Criminal offence investigation case will only closed if all criminal offence(child) cases are closed.
*/
public class COInvestigationCloseCaseProcessor {
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public COInvestigationCloseCaseProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
    }
    
    public void processClosedCases() {
        
        try {
            SET<String> coInvestigationCaseIds = new SET<String>();
            
            for(Case newCase : newCases.values()) {
                
                //if Criminal Offence Investigation case is closed
                if( newCase.Record_Type_Dev_Name__c == GlobalConstants.Criminal_Offence_Investigation_CASE_RECORD_TYPE_DEV_NAME 
                   && newCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && newCase.Status != oldCases.get(newCase.Id).Status) {
                       
                       coInvestigationCaseIds.add(newCase.Id);
                   }
            }
            
            if(coInvestigationCaseIds.size() == 0)
                return;
            
            Map<Id,List<Case>> parentCaseIdVsChildCases = new Map<Id,List<Case>>();
            
            //Create map of Parent Case Id vs List of all child cases of type Criminal_Offence
            for(Case child : [SELECT Id, Status, Sub_Status__c, ParentId 
                              FROM Case
                              WHERE ParentId IN :coInvestigationCaseIds
                              AND Record_Type_Dev_Name__c = :GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_DEV_NAME]) {
                                  
                                  if(parentCaseIdVsChildCases.containsKey(child.ParentId)) {
                                      parentCaseIdVsChildCases.get(child.ParentId).add(child);
                                  } else {
                                      parentCaseIdVsChildCases.put(child.ParentId, new List<Case>{child});
                                  }
                              }
            
            Boolean isAllCasesClosed;
            for(String parentId : parentCaseIdVsChildCases.keySet()) {
                
                isAllCasesClosed = true;
                
                //iterate over all child cases of parent and check whether all are CLOSED
                for(Case childCase : parentCaseIdVsChildCases.get(parentId)) {
                    
                    if(childCase.Status != GlobalConstants.CLOSED_CASE_STATUS)
                        isAllCasesClosed = false;
                }
                
                //if all child cases are not closed then
                if(!isAllCasesClosed) {
                     this.newCases.get(parentId).addError('Cannot close the case as one or more criminal charge cases are still open');
                }
            }
        }
        catch (Exception ex) {
            //Insert Application Log
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'COInvestigationCloseCaseProcessor', 'processClosedCases', ex.getMessage(), null, ex, null, null, null, null);
        }
    }
}