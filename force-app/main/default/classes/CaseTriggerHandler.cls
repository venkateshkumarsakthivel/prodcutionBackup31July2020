/**
*  Description: Case trigger handler class
*/
public with sharing class CaseTriggerHandler {
    
    //after update handler
    public static void afterUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        //create authorisation record for lodged applications
        AuthorisationApplicationQualifier qualifier = new AuthorisationApplicationQualifier(newCases.values(), oldCases);
        List<Case> qualifiedApplications = qualifier.retrieveQualifiedApplication();
        
        if(!qualifiedApplications.isEmpty()){
            AuthorisationCreator creator = new AuthorisationCreator(newCases.values());
            creator.create();
        }
        
        //This code was used to create contacts from Related Contacts when Authorisation is Granted.
        //This functionality is now implemented in class RelatedContactToAccountContactConversion.
        //post authorisation processing
        //PostAuthorisationProcessor postAuthProcessor = new PostAuthorisationProcessor(newCases, oldCases);
        //postAuthProcessor.process();
        
        //Create contact record when case of "service provider administration" is approved
        ContactCreatorforCaseTypeSPA contactCreator = new ContactCreatorforCaseTypeSPA(newCases.values());
        
        // Added as part of Relase 1.1
        // Deactivate contact record when case of  -
        // type "Service Provider Administration" and Maintain Request Type 'Deactivate Contact' is approved
        ContactDeactivatorforCaseTypeSPA contactDeactivator = new ContactDeactivatorforCaseTypeSPA(newCases.values());
        
        // Added as part of Relase 1.1
        // Update contact record when case of  -
        // type "Service Provider Administration" and Maintain Request Type 'Edit Contact' is approved
        ContactUpdatorforCaseTypeSPA contactUpdator = new ContactUpdatorforCaseTypeSPA(newCases.values());
       //  hot fix start.. field ko licenses have been disabled 
        //Audit Case Trigger Handlers
       //AuditCaseApprovalProcessor processAuditCases = new AuditCaseApprovalProcessor(newCases, oldCases);
        //processAuditCases.processApprovedAuditCases();
        
        //RemoveAuditorTeamRole removeAuditorRolefromAccount = new RemoveAuditorTeamRole(newCases, oldCases);
        
        //AuditCaseLockUnlockProcessor auditCaseLockUnlock = new AuditCaseLockUnlockProcessor(newCases, oldCases);
        //auditCaseLockUnlock.processAuditCasesLockUnlock();
        
        //AuditCaseLeadAuditorHandler leadAuditorHandler = new AuditCaseLeadAuditorHandler(newCases, oldCases);
        //leadAuditorHandler.updateLeadAuditors();
        
       // AuditCaseEmailPDFProcessorTrigger auditCaseEmailPDFProcessorTrigger = new AuditCaseEmailPDFProcessorTrigger(newCases, oldCases);
        //auditCaseEmailPDFProcessorTrigger.sendAuditCaseReportEmailonVisitCompletion();
         //  hot fix end .. field ko licenses have been disabled
        
        //Code commented as per AUD-636 (automated email functionality for audit case closure is disabled.
        //AuditCaseSendCloserReport auditCaseSendCloserReport = new AuditCaseSendCloserReport(newCases, oldCases);
        //auditCaseSendCloserReport.sendAuditCaseSendCloserReport();
        
        //processor to make RMS callout for approved criminal offence cases with decision as overturn
        OverturnCriminalOffenceApprovalProcessor overturnCaseProcessor = new OverturnCriminalOffenceApprovalProcessor(newCases, oldCases);
        overturnCaseProcessor.processCriminalOffenceCases();
        
        //all child cases are approved then change sub status of parent case and assign the case to dataExchangeQueue
        ApprovedCriminalOffenceCasesProcessor criminalOffenceCasesProcessor = new ApprovedCriminalOffenceCasesProcessor(newCases, oldCases);
        criminalOffenceCasesProcessor.processApprovedCases();
        
        //NoticeRecordAuditActionCase noticeRecordAuditActionCase = new NoticeRecordAuditActionCase(newCases, oldCases);
        //noticeRecordAuditActionCase.checkIsRelatedCaseApprovedOnNCRecord();
        
        ApprovedWATApplicationProcessor watProcessor = new ApprovedWATApplicationProcessor(oldCases, newCases);
        watProcessor.process();
        
    }
    
    public static void beforeUpdate(Map<Id, Case> newCases, Map<Id, Case> oldCases) {
        
        //detect ASP application probable refusal in past 12 months
        CaseRefusalDetector refusalDetector = new CaseRefusalDetector(newCases, oldCases);
        refusalDetector.detectRefusal();
        
        //update authorisation on approval/rejection of application
        ApprovedApplicationProcessor processor = new ApprovedApplicationProcessor(newCases, oldCases);
        processor.process();
        
        //updates authorisation contact's profile to Account Manager, if its the only active authorisation
        //that has expired, returned or cancel/suspended
        RevokeDVDAccess revokeDVD = new RevokeDVDAccess(newCases, oldCases);
        revokeDVD.revokeDVDAccess();   
        
        //handles approval/rejection flow of variation requests and accordingly update 
        VariationCaseClosedProcessor variationRequestProcessor = new VariationCaseClosedProcessor(newCases, oldCases);
        variationRequestProcessor.processClosedVariationCases();
        
        //handles approval/rejection flow of variation requests and accordingly update 
        LevyAdministrationCaseClosedProcessor levyRequestProcessor = new LevyAdministrationCaseClosedProcessor(newCases, oldCases);
        levyRequestProcessor.processClosedLevyCases();     
        
        //ExpiryCaseClosePreProcessor - Check if Renewal Case is in progress on Authorisation related to Expiry-Renewable Case, if yes display error message
        ExpiryCaseClosePreProcessor expiryCaseClosePreProcessor = new ExpiryCaseClosePreProcessor(newCases);
        expiryCaseClosePreProcessor.checkRenewalCaseIsInProgress();
        
        //ASPExpiryCaseClosePreProcessor - Check if Renewal Case is in progress on Authorisation related to Expiry-Renewable Case, if yes display error message
        ASPExpiryCaseClosePreProcessor aspExpiryCaseClosePreProcessor = new ASPExpiryCaseClosePreProcessor(newCases);
        aspExpiryCaseClosePreProcessor.checkRenewalCaseIsInProgress();
       
        //Transport updates
        CaseTriggerHelper.changeCaseRecordType(newCases, oldCases);
        
        //handles approval actions of agent registration cases
        AgentRegistrationCaseApprovalProcessor agentRegProcessor = new AgentRegistrationCaseApprovalProcessor(newCases, oldCases);
        agentRegProcessor.processApprovedAgentRegistrationCases();
        
        //handles approval actions of agent agreement cases
        AgentAgreementCaseApprovalProcessor agentAgreementProcessor = new AgentAgreementCaseApprovalProcessor(newCases, oldCases);
        agentAgreementProcessor.processApprovedAgentAgreementCases();
        
        //handles approval actions of agent revoke agreement cases
        RevokeAgreementCaseApprovalProcessor agentRevokeAgreementProcessor = new RevokeAgreementCaseApprovalProcessor(newCases, oldCases);
        agentRevokeAgreementProcessor.processApprovedAgentRevokeAgreementCases();
        
        //Audit Case Update Case Owner on Audit Approval/Rejection Actions
        AuditCaseAssignedReviewerPostApproval auditCaseAssignedReviewerPostApproval = new AuditCaseAssignedReviewerPostApproval(newCases, oldCases);
        auditCaseAssignedReviewerPostApproval.updateCaseOwnertoAssignedReviewer();
        
        //handles criminal offence investigation case closure
        COInvestigationCloseCaseProcessor coiCaseClosedProcessor = new COInvestigationCloseCaseProcessor(newCases, oldCases);
        coiCaseClosedProcessor.processClosedCases();
        
        //handles case closure to check if all related notice records are in closed/cancelled status.
        CaseTriggerHelper.checkCaseRelatedNoticeClosed(newCases, oldCases);
    }
    
    //Added for Audit Case Trigger
    public static void afterInsert(Map<Id, Case> newCases) {
        AuditCaseCreationHandler auditCaseCreated = new AuditCaseCreationHandler(newCases);
        auditCaseCreated.postAuditCaseCreationAutomation();
    }
    
    //Added for Audit Case Trigger
    public static void beforeInsert(List<Case> newCases) {
        //AuditDefaultGroupAccount auditDefaultGroupAccount = new AuditDefaultGroupAccount(newCases);
        //auditDefaultGroupAccount.postAuditCaseCreationUpdateVendorGroup();
      }
    
}