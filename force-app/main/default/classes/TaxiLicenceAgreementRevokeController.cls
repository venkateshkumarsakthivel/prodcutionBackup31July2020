public class TaxiLicenceAgreementRevokeController {
    
    //function to retrieve service provider list from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static List<String> fetchServiceProviderList(String accountId, String serviceProvider) {
        
        List<Authorisation_Agent__c> authorisationAgentList = fetchInitialAuthorisationAgentList(accountId, serviceProvider);
        List<String> serviceProviderList = fetchserviceProviderList(authorisationAgentList);
        
        return serviceProviderList;
    }
    
    //function to fetch authorisation agent list from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static List<Authorisation_Agent__c> fetchInitialAuthorisationAgentList(String accountId, String serviceProvider) {
        
        String queryString = 'SELECT Id, isSelectedForRevokeAgreement__c, Authorisation__c, Authorisation__r.Name, Authorisation__r.Plate_Number__c, ' +  
                             'Agreement_Type__c, Status__c, Authorisation_Service_Provider__c, Service_Provider__c, Authorisation__r.Status__c ' + 
                             'FROM Authorisation_Agent__c ' + 
                             'WHERE Authorisation__r.Status__c = \'Granted\' AND Status__c = \'Active\' AND Account__c = \'' + accountId + '\'';
        
        List<Authorisation_Agent__c> authorisationAgentList = database.query(queryString);
        return authorisationAgentList;
    }
    
    //function to fetch authorisation agent list from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static List<Authorisation_Agent__c> fetchAuthorisationAgentList(String accountId, String serviceProvider) {
        
        String queryString = 'SELECT Id, isSelectedForRevokeAgreement__c, Authorisation__c, Authorisation__r.Name, Authorisation__r.Plate_Number__c, ' +  
                             'Agreement_Type__c, Status__c, Authorisation_Service_Provider__c, Service_Provider__c, Authorisation__r.Status__c ' + 
                             'FROM Authorisation_Agent__c ' + 
                             'WHERE Authorisation__r.Status__c = \'Granted\' AND Status__c = \'Active\' AND Account__c = \'' + accountId + '\'';
        
        if(serviceProvider != null && serviceProvider != '') {
            queryString += ' AND Service_Provider__c = \'' + serviceProvider + '\'';
        }
        List<Authorisation_Agent__c> authorisationAgentList = database.query(queryString);
        return authorisationAgentList;
    }
    
    //function to fetch service provider list
    public static List<String> fetchserviceProviderList(List<Authorisation_Agent__c> authorisationAgentList) {
        List<String> serviceProviderList = new List<String>();
        Set<String> serviceProviderSet = new Set<String>();
        for(Authorisation_Agent__c authAgent : authorisationAgentList) {
            serviceProviderSet.add(authAgent.Service_Provider__c);
        }
        serviceProviderList.addAll(serviceProviderSet);
        
        return serviceProviderList;
    }
    
    //function to validate case number and fetch case id from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static String validatiedForCaseNumber(String caseNumberString) {
        if(caseNumberString != null && caseNumberString != '') {
            caseNumberString = caseNumberString.trim();
        }
        String queryString = 'SELECT Id, CaseNumber FROM Case WHERE CaseNumber = \'' + caseNumberString + '\'';
        List<Case> caseList = database.query(queryString);
        if(caseList != null && caseList.size() > 0) {
            return caseList[0].Id;
        }
        else {
            return null;
        }
    }
    
    //function to upsert case from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static String upsertCase(List<Authorisation_Agent__c> authorisationAgentList, String parentCaseId, String newCaseId, String accountId, String serviceProvider) {
        RecordType rt = fetchCaseRecodType();
        List<Contact> primaryContact = fetchPrimaryContact(accountId);
        Account accountRecord = fetchAccountDetails(accountId);
        Case caseToUpsert = new Case();
        caseToUpsert.Id = newCaseId;
        caseToUpsert.RecordTypeId = rt.Id;
        caseToUpsert.Type = GlobalConstants.TAXI_CASE_TYPE;
        caseToUpsert.Sub_Type__c  = GlobalConstants.REVOKE_AGREEMENT_CASE_SUB_TYPE;
        caseToUpsert.Status = GlobalConstants.CASE_NEW;
        caseToUpsert.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_REVIEW_PENDING;
        caseToUpsert.Subject = accountRecord.Name + ' - Revoke Agreement';
        caseToUpsert.Description = accountRecord.Name + ' - Revoke Agreement';
        //caseToUpsert.Licence_Holder_Name__c = serviceProvider;
        caseToUpsert.Authorisation_Account_Name__c = serviceProvider;
        caseToUpsert.AccountId = accountId;
        caseToUpsert.ParentId = parentCaseId;        
        caseToUpsert.ContactId = (primaryContact != NULL && primaryContact.size() > 0) ? primaryContact[0].Id : NULL;
        if(caseToUpsert != null) {
            upsert caseToUpsert;
        }
        return caseToUpsert.Id;
    }
    
    //function to fetch Case record type reocrd of Agent_Registration
    public static RecordType fetchCaseRecodType() {
        String recordTypeDeveloperName = GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE_DEV_NAME;
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where DeveloperName =: recordTypeDeveloperName AND SobjectType = 'Case' LIMIT 1];
        return rt;
    }
    
    //function to fetch primary contact reocrd of Agent_Registration
    public static List<Contact> fetchPrimaryContact(String accountId) {
        List<Contact> primaryContact = [SELECT Primary_Contact__c, AccountId FROM Contact
                                        WHERE AccountId = :accountId AND Primary_Contact__c = TRUE
                                        ORDER BY LastModifiedDate DESC LIMIT 1];
        return primaryContact;
    }
    
    //function to fetch account reocrd details of Agent_Registration
    public static Account fetchAccountDetails(String accountId) {
        Account accountRecord = [SELECT Id, Name FROM Account WHERE Id =: accountId LIMIT 1];
        return accountRecord;
    }
    
    //function to upsert related contacts from TaxiLicenceAgreementRevoke form
    @AuraEnabled
    public static List<Related_Contact__c> upsertRelatedContacts(List<Authorisation_Agent__c> authorisationAgentList, String newCaseId) {
        deleteExistingRelatedContacts(newCaseId);
        RecordType rt = fetchRelatedContactRecodType();
        List<Related_Contact__c> relConListToUpsert = New List<Related_Contact__c>();
        for(Authorisation_Agent__c authAgentRec : authorisationAgentList) {
            if(authAgentRec.isSelectedForRevokeAgreement__c == true) {
                Related_Contact__c recConRec = new Related_Contact__c();
                recConRec.Related_Application__c = newCaseId;
                recConRec.RecordTypeId = rt.Id;
                recConRec.Taxi_Licence_Authorisation__c  = authAgentRec.Authorisation__c;
                recConRec.Taxi_Licence__c = authAgentRec.Authorisation__r.Name;
                recConRec.Plate_Number__c = authAgentRec.Authorisation__r.Plate_Number__c;
                relConListToUpsert.add(recConRec);
            }
        }
        if(relConListToUpsert != null && relConListToUpsert.size() > 0) {
            upsert relConListToUpsert;
        }
        return relConListToUpsert;
    }
    
    //function to delete existing Related Contacts
    public static void deleteExistingRelatedContacts(String newCaseId) {
        List<Related_Contact__c> relConListToDelete = [SELECT Id FROM Related_Contact__c WHERE Related_Application__c =: newCaseId];
        if(relConListToDelete != null && relConListToDelete.size() > 0) {
            delete relConListToDelete;
        }
    }
    
    //function to fetch Related Contact record type reocrd of Agent_Agreement 
    public static RecordType fetchRelatedContactRecodType() {
        String recordTypeDeveloperName = GlobalConstants.RELATED_CONTACT_AGENT_AGREEMENT_RECORD_TYPE_DEV_NAME;
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where DeveloperName =: recordTypeDeveloperName AND SobjectType = 'Related_Contact__c' LIMIT 1];
        return rt;
    }
    
    //function to update Case record from TaxiLicenceAgreementRevokeB form
    @AuraEnabled
    public static String updateCase(String newCaseId) {
        Group queueRecordForCaseOwner = fetchQueueForCaseOwner();
        case caseToUpdate = fetchCaseRecord(newCaseId);
        caseToUpdate.Type = GlobalConstants.TAXI_CASE_TYPE;
        caseToUpdate.Sub_Type__c  = GlobalConstants.REVOKE_AGREEMENT_CASE_SUB_TYPE;
        caseToUpdate.Status = GlobalConstants.LODGED_CASE_STATUS;
        caseToUpdate.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
        caseToUpdate.OwnerId = queueRecordForCaseOwner.Id;
        caseToUpdate.Date_Submitted__c = System.Now();
        if(caseToUpdate != null) {
            update caseToUpdate;
        }
        return caseToUpdate.CaseNumber;
    }
    
    //function to fetch Queue record for Case Owner of Taxi Support Level 1
    public static Group fetchQueueForCaseOwner() {
        String queueDeveloperName = GlobalConstants.TAXI_LEVEL_1_QUEUE_DEV_NAME;
        String queueType = GlobalConstants.QUEUE;
        Group queueRecord = [SELECT Id FROM Group WHERE Type =: queueType AND DeveloperName =: queueDeveloperName LIMIT 1];
        return queueRecord;
    }
    
    //function to fetch Case record
    public static Case fetchCaseRecord(String caseId) {
        case caseRecord = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, OwnerId, Date_Submitted__c FROM Case WHERE Id =: caseId LIMIT 1];
        return caseRecord;
    }

}