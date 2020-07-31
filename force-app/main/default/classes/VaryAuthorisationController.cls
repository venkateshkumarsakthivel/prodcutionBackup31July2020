/**
* Server side rest resource controller for Variation Action
*/
public with sharing class VaryAuthorisationController {
    
    //Function to create variation of provided authorisation record
    @AuraEnabled
    public static String varyAuthorisation(String authId, String decisionReason) { 
        
        try {
            
            //Id serviceProviderAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            //Id taxiAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Id variationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            Authorisation__c auth = [SELECT Id, Application__c, Service_Provider__c, Contact__c, 
                                     Record_Type_Dev_Name__c, (SELECT Id FROM Conditions__r)
                                     FROM Authorisation__c
                                     WHERE Id =:authId];
            
            String authAppId = auth.Application__c;
            
            Case newCase = new Case();
            newCase.RecordTypeId = variationRecordTypeId;
            
            //if authorisation is not related to Taxi
            if(auth.Record_Type_Dev_Name__c != GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME) {
                
              newCase.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
              newCase.Subject = GlobalConstants.VARIATION_AUTHORISATION_CASE_SUBJECT;
            }
            else {
              
              newCase.Type = GlobalConstants.CASE_TAXI_TYPE;
              newCase.Subject = GlobalConstants.VARIATION_AUTHORISATION_TAXI_CASE_SUBJECT;
            }
            
            
            newCase.AccountId = auth.Service_Provider__c;
            //newCase.ContactId = auth.Contact__c;
            newCase.Status = GlobalConstants.LODGED_CASE_STATUS;
            newCase.Sub_Status__c = GlobalConstants.ASSESSMENT_INPROGRESS;
            
            newCase.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_VARIATION;
            
            newCase.Date_Submitted__c = System.now();
            newCase.Decision_Reason__c = decisionReason;
            //newCase.Authorisation__c = authId;
            
            
            insert newCase;
            
            String soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c','id=\''+authId+'\'');    
            auth = (Authorisation__c)Database.query(soql);
            
            Authorisation__c variationAuthorisation = auth.clone(false, true, false, false);
            variationAuthorisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
            variationAuthorisation.Application__c = authAppId;
            variationAuthorisation.Related_Request_Case_Id__c = newCase.Id;
            variationAuthorisation.Variation_Auth_Id__c = authId;
            variationAuthorisation.Request_Type__c = GlobalConstants.VARIATION_REQUEST_TYPE;
            variationAuthorisation.Support_Process_Approval_Status__c = '';
            variationAuthorisation.Decision_Date__c = System.Today();
            variationAuthorisation.Decision_Made_By__c = UserInfo.getUserId();
            variationAuthorisation.Decision_Reason__c = decisionReason;
            variationAuthorisation.OwnerId = UserInfo.getUserId();
            variationAuthorisation.ASP_Authorisation_Approved__c = false;
            variationAuthorisation.Current_Support_Request__c = newCase.Id;
            
            insert variationAuthorisation;
            
            newCase.Authorisation__c = variationAuthorisation.Id;
            
            update newCase;
            
            soql = GlobalUtility.getCreatableFieldsSOQL('Condition__c','Authority__c=\''+authId+'\'');  
            List<Condition__c> targetConditions = (List<Condition__c>)Database.query(soql);
            List<Condition__c> clonedConditions = new List<Condition__c>();
            for(Condition__c tempCondition : targetConditions) {
                
                Condition__c clonedCondition = tempCondition.clone(false, true);
                clonedCondition.Authority__c = variationAuthorisation.Id;
                clonedConditions.add(clonedCondition);
            }
            
            if(clonedConditions.size() > 0)
                insert clonedConditions;
            
            newCase = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id];
            
            system.debug('CaseNumber is: '+newCase.CaseNumber+'-'+variationAuthorisation.Id);
            return newCase.CaseNumber+':'+newCase.Id;
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationController','varyAuthorisation',ex.getMessage(),ex);
            return null;
        } 
    }
    
    
    /*Function that validates if authorisation record should be allowed
      for variation or not.
    */
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) { 
        try{
            
            Authorisation__c tempAuth = [SELECT Status__c,Authorisation_Type__c FROM Authorisation__c
                                         WHERE Id = :authId];
            String authType = '';
            if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE) {
                authType = 'Taxi';
                
                if(tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED 
                   || tempAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED 
                   || tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS
                   || tempAuth.Status__c == GlobalConstants.SURRENDERED_AUTHORISATION_STATUS) {
                    	return 'SUCCESS';
                   }
            } else {
                 authType = 'Auth';

                 if(tempAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                   || tempAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY
                   || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED
                   || tempAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                   || tempAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_REFUSED) {
                     	return 'SUCCESS';
                    }
            }
            
            return authType; 
        }  catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationController','validateAuthorisationRecord',ex.getMessage(),ex);
            return null;
        }
    }
}