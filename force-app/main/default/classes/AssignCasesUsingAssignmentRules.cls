/*
* Invocable class for running assignment rule using process builder
*/
public without sharing class AssignCasesUsingAssignmentRules {
    
    @InvocableMethod
    public static void runCaseAssignmentRules(List<Id> caseIds) {
        
        //record reassignment can not be done from trigger/process builder directly in
        //same transaction. Hence a future method call needs to be made
        if(!System.isBatch() && !System.isFuture())
         triggerCaseAssignmentRules(caseIds);
    }
    
    @future 
    public static void triggerCaseAssignmentRules(List<Id> caseIds) {
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        //dmo.assignmentRuleHeader.assignmentRuleId= '01QO0000000Eje0';    
        dmo.assignmentRuleHeader.useDefaultRule= true;
        
        System.debug('Case Ids ' + caseIds);
        
        List<Case> cases = [Select Id, Status, OwnerId FROM Case WHERE Id IN :caseIds];
        List<Case> casesToUpdate = new List<Case>();
        
        for(Case tempCase : cases) {
            
            tempCase.setOptions(dmo);
            casesToUpdate.add(tempCase);
        }
        
        update casesToUpdate;
        
        List<Case> caseRecList = [Select Id, Status, OwnerId FROM Case WHERE Id in :caseIds];
        
        System.debug('Case List: '+caseRecList);
    }
}