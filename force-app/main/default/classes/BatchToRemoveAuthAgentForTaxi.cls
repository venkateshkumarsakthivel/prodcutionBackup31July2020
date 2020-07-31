//batch class for scheduler "SchedulerToRemoveAuthAgentForTaxi" to Remove Agency and Agreement Type for Authorisations of Trasferred Taxi Licence
global class BatchToRemoveAuthAgentForTaxi implements Database.Batchable<sObject>  {
    
    String query;

    global BatchToRemoveAuthAgentForTaxi(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Authorisation__c> authorisationList) {
        List<Authorisation__c> authorisationListToUpdate = new List<Authorisation__c>();
        for(Authorisation__c authRecord : authorisationList) {
            authRecord.Agency__c = null;
            authRecord.Agreement_Type__c = null;
            authorisationListToUpdate.add(authRecord);
        }
        if(authorisationListToUpdate != null && authorisationListToUpdate.size() > 0) {
            update authorisationListToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}