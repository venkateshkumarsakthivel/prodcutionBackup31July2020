/**
 * Description: Tax Payer Registration trigger handler class
*/
public class TaxPayerRegistrationTriggerHandler {

    //before insert handler
    public static void beforeInsert(List<Tax_Payer_Registration__c> newRegistrations){
        
        TSPBSPRegistrationAssociator authorisationAssociator = new TSPBSPRegistrationAssociator(newRegistrations);
        authorisationAssociator.associateRelatedAuthorisations();
    }
    
    //before update handler
    public static void beforeUpdate(Map<Id, Tax_Payer_Registration__c> newRegistrations, Map<Id, Tax_Payer_Registration__c> oldRegistrations) {
      
        ExemptionRebateApprovalHelper exemptionRebateApprovalHandler = new ExemptionRebateApprovalHelper(newRegistrations, oldRegistrations);
        exemptionRebateApprovalHandler.processApprovalRejectionActions();
        
        RegIntegrationRelatedUpdateIdentifier validateRegistrationUpdate = new RegIntegrationRelatedUpdateIdentifier(newRegistrations, oldRegistrations);
        validateRegistrationUpdate.validateIntegrationUpdates();
    }
}