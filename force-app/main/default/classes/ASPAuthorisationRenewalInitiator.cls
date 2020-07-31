public class ASPAuthorisationRenewalInitiator {
    
    public void initiate(List<Authorisation__c> listAuthorisations) {
        
        // Remove Authorisations which have Renewal Application Open 
        List<Authorisation__c> listAuthsEligibleForRenewal = filterAuthorisationsHavingRenewalInProgress(listAuthorisations);
        
        // If TSP and BSP are due to renewals within 30 days from the end date of other authorisation 
        // then we should be creating combined renewal application
        
        // If an authorisation (A) is found on an account fitting the above conditions, 
        // check if there is another authorisation (B) with Status: Granted Unconditionally, Granted With Conditions or Suspended, 
        // and the End Date is within 30 days of the end date of authorisation (A)
        
        Set<Id> accountIds = new Set<Id>();
        for(Authorisation__c auth : listAuthsEligibleForRenewal) {
            accountIds.add(auth.Service_Provider__c);
        }
        
        Date currentPlus30Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_End_Date_of_ASP_Authorisation));
        Date thirtyDaysAfterCurrentPlus30Days = currentPlus30Days.addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_End_Date_of_ASP_Authorisation));
        List<Authorisation__c> listAuthorisationsExpiringFromSameAccount = [SELECT Id, Name, Authorisation_Number__c, Authorisation_Type__c, Service_Provider__c, Application__c 
                                                                            FROM Authorisation__c 
                                                                            WHERE (Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_BSP 
                                                                                   OR Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_TSP)
                                                                            AND (Status__c =: GlobalConstants.GRANTED_UNCONDITIONALLY
                                                                                 OR Status__c =: GlobalConstants.GRANTED_CONDITIONALLY
                                                                                 OR Status__c =: GlobalConstants.AUTHORISATION_SUSPENDED)
                                                                            AND End_Date__c <=: thirtyDaysAfterCurrentPlus30Days
                                                                            AND Service_Provider__c IN : accountIds];
        
        listAuthsEligibleForRenewal.addAll(filterAuthorisationsHavingRenewalInProgress(listAuthorisationsExpiringFromSameAccount));
        
        createRenewalCaseWithDraftAuth(listAuthsEligibleForRenewal);
    }
    
    // Check if open Renewal application exists for a Authorisation
    private List<Authorisation__c> filterAuthorisationsHavingRenewalInProgress(List<Authorisation__c> listAuthorisations) {
        
        // Map of Existing Auths
        Map<Id, Authorisation__c> mapIdVSExistingAuthorisation = new Map<Id, Authorisation__c>();
        for(Authorisation__c auth : listAuthorisations) {
            mapIdVSExistingAuthorisation.put(auth.Id, auth);
        }
        
        // Map of Cloned Auths
        // Renewal Case is associated with Cloned Auth of Existing Auth
        Map<Id, Authorisation__c> mapIdVSClonedAuthorisations = new Map<Id, Authorisation__c>([SELECT Id, Related_Authorisation__c, Application__c
                                                                                               FROM Authorisation__c 
                                                                                               WHERE Related_Authorisation__c IN : mapIdVSExistingAuthorisation.keySet()]);
        
        // Check if Renewal case in progress on Cloned Auth
        Set<Id> caseIds = new Set<Id>();
        for(Authorisation__c auth : mapIdVSClonedAuthorisations.values()) {
            
            if(String.isNotEmpty(auth.Application__c)) {
                caseIds.add(auth.Application__c);
            }
        }
        
        Map<Id, Case> openRenewalApplications = new Map<Id, Case> ([SELECT Id, CaseNumber, Status
                                                                    FROM Case 
                                                                    WHERE IsClosed = FALSE
                                                                    AND Id IN :caseIds
                                                                    AND Type =: GlobalConstants.SERVICE_PROVIDER_CASE_TYPE
                                                                    AND Sub_Type__c =: GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                                                    AND (Status =: GlobalConstants.APPLICATION_STATUS_DRAFT 
                                                                         OR Status =: GlobalConstants.APPLICATION_STATUS_LODGED)]);
        
        Set<Id> authToRemoveFromList = new Set<Id>();
        
        for(Id applicationId : openRenewalApplications.keySet()) {
            
            for(Authorisation__c auth : mapIdVSClonedAuthorisations.values()) {
                
                if(auth.Application__c != null && auth.Application__c.equals(applicationId)) {
                    authToRemoveFromList.add(auth.Related_Authorisation__c);
                }
            }
        }
        
        for(Authorisation__c auth : listAuthorisations) {
            
            if(authToRemoveFromList.contains(auth.Id)) {
                mapIdVSExistingAuthorisation.remove(auth.Id);
            }
        }
        
        return mapIdVSExistingAuthorisation.values();
    }
    
    public void createRenewalCaseWithDraftAuth(List<Authorisation__c> existingAuthsParam) {
        
        // Clone existing ASP Auths
        String soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c','Id IN :existingAuthsParam');
        System.debug(LoggingLevel.INFO, 'Generated SOQL to clone ASP Authorisations : ' + soql);
        
        List<Authorisation__c> existingAuths = (List<Authorisation__c>) Database.query(soql);
        List<Authorisation__c> clonedAuths = new List<Authorisation__c>();
        List<Authorisation__c> existingAuthsUpdated = new List<Authorisation__c>();
        
        for(Authorisation__c existingAuth : existingAuths) {
            
            System.debug(LoggingLevel.INFO, ' Existing ASP Auth: ' + existingAuth);
            
            Authorisation__c clonedAuth = existingAuth.clone(false, true, false, false);
            clonedAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
            clonedAuth.Start_Date__c = existingAuth.End_Date__c.addDays(1);
            Date endDate = Date.newInstance(clonedAuth.Start_Date__c.year() + Integer.valueOf(System.Label.Default_ASP_Term_period), clonedAuth.Start_Date__c.month(), clonedAuth.Start_Date__c.day()-1);
            clonedAuth.End_Date__c = endDate;
            
            clonedAuth.Auto_Generate_Number__c = false;
            clonedAuth.Is_Renewal_Licence__c = true;
            clonedAuth.Related_Authorisation__c = existingAuth.Id;
            
            clonedAuth.ASP_Authorisation_Approved__c = false;
            
            clonedAuths.add(clonedAuth);
            
            existingAuth.Renewal_Requested__c = true;
            existingAuthsUpdated.add(existingAuth);
        }
        
        // Insert Authorisations
        Database.insert(clonedAuths, false);
        
        // Update flag on existing Authorisation
        Database.update(existingAuthsUpdated, false);
        
        // Populate Map Account Id VS List<Authorisation__c>
        Map<Id, List<Authorisation__c>> mapAccountVsAuthorisations = new Map<Id, List<Authorisation__c>>();
        for(Authorisation__c auth : clonedAuths) {
            
            if(mapAccountVsAuthorisations.containsKey(auth.Service_Provider__c)) {
                mapAccountVsAuthorisations.get(auth.Service_Provider__c).add(auth);
            } else {
                mapAccountVsAuthorisations.put(auth.Service_Provider__c, new List<Authorisation__c> {auth});
            }
        }
        
        // Create Cases
        List<Case> renewalCases = new List<Case>();
        Case renewalCase;
        
        Id serviceProviderAdministrationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        PrimaryContactRetriever primaryContactRetriever = new PrimaryContactRetriever(mapAccountVsAuthorisations.keySet());
        
        for(Id accountId : mapAccountVsAuthorisations.keySet()) {
            
            renewalCase = new Case();
            renewalCase.AccountId = accountId;
            renewalCase.ContactId = primaryContactRetriever.identifyPrimaryContact(accountId);
            renewalCase.RecordTypeId = serviceProviderAdministrationRecordType;
            renewalCase.Status = GlobalConstants.CASE_DRAFT;
            renewalCase.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
            renewalCase.Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE;                 
            renewalCase.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
            renewalCase.Subject = GlobalConstants.ASP_AUTH_RENEWAL_CASE_SUBJECT;
            renewalCase.Description = GlobalConstants.ASP_AUTH_RENEWAL_CASE_SUBJECT;               
            renewalCase.Origin = GlobalConstants.CASE_ORIGIN_WEB;
            
            // Populate field Renewal_Authorisation_End_Date__c on Case
            // This field holds the End Date of Authorisation which is expiring after exact 30 days from Case creation date (i.e. today)
            List<Authorisation__c> listAuthorisationsFromSameAccount = mapAccountVsAuthorisations.get(accountId);
            
            Date authEndDate = null;
            Authorisation__c clonnedAuthWithEarlierEndDate = null;
                
            if(listAuthorisationsFromSameAccount.size() == 1) {
                // We have 1 Authorisation due for Renewal
                clonnedAuthWithEarlierEndDate = listAuthorisationsFromSameAccount.get(0);
                authEndDate = clonnedAuthWithEarlierEndDate.End_Date__c;
            } else {
                // We have 2 Authorisations due for Renewal
                for(Authorisation__c auth : listAuthorisationsFromSameAccount) {
                   
                    if(authEndDate == null) {
                        clonnedAuthWithEarlierEndDate = auth;
                        authEndDate = auth.End_Date__c;
                    } else if(authEndDate != null && authEndDate > auth.End_Date__c) {
                        clonnedAuthWithEarlierEndDate = auth;
                        authEndDate = auth.End_Date__c;
                    }
                }
            }
            
            Authorisation__c originalAuth = [SELECT Id, End_Date__c FROM Authorisation__c 
                                             WHERE Id =: clonnedAuthWithEarlierEndDate.Related_Authorisation__c];
            
            renewalCase.Renewal_Authorisation_End_Date__c = originalAuth.End_Date__c;
            
            renewalCases.add(renewalCase);
        }
        
        // Insert Cases
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        
        Database.insert(renewalCases, dmo);
        
        // Associate Auth and Case
        Map<Id, Id> mapAccountIdVSCaseId = new Map<Id, Id>();
        for(Case caseRec : renewalCases) {
            mapAccountIdVSCaseId.put(caseRec.AccountId, caseRec.Id);
        }
        
        List<Authorisation__c> updatedAuths = new List<Authorisation__c>();
        for(Id accountId : mapAccountVsAuthorisations.keySet()) {
            
            List<Authorisation__c> listAuthsFromSameAccount = mapAccountVsAuthorisations.get(accountId);
            Id renewalCaseId = mapAccountIdVSCaseId.get(accountId);
            
            for(Authorisation__c auth : listAuthsFromSameAccount) {
                auth.Application__c = renewalCaseId;
                updatedAuths.add(auth);
            }
        }
        
        Database.update(updatedAuths, false);
    }
    
}