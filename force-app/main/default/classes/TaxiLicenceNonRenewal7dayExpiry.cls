/*
 * * * Created by : Srikanth Sunkara
 * Created Date: 20/11/2019 (JIRA- 224)
* Batch class to remind Non Renewal Case(set flag NonRenewal7dayExpiry__c = true) before 7 days of expiry date if its not closed
* This Batch runs run Daily.
* 
Test Class: TaxiLicenceNonRenewal7dayExpiryTest
*/ 
global class TaxiLicenceNonRenewal7dayExpiry implements Database.Batchable<sObject>{
	
    global final String Query;
   private static final String SUSPENDED_STATUS = GlobalConstants.AUTHORISATION_SUSPENDED;
    private static final String GRANTED_STATUS = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String TAXI_LICENCE = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    public static final String ERROR ='Error';//logging level
    public static final Set<String> AUTH_STATUSES = new Set<String>{'Granted','Suspended','Granted With Conditions','Granted Unconditionally'};
	
        global TaxiLicenceNonRenewal7dayExpiry() {
        Date dateGMT=System.Today()+7;  
        Datetime d1=Date.valueOf(dateGMT);
        string dateTimeFormat =d1.format('yyyy-MM-dd');
        
     
        Query = 'SELECT Id, End_Date__c, Service_Provider__c,Operating_Locations__c,Operation_Area__c,Authorisation_Type__c,' 
                        + 'Licence_Class__c, Licence_Type__c, Status__c, Licence_Fee__c '
                        + 'FROM Authorisation__c '
                        + 'WHERE (Status__c = :GRANTED_STATUS OR Status__c =:SUSPENDED_STATUS) '
                        + 'AND Authorisation_Type__c = :TAXI_LICENCE ' 
                        + 'AND End_Date__c ='+dateTimeFormat+ 
                        + 'AND Renewal_Requested__c = false '
                        + 'AND Licence_Type__c != NULL '
                + 'AND Renewal_Count_Remaining__c = 0';
        
        
    }
    
    //Start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC, List<Authorisation__c> scope){
        List<Case> caseRecordsToInsert = new List<Case>();
        List<Authorisation__c> updateAuthorisationList = new List<Authorisation__c>();
        try{
              
                Map<Id, Authorisation__c> licencesForExpiry = new Map<Id, Authorisation__c>();
               
                for(Authorisation__c auth : scope){
                   
                    licencesForExpiry.put(auth.Id, auth);
                }
             
                
                //check if open surrender case exist for a licence, do not create expiry case if surrender is in progress
                List<Case> openCaseRequests = [SELECT CaseNumber, Status, Authorisation__c
                                                    FROM Case 
                                                    WHERE IsClosed = TRUE
                                                        AND Authorisation__c IN :licencesForExpiry.keySet()
                                                        AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                                        AND (Sub_Type__c = :GlobalConstants.NONRENEWAL_TAXI_APPLICATION_SUBJECT
                                                                )];
                //Filter the closed cases
                for(Case surrenderCase : openCaseRequests){
                     licencesForExpiry.remove(surrenderCase.Authorisation__c);
                }

                //Fetching the assignment rules on case
                for(Authorisation__c authRec : licencesForExpiry.values()) {
                    system.debug('7 day expiry');
                  authRec.NonRenewal7dayExpiry__c = true;
                    updateAuthorisationList.add(authRec);
                    
                }
            if(updateAuthorisationList.Size() > 0)
                update updateAuthorisationList;
            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'TaxiLicenceNonRenewal7dayExpiry','execute',ex.getMessage(),ex);
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC){
        
    }
}