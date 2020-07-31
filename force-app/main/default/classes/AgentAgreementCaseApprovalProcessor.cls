/*
 * Helper class to detect if agent agreement case 
 * is approved or rejected and then accordingly create agent
 * authorisation record for respective authorisation record
 */
public without sharing class AgentAgreementCaseApprovalProcessor {

    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public AgentAgreementCaseApprovalProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
     
        this.newCases = newCases;
        this.oldCases = oldCases;
    } 
    
    public void processApprovedAgentAgreementCases() {    
       
     try {
        
        Map<String, Case> approvedAgentAgreementCaseIdVsCase = new Map<String, Case>();
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
               && tempCase.Sub_Type__c == GlobalConstants.AGENT_LICENCE_AGREEMENT_SUB_TYPE) {
              
               approvedAgentAgreementCaseIdVsCase.put(tempCase.Id, tempCase);
         }
        }
        
        System.debug('Agent Licence Agreement Cases: '+approvedAgentAgreementCaseIdVsCase.size());
       
        if(approvedAgentAgreementCaseIdVsCase.size() == 0)
           return;  
           
        for(Related_Contact__c tempRelatedContact : [SELECT Name, Taxi_Licence__c, Plate_Number__c, Related_Application__c
                                                      FROM Related_Contact__c
                                                      WHERE Related_Application__c IN :approvedAgentAgreementCaseIdVsCase.keySet()]) {
                  
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
                                       
        if(existingAuthAgents.size() > 0)
          Database.update(existingAuthAgents, FALSE);
          
        
        for(String tempLicenceNumber : licenceNumberVsRelatedContact.keySet()) {
          
          Related_Contact__c tempRelatedContact = licenceNumberVsRelatedContact.get(tempLicenceNumber);
          
          Authorisation_Agent__c tempAuthAgent = new Authorisation_Agent__c();
          tempAuthAgent.Account__c = approvedAgentAgreementCaseIdVsCase.get(tempRelatedContact.Related_Application__c).AccountId;
          tempAuthAgent.Status__c = GlobalConstants.STATUS_ACTIVE;
          tempAuthAgent.Agreement_Type__c = approvedAgentAgreementCaseIdVsCase.get(tempRelatedContact.Related_Application__c).Agreement_Type__c;
          tempAuthAgent.Expiry_Date__c = approvedAgentAgreementCaseIdVsCase.get(tempRelatedContact.Related_Application__c).Expiry_Date__c;
          tempAuthAgent.Approved_Date__c = System.Today();
          tempAuthAgent.Authorisation__c = licenceNumberVsAuthorisation.get(tempRelatedContact.Taxi_Licence__c).Id;
                    
          authAgentsToInsert.add(tempAuthAgent);
          
          Authorisation__c tempAuth = new Authorisation__c();
          tempAuth.Id = licenceNumberVsAuthorisation.get(tempRelatedContact.Taxi_Licence__c).Id;
          tempAuth.Agency__c = approvedAgentAgreementCaseIdVsCase.get(tempRelatedContact.Related_Application__c).AccountId;
          tempAuth.Agreement_Type__c = approvedAgentAgreementCaseIdVsCase.get(tempRelatedContact.Related_Application__c).Agreement_Type__c;
          
          existingLicencesToUpdate.add(tempAuth);
        }
        
        
        List<Database.SaveResult> sr;
        List<Database.SaveResult> newAuthAgentsInsertResult;
        List<Database.SaveResult> existingAuthUpdateResult;
        
        if(existingAuthAgents.size() > 0)
          sr = Database.insert(existingAuthAgents, FALSE);
        
        if(authAgentsToInsert.size() > 0)
          newAuthAgentsInsertResult = Database.insert(authAgentsToInsert, FALSE);
        
        if(existingLicencesToUpdate.size() > 0)
          existingAuthUpdateResult = Database.update(existingLicencesToUpdate, FALSE);
        
        System.debug('Authorisation Agent Insertion List Result: '+sr);
        System.debug('Authorisation Update List Result: '+existingLicencesToUpdate);
     }
     catch(Exception ex) {
        
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AgentAgreementCaseApprovalProcessor','processApprovedAgentAgreementCases',ex.getMessage(),ex);                        
     }
    }
}