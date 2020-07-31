// When Expiry Case is Closed and Approved - Update Draft Authorisation Status, Associated Renewal Case 
// This is invoked from Process - ASP Expiry Case Closed Approved - Post Processing
public with sharing class ASPExpiryCaseClosePostProcessor {
    
    @InvocableMethod
    public static void closeRenewalCase(List<Authorisation__C> listAuthorisations) {
        
        // We get only one Authorisation in List     
        Authorisation__c originalAuthorisation = listAuthorisations.get(0);  
        
        Id originalAuthorisationId = originalAuthorisation.Id;  
        
        List<Authorisation__c> relatedDraftAuthorisationList = [SELECT Id, Application__c, Status__c FROM Authorisation__c
                                                      WHERE Related_Authorisation__c =: originalAuthorisationId];
        
        Authorisation__c relatedDraftAuthorisation = null;
        if(relatedDraftAuthorisationList.size() > 0) {
            relatedDraftAuthorisation = relatedDraftAuthorisationList.get(0);
        }
        
        Id relatedRenewalCaseId = null;
        
        if(relatedDraftAuthorisation != null) {
            
            relatedRenewalCaseId = relatedDraftAuthorisation.Application__c;
            
            if(relatedRenewalCaseId != null) {
                
                Id serviceProviderAdministrationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                    GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                
                List<Case> listCases = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c FROM Case 
                                        WHERE Id =: relatedRenewalCaseId
                                        AND (Status =: GlobalConstants.CASE_DRAFT 
                                             OR Status =: GlobalConstants.APPLICATION_STATUS_LODGED
                                             OR Status =: GlobalConstants.CANCELLED_CASE_STATUS)
                                        AND RecordTypeId =: serviceProviderAdministrationRecordType
                                        AND Type =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE                
                                        AND Sub_Type__c =: GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION];
                
                Case renewalCaseRecord =  null;
                if(listCases.size() > 0) {
                    renewalCaseRecord = listCases.get(0);
                }
                
                //Renewal Case Present
                //Update Renewal case Status: "Cancelled" and Sub Status: "Expired"
                //Update Draft Authorisation Status : "Discarded"
                if(renewalCaseRecord != null) {
                    
                    renewalCaseRecord.Status = GlobalConstants.CANCELLED_CASE_STATUS;
                    renewalCaseRecord.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_EXPIRED;
                    Database.update(renewalCaseRecord, false);
                    
                    relatedDraftAuthorisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_DISCARDED;
                    
                    Database.update(relatedDraftAuthorisation, false);
                }
            }
        }
    }
}