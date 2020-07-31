global class BatchForApplicationExpirationPost90Days implements Database.Batchable<sObject>{
    global final String Query;
    
    
    public static final String CASE_RECORD_TYPE_DEV_NAME_TAXI= 'Taxi';
    public static final String ASP_CORPORATION_CASE_RECORD_TYPE_DEV_NAME = 'Corporation_Application';
    public static final String ASP_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME = 'Individual_Application';
    public static final String ASP_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME = 'Partnership_Application';
    public static final String CLOSED_CASE_STATUS = 'Closed';
    public static final String EXPIRED_CASE_SUB_STATUS = 'Expired';
    public static final String ERROR ='Error';//logging level
    Public Static final Application_Expiration_Post_XDays_Config__mdt postXDaysConfig= [Select id, X_Days__c, DeveloperName From Application_Expiration_Post_XDays_Config__mdt Where DeveloperName = 'Post_XDays'];
    //Constructor
    global BatchForApplicationExpirationPost90Days(){
        try{ // Fetch Application records with Case Age, Existing status and Record type. 
            Query = 'SELECT Id, Status, IsStopped, Case_Age__c, Record_Type_Dev_Name__c FROM Case WHERE Case_Age__c >='+ postXDaysConfig.X_Days__c;
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchForApplicationExpirationPost90Days','BatchForApplicationExpirationPost90Days',ex.getMessage(),ex);
        }
        
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> CaseRecordsToUpdate = new List<Case>();
        
        try{
            String CA = ASP_CORPORATION_CASE_RECORD_TYPE_DEV_NAME;
            String IA = ASP_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME;
            String PA = ASP_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME;
            String Taxi = CASE_RECORD_TYPE_DEV_NAME_TAXI;
            
            for(Case CaseRec : scope){
                if((CaseRec.Case_Age__c >= postXDaysConfig.X_Days__c) && ((CaseRec.Record_Type_Dev_Name__c == CA) || (CaseRec.Record_Type_Dev_Name__c == IA) || (CaseRec.Record_Type_Dev_Name__c == PA) || CaseRec.Record_Type_Dev_Name__c.contains(Taxi))){
                    CaseRec.Status = CLOSED_CASE_STATUS;
                    CaseRec.Sub_Status__c = EXPIRED_CASE_SUB_STATUS;
                    CaseRec.IsStopped = true;
                    CaseRecordsToUpdate.add(CaseRec);
                }
            }
            update CaseRecordsToUpdate;
            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'BatchForApplicationExpirationPost90Days','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    }
}