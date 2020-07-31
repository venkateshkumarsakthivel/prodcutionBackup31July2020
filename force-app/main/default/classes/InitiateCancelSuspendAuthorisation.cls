/**
* Server side rest resource controller for Cancel/Suspend Action
*/
public without sharing class InitiateCancelSuspendAuthorisation {
    
    /*Function to create cancel/suspend support request for 
provided authorisation record
*/
    @AuraEnabled
    public static String submitSuspendCancelCaseRec(String authId, String authStatus, String decisionReason){
        
        try{
            
            //Id serviceProviderAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            //Id taxiAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Id cancelSuspendRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            Authorisation__c auth = [SELECT Id, Service_Provider__c, Contact__c, Record_Type_Dev_Name__c, Current_Support_Request__c 
                                     FROM Authorisation__c
                                     WHERE Id =:authId];
            system.debug('Authorisation: '+auth);
            
            Case newCase = new Case();
            newCase.RecordTypeId = cancelSuspendRecordTypeId;
            
            //if authorisation is not related to Taxi
            if(auth.Record_Type_Dev_Name__c != GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME) {
                
                newCase.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
                if(authStatus == 'Cancel') {
                    
                    newCase.Subject = GlobalConstants.ASP_CANCEL_AUTHORISATION_CASE_SUBJECT;  
                    auth.Request_Type__c = GlobalConstants.CANCEL_REQUEST_TYPE;
                }
                else{
                    
                    newCase.Subject = GlobalConstants.ASP_SUSPEND_AUTHORISATION_CASE_SUBJECT;
                    auth.Request_Type__c = GlobalConstants.SUSPEND_REQUEST_TYPE;
                }
            }
            else {
                
                newCase.Type = GlobalConstants.CASE_TAXI_TYPE;
                if(authStatus == 'Cancel') {
                    
                    newCase.Subject = GlobalConstants.TAXI_CANCEL_AUTHORISATION_CASE_SUBJECT;  
                    auth.Request_Type__c = GlobalConstants.CANCEL_REQUEST_TYPE;
                }
                else{
                    
                    newCase.Subject = GlobalConstants.TAXI_SUSPEND_AUTHORISATION_CASE_SUBJECT;
                    auth.Request_Type__c = GlobalConstants.SUSPEND_REQUEST_TYPE;
                }
            }
            
            //determine if request is made for cancel or suspend            
            
            newCase.AccountId = auth.Service_Provider__c;
            //newCase.ContactId = auth.Contact__c;
            newCase.Status = GlobalConstants.LODGED_CASE_STATUS;
            newCase.Sub_Status__c = GlobalConstants.ASSESSMENT_INPROGRESS;
            newCase.Sub_Type__c = authStatus; 
            newCase.Decision_Reason__c = decisionReason;
            newCase.Authorisation__c = authId;
            newCase.Date_Submitted__c = System.now();            
            
            insert newCase;
            
            auth.Related_Request_Case_Id__c = newCase.Id;
            auth.Current_Support_Request__c = newCase.Id;
            
            update auth;
            
            Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1];
            
            return caseRec.CaseNumber+':'+caseRec.Id;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InitiateCancelSuspendAuthorisation','submitSuspendCancelCaseRec',ex.getMessage(),ex);
            return null; 
        }
        
    }
    
    /*Function that validates if authorisation record should be allowed
for variation or not.
*/
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) { 
        try{
            
            Authorisation__c tempAuth = [SELECT Status__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            if(tempAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY 
               || tempAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY
               || tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS
               || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED)
                return 'SUCCESS';
            
            
            return 'ERROR'; 
        }  catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InitiateCancelSuspendAuthorisation','validateAuthorisationRecord',ex.getMessage(),ex);
            return null;
        }
    }
    
}