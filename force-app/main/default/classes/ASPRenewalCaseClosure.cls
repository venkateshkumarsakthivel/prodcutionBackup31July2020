// When Authorisation related to ASP Renewal Case Gets Approved (Status : Granted Unconditionally / Granted With Conditions)
// check if all Authorisations linked to Renewal Case are approved 
public with sharing class ASPRenewalCaseClosure {
    
    @InvocableMethod
    public static void closeRenewalCase(List<Authorisation__c> listAuthorisations) {
        
        // We get only one Authorisation in List    
        Authorisation__c authReceived = listAuthorisations.get(0);
        
        // Draft Auth which got approved or rejected from Renewal Case
        Authorisation__c draftAuthWhichIsApprovedOrRejected =  [SELECT Id, Application__c, Status__c FROM Authorisation__c
                                                                WHERE Id =: authReceived.Id];
        
        // Related Renewal Case
        Id relatedRenewalCaseId = draftAuthWhichIsApprovedOrRejected.Application__c;
        System.debug('relatedRenewalCaseId ' + relatedRenewalCaseId);
        
        List<Case> relatedRenewalCasesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c FROM Case 
                                   WHERE Id =: relatedRenewalCaseId
                                   AND Type =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
                                   AND Sub_Type__c =: GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                   AND Status =: GlobalConstants.APPLICATION_STATUS_LODGED];

        Case relatedRenewalCase = null;
        if(relatedRenewalCasesList.size() > 0) {
            relatedRenewalCase = relatedRenewalCasesList.get(0);
        }
        System.debug('relatedRenewalCase ' + relatedRenewalCase);
        
        if(relatedRenewalCase != null) {
            
            // Get another Related Authorisation from Case (BSP or TSP) if exists 
            List<Authorisation__c> otherAuthRelatedToRenewalCaseList = [SELECT Id, Application__c, Status__c, Authorisation_Type__c FROM Authorisation__c
                                                              WHERE Application__c =: relatedRenewalCaseId
                                                              AND Id !=: draftAuthWhichIsApprovedOrRejected.Id];
            
            Authorisation__c otherAuthRelatedToRenewalCase = null;
            
            if(otherAuthRelatedToRenewalCaseList.size() > 0) {
                otherAuthRelatedToRenewalCase = otherAuthRelatedToRenewalCaseList.get(0);
            }
            System.debug('otherAuthRelatedToRenewalCase ' + otherAuthRelatedToRenewalCase);
            
            // Change Renewal Case Status and Sub Status
            if((draftAuthWhichIsApprovedOrRejected.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                || draftAuthWhichIsApprovedOrRejected.Status__c == GlobalConstants.GRANTED_CONDITIONALLY)
               && (otherAuthRelatedToRenewalCase == null ||
                   (otherAuthRelatedToRenewalCase != null 
                    && (otherAuthRelatedToRenewalCase.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                        || otherAuthRelatedToRenewalCase.Status__c == GlobalConstants.GRANTED_CONDITIONALLY)
                    && (otherAuthRelatedToRenewalCase.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP
                        || otherAuthRelatedToRenewalCase.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP))))
            {
                relatedRenewalCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
                relatedRenewalCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
                
                Database.update(relatedRenewalCase, false);
            }
            else if(draftAuthWhichIsApprovedOrRejected.Status__c == GlobalConstants.APPLICATION_STATUS_REFUSED
                    && (otherAuthRelatedToRenewalCase == null ||
                        (otherAuthRelatedToRenewalCase != null 
                         && otherAuthRelatedToRenewalCase.Status__c == GlobalConstants.APPLICATION_STATUS_REFUSED
                         && (otherAuthRelatedToRenewalCase.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP
                             || otherAuthRelatedToRenewalCase.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP))))
            {
                relatedRenewalCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
                relatedRenewalCase.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_REFUSED;
                
                Database.update(relatedRenewalCase, false);
            }
        }        
    }
}