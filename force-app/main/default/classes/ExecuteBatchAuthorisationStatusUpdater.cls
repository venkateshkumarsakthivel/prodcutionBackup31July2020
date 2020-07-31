/* Batch class for updating authorisations which are in already in approval process.
* 
*
*/

global class ExecuteBatchAuthorisationStatusUpdater implements Database.Batchable<sObject>{
    
    global final String Query;
    public static final String ERROR ='Error';//logging level
    public static final String AUTHORISATION_STATUS_CANCELLED = 'Cancelled';
    public static final String AUTHORISATION_STATUS_DISCARDED = 'Discarded';
    public static final String AUTHORISATION_DECISION_REASON = 'Voluntary withdraw by applicant';
    
    global ExecuteBatchAuthorisationStatusUpdater(){
        try{
            // Fetch those Authorisation records whose Application status is 'Withdrawn'. 
            Query = 'SELECT Id, Status__c,  Application__c, Application__r.Decision_Made_By__c, Application__r.Parent.Record_type_dev_name__c FROM Authorisation__c WHERE Application__r.Sub_Status__c  = \'Withdrawn\' AND Status__c != \'Cancelled\' AND Status__c != \'Discarded\'';
            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(ERROR,'ExecuteBatchAuthorisationStatusUpdater','ExecuteBatchAuthorisationStatusUpdater',ex.getMessage(),ex);  
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator authList = Database.getQueryLocator(Query);
        system.debug('authList :'+authList);
        return authList;
    }
    
    global void execute(Database.BatchableContext BC, List<Authorisation__c> scope){
        
        try{
            List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
            String CurrentDatetring = system.today().format();
            Date currentDate = date.parse(CurrentDatetring);
            for(Authorisation__c authRec : scope){
                if(authRec.Status__c != AUTHORISATION_STATUS_CANCELLED && authRec.Status__c != AUTHORISATION_STATUS_DISCARDED){
                    if(authRec.Application__r.Parent != null && authRec.Application__r.Parent.Record_type_dev_name__c == 'Tender'){
                        authRec.Status__c = AUTHORISATION_STATUS_DISCARDED;
                    }else{
                    authRec.Status__c = AUTHORISATION_STATUS_CANCELLED;
                    }
                    authRec.Decision_Reason__c = AUTHORISATION_DECISION_REASON;
                    authRec.Decision_Date__c = currentDate;
                    authRec.Decision_Made_By__c = authRec.Application__r.Decision_Made_By__c;
                    authRecordsToUpdate.add(authRec);
                }
            }
            update authRecordsToUpdate;
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'ExecuteBatchAuthorisationStatusUpdater','execute',ex.getMessage(),ex);  
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}