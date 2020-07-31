/*
 * Helper class to detect if agent agreement case 
 * is approved or rejected and then accordingly create agent
 * authorisation record for respective authorisation record
 */
public without sharing class RevokeAgreementCaseApprovalProcessor {

    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public RevokeAgreementCaseApprovalProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
     
        this.newCases = newCases;
        this.oldCases = oldCases;
    } 
    
    public void processApprovedAgentRevokeAgreementCases() {    
       
     try {
        
        Map<String, Case> approvedAgentRevokeAgreementCaseIdVsCase = new Map<String, Case>();
        Map<String, Related_Contact__c> licenceNumberVsRelatedContact = new Map<String, Related_Contact__c>();
        Map<String, Authorisation__c> licenceNumberVsAuthorisation = new Map<String, Authorisation__c>();
        
        List<Authorisation_Agent__c> existingAuthAgents = new List<Authorisation_Agent__c>();
        List<Authorisation_Agent__c> authAgentsToInsert = new List<Authorisation_Agent__c>();
        List<Authorisation__c> existingLicencesToUpdate = new List<Authorisation__c>();
        
        for(Case tempCase : newCases.values()) {
       
         if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE_DEV_NAME
               && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
               && tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS
               && tempCase.Sub_Status__c != oldCases.get(tempCase.Id).Sub_Status__c
               && tempCase.Sub_Type__c == GlobalConstants.REVOKE_AGREEMENT_CASE_SUB_TYPE) {
              
               approvedAgentRevokeAgreementCaseIdVsCase.put(tempCase.Id, tempCase);
         }
        }
        
        System.debug('Agent Revoke Agreement Cases: '+approvedAgentRevokeAgreementCaseIdVsCase.size());
       
        if(approvedAgentRevokeAgreementCaseIdVsCase.size() == 0)
           return;  
        
         for(Related_Contact__c tempRelatedContact : [SELECT Name, Taxi_Licence__c, Plate_Number__c, Related_Application__c
                                                      FROM Related_Contact__c
                                                      WHERE Related_Application__c IN :approvedAgentRevokeAgreementCaseIdVsCase.keySet()]) {
                  
              licenceNumberVsRelatedContact.put(tempRelatedContact.Taxi_Licence__c, tempRelatedContact);
        }
        
        for(Authorisation__c tempAuth : [SELECT Name, Agency__c, Agreement_Type__c, Status__c
                                          FROM Authorisation__c
                                          WHERE Name IN :licenceNumberVsRelatedContact.keySet()
                                          AND Status__c = :GlobalConstants.TAXI_LICENCE_GRANTED_STATUS]) {
              
              licenceNumberVsAuthorisation.put(tempAuth.Name, tempAuth);          
        }
        
        //fetching exsting authorisation agent records and marking them as inactive        
        for(Authorisation_Agent__c tempAuthAgent : [SELECT Status__c, Authorisation__c, Authorisation__r.Name
                                                     FROM Authorisation_Agent__c
                                                     WHERE Status__c = :GlobalConstants.STATUS_ACTIVE
                                                     AND Authorisation__r.Name IN :licenceNumberVsAuthorisation.keySet()]) {
              
              tempAuthAgent.Status__c = GlobalConstants.AUDITOR_STATUS_INACTIVE;
              existingAuthAgents.add(tempAuthAgent);                                             
        }
             
        List<Database.SaveResult> sr;
                                  
        if(existingAuthAgents.size() > 0)
          sr = Database.update(existingAuthAgents, FALSE);
          
        System.debug('Authorisation Agent Revoke List Result: '+sr);
      }
      catch(Exception ex) {
        
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'RevokeAgreementCaseApprovalProcessor','processApprovedAgentRevokeAgreementCases',ex.getMessage(),ex);                        
      }
    }
}