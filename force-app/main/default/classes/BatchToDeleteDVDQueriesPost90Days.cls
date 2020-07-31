//Batch Class to Delete DVD queries after 90 days of Cretaed Date.

global class BatchToDeleteDVDQueriesPost90Days implements Database.Batchable<sObject>{
    global String query;
    global static final String ERROR ='Error';//logging level
    global static final date SYSTEM_DATE = date.today().addMonths(-3);
    
    //Constructor
    global BatchToDeleteDVDQueriesPost90Days(){
        // Fetch DVD Queries records which are created before 90 days . 
        query = 'SELECT id FROM DVD_Query__c WHERE CreatedDate <= :SYSTEM_DATE';
        system.debug('Query '+query);
    } 
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<DVD_Query__c> scope){
        try{
            List<DVD_Query__c> DVDQueriesToDelete = new List<DVD_Query__c>();
            
            for(DVD_Query__c DVDQueryToDelete : scope){
                DVDQueriesToDelete.add(DVDQueryToDelete); 
            }
            
            if(DVDQueriesToDelete != null && DVDQueriesToDelete.size() > 0) {
                Database.delete(DVDQueriesToDelete, false);
            }
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchToDeleteDVDQueriesPost90Days','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    } 
}