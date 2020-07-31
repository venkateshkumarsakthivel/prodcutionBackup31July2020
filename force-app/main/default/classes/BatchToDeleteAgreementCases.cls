//batch class for scheduler "SchedulerToDeleteAgreementCases" to delete Agreement Case
global class BatchToDeleteAgreementCases implements Database.Batchable<sObject>  {
	
	String query;

	global BatchToDeleteAgreementCases(String query) {
		this.query = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}
    
   	global void execute(Database.BatchableContext BC, List<Case> caseList) {
        Integer numberOfHours = Integer.ValueOf(Label.Delete_Agreement_Case_After_N_Hours);
        List<Case> caseListToDelete = new List<Case>();
        for(Case caseRecord : caseList) {
            if(caseRecord.LastModifiedDate <= System.Now().addHours(-numberOfHours)) {
                caseListToDelete.add(caseRecord);
            }
        }
        if(caseListToDelete != null && caseListToDelete.size() > 0) {
            delete caseListToDelete;
        }
	}
	
	global void finish(Database.BatchableContext BC) {		
	}
	
}