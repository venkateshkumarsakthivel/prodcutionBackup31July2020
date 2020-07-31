//batch class for scheduler "SchedulerToInactiveAuthorisationAgent" to update Authorisation_Agent__c records "Staus" as "Inactive"
global class BatchToInactiveAuthorisationAgent implements Database.Batchable<sObject>  {
	
	String query;

	global BatchToInactiveAuthorisationAgent(String query) {
		this.query = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query) ;
	}

   	global void execute(Database.BatchableContext BC, List<Authorisation_Agent__c> authorisationAgentList) {
        List<Authorisation_Agent__c> authorisationAgentToUpdateList = new List<Authorisation_Agent__c>();
        for(Authorisation_Agent__c authAgentRecord : authorisationAgentList) {
            authAgentRecord.Status__c = 'Inactive';
            authorisationAgentToUpdateList.add(authAgentRecord);
        }
        if(authorisationAgentToUpdateList != null && authorisationAgentToUpdateList.size() > 0) {
            update authorisationAgentToUpdateList;
        }
	}
	
	global void finish(Database.BatchableContext BC) {		
	}
	
}