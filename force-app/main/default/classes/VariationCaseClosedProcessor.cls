/*
 * Helper class to detect if it was last active authorisation and if yes then
 * revoke DVD access of all related authorisation contacts
 */
public with sharing class VariationCaseClosedProcessor {

    private Map<Id, Case> newApplications;
    private Map<Id, Case> oldApplications;
    private static final Set<Id> aspRecordTypes;
    
    static {
        
        aspRecordTypes = GlobalUtility.retrieveASPApplicationRecordTypes();
    }
    
    public VariationCaseClosedProcessor(Map<Id, Case> newApplications, Map<Id, Case> oldApplications){
    
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    public void processClosedVariationCases() {    
    
      try {
        
        Map<Id, Case> approvedVaritionRequests = new Map<Id, Case>();
        Map<Id, Case> rejectedVaritionRequests = new Map<Id, Case>();
        Set<Id> relatedVariationAuthorisations = new Set<Id>();
        
        System.debug('In Variation Processor');
        
        for(Case tempCase : newApplications.values()) {
         
         //authorisation variation request approved
         if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_DEV_NAME
              && (tempCase.Type == GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
                  || tempCase.Type == GlobalConstants.CASE_TAXI_TYPE)
              && tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_VARIATION
              && (tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS)
              && tempCase.Authorisation__c != NULL
              && tempCase.AccountId != NULL) {
              
              System.debug('In Variation Processor Case Found: '+tempCase.Id);
              approvedVaritionRequests.put(tempCase.Id, tempCase);
              relatedVariationAuthorisations.add(tempCase.Authorisation__c);     
         }
         
         
         //authorisation variation request rejected
         if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_DEV_NAME
              && (tempCase.Type == GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
                  || tempCase.Type == GlobalConstants.CASE_TAXI_TYPE)
              && tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_VARIATION
              && (tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && tempCase.Sub_Status__c == GlobalConstants.DECLINED_CASE_SUB_STATUS)
              && tempCase.Authorisation__c != NULL
              && tempCase.AccountId != NULL) {
              
              System.debug('In Variation Processor Rejection Case Found: '+tempCase.Id);
              rejectedVaritionRequests.put(tempCase.Id, tempCase);
              relatedVariationAuthorisations.add(tempCase.Authorisation__c);              
         }
         
        }
        
        System.debug('In Variation Flow: '+approvedVaritionRequests);
        System.debug('In Variation Flow: '+rejectedVaritionRequests);
        
        if(!approvedVaritionRequests.isEmpty() || !rejectedVaritionRequests.isEmpty()) {
         
          List<Authorisation__c> relatedVariationAuthorisationToUpdate = new List<Authorisation__c>();
          
          for(Authorisation__c relatedVariationAuthorisation : [SELECT Status__c, Application__c, Conditions_Count__c, 
                                                                   Variation_Auth_Id__c, Related_Request_Case_Id__c, 
                                                                   Record_Type_Dev_Name__c
                                                                   FROM Authorisation__c
                                                                   WHERE Id IN :relatedVariationAuthorisations]) {
              
               if(approvedVaritionRequests.containsKey(relatedVariationAuthorisation.Related_Request_Case_Id__c)) {
                
                if(relatedVariationAuthorisation.Record_Type_Dev_Name__c != GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME) {
                
                 if(relatedVariationAuthorisation.Conditions_Count__c > 0)
                   relatedVariationAuthorisation.Status__c = GlobalConstants.GRANTED_CONDITIONALLY;
                 else 
                   relatedVariationAuthorisation.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
                }
                else
                   relatedVariationAuthorisation.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
                 
                 relatedVariationAuthorisationToUpdate.add(relatedVariationAuthorisation);
                  
                 Authorisation__c authorisationToSuperseed = new Authorisation__c();
                 authorisationToSuperseed.Id = relatedVariationAuthorisation.Variation_Auth_Id__c;
                 authorisationToSuperseed.Status__c = GlobalConstants.SUPERSEEDED_AUTHORISATION_STATUS;
                 
                 relatedVariationAuthorisationToUpdate.add(authorisationToSuperseed);
               }     
               
               
               if(rejectedVaritionRequests.containsKey(relatedVariationAuthorisation.Related_Request_Case_Id__c)) {
                  
                   relatedVariationAuthorisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_DISCARDED;
                   relatedVariationAuthorisationToUpdate.add(relatedVariationAuthorisation);
               }                                            
          }
          
          if(relatedVariationAuthorisationToUpdate.size() > 0)
            update relatedVariationAuthorisationToUpdate;
        }
       
      }
     catch(Exception ex) {
                    ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VariationCaseClosedProcessor','processClosedVariationCases',ex.getMessage(),ex);
                                
                }
    }
}