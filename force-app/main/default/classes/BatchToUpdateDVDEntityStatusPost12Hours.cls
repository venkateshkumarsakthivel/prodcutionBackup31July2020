//Batch Class to Update Fleet status to Error if DVD status is requested or Null After 12 hrs of DVD run.

global class BatchToUpdateDVDEntityStatusPost12Hours implements Database.Batchable<sObject>{
    global String query;
    global static final String ERROR ='Error';//logging level
    global static final Set<String> DVD_ENTITY_STATUSES = new Set<String>{'','Requested'};
    global static final datetime SYSTEM_DATE_TIME = System.now().addHours(-12);   
    //Constructor
    global BatchToUpdateDVDEntityStatusPost12Hours(){
        // Fetch DVD Entity records with status and Last Modified Date. 
        query = 'SELECT Id, DVD_Status__c, (SELECT id FROM DVD_Queries__r )FROM DVD_Entity__c WHERE DVD_Status__c IN : DVD_ENTITY_STATUSES AND LastModifiedDate <= :SYSTEM_DATE_TIME';
    } 
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<DVD_Entity__c> scope){
        try{
            final String STATUS_ERROR = 'Error';
            final String STATUS_BLANK = Null;
            final String STATUS_REQUESTED = 'Requested';
            
            List<DVD_Entity__c> FleetsToUpdate = new List<DVD_Entity__c>();
            
            for(DVD_Entity__c fleetRecord : scope){
                if(fleetRecord.DVD_Queries__r.size() >0){
                    if(fleetRecord.DVD_Status__c == STATUS_BLANK || fleetRecord.DVD_Status__c == STATUS_REQUESTED){
                        fleetRecord.DVD_Status__c = STATUS_ERROR;
                        FleetsToUpdate.add(fleetRecord);
                    }
                }
            }
            
            if(FleetsToUpdate != null && FleetsToUpdate.size() > 0) {
                Database.update(FleetsToUpdate, false);
            }
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchToUpdateDVDEntityStatusPost12Hours','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    } 
}