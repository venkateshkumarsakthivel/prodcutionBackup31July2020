/**
* Server side controller for saving Case and Related Contacts data for Licence Agreement Registration component
*/
public without sharing class LicenceAgreementRegistrationController {
    
    public static String taxiErrorMessageStr = '';
    public static List<String> errorTaxiLicenceList = New List<String>();
    public static List<String> errorList = new List<String>();
    public static Map<String, String> taxiLicAndPlateNumVsAuthorisationIdMap = new Map<String, String>();

    //function returns data for section of Licence Agreement Registration form
    @AuraEnabled
    public static String saveRelatedContacts(List<Related_Contact__c> ListRelatedContact, String caseId, String accountId) {
        
        boolean isTaxiLicAndPlateNumBothMatch = false;
        boolean isOnlyTaxiLicMatch = false;
        boolean isTaxiLicNotMatch = false;
        List<String> taxiLicenceList = New List<String>();
        List<String> plateNumberList = New List<String>();
        List<String> errorTaxiLicencePlateNumberList = New List<String>();
        List<String> duplicateEntryErrorTaxiLicenceList = New List<String>();
        List<Related_Contact__c> relatedContactsList = new List<Related_Contact__c>();
        Map<String, String> taxiLicenceVsPlateNumberMap = new Map<String, String>();
        
        
        relatedContactsList.addAll(ListRelatedContact);
        ListRelatedContact.clear();
        
        for(Integer i = 0; i < relatedContactsList.size(); i++) {
            if((relatedContactsList.get(i).Taxi_Licence__c != '' && relatedContactsList.get(i).Taxi_Licence__c != null) && (relatedContactsList.get(i).Plate_Number__c != '' && relatedContactsList.get(i).Plate_Number__c != null)) {
                relatedContactsList.get(i).Taxi_Licence__c = relatedContactsList.get(i).Taxi_Licence__c.touppercase();
                relatedContactsList.get(i).Plate_Number__c = relatedContactsList.get(i).Plate_Number__c.touppercase();
                ListRelatedContact.add(relatedContactsList.get(i));
            }
        }
        
        if(ListRelatedContact == null || ListRelatedContact.size() == 0) {
            //Error message for "all entries are blank"
            taxiErrorMessageStr = 'Taxi Licences and Plate Numbers cannot be blank.';
            return taxiErrorMessageStr;
        }
        
        for(Related_Contact__c relConRecord : ListRelatedContact) {
            taxiLicenceList.add(relConRecord.Taxi_Licence__c);
            plateNumberList.add(relConRecord.Plate_Number__c);
            
            //implementation for duplicate entries check
            if(!taxiLicenceVsPlateNumberMap.containsKey(relConRecord.Taxi_Licence__c + relConRecord.Plate_Number__c)) {
                taxiLicenceVsPlateNumberMap.put((relConRecord.Taxi_Licence__c + relConRecord.Plate_Number__c), relConRecord.Plate_Number__c);
            }
            else {
                errorList.add(relConRecord.Taxi_Licence__c);
                duplicateEntryErrorTaxiLicenceList.add(relConRecord.Taxi_Licence__c);
            }            
        }
        
        if(duplicateEntryErrorTaxiLicenceList != null && duplicateEntryErrorTaxiLicenceList.size() > 0) {
            //Error message for "Duplicate Taxi Licence and Plate Number", "Error List duplicateEntryErrorTaxiLicenceList"
            taxiErrorMessageStr = 'Taxi Licence and Plate Number cannot be repeated.';
            return taxiErrorMessageStr;
        }
        
        List<Authorisation__c> authorisationList = fetchAuthorisationRecords(taxiLicenceList, plateNumberList);
        if(authorisationList == null || authorisationList.isEmpty()) {
            //Error message for "Does not found any Taxi Licence"
            taxiErrorMessageStr = 'The Licence Number ' + errorListStringCovertion(taxiLicenceList) + ' is not correct. Please refer to the Taxi Licence Holder.';
            return taxiErrorMessageStr;
        }
        
        for(Related_Contact__c relConRec : ListRelatedContact) {
            isTaxiLicAndPlateNumBothMatch = false;
            isOnlyTaxiLicMatch = false;
            isTaxiLicNotMatch = false;
            
            for(Authorisation__c authRec : authorisationList) {
                if(relConRec.Taxi_Licence__c == authRec.Name && relConRec.Plate_Number__c == authRec.Plate_Number__c) {
                    isTaxiLicAndPlateNumBothMatch = true;
                    isOnlyTaxiLicMatch = false;
                    isTaxiLicNotMatch = false;
                    break;
                }
                else {
                    if(relConRec.Taxi_Licence__c == authRec.Name && relConRec.Plate_Number__c != authRec.Plate_Number__c) {
                        isOnlyTaxiLicMatch = true;
                        isTaxiLicNotMatch = false;
                    }
                    else if(isOnlyTaxiLicMatch != true) {
                        isTaxiLicNotMatch = true;
                    }
                }
            }
            if(isTaxiLicAndPlateNumBothMatch != true && isOnlyTaxiLicMatch == true) {
                errorList.add(relConRec.Taxi_Licence__c);
                errorTaxiLicencePlateNumberList.add(relConRec.Taxi_Licence__c);
            }
            else if(isTaxiLicAndPlateNumBothMatch != true) {
                errorList.add(relConRec.Taxi_Licence__c);
                errorTaxiLicenceList.add(relConRec.Taxi_Licence__c);
            }
        }
        
        if(errorTaxiLicenceList != null && errorTaxiLicenceList.size() > 0) {
            //Error message for "Does not match Taxi Licence"
            taxiErrorMessageStr = 'The Licence Number ' + errorListStringCovertion(errorTaxiLicenceList) + ' is not correct. Please refer to the Taxi Licence Holder.';
            return taxiErrorMessageStr;
        }
        if(errorTaxiLicencePlateNumberList != null && errorTaxiLicencePlateNumberList.size() > 0) {
            //Error message for "Does not match Plate Number"
            taxiErrorMessageStr = 'The Plate Number you have entered for Licence Number ' + errorListStringCovertion(errorTaxiLicencePlateNumberList) + ' is not correct. Please refer to the Taxi Licence Holder.';
            return taxiErrorMessageStr;
        }
        
        if(ListRelatedContact != null && ListRelatedContact.size() > 0 && errorList.isEmpty()) {
            if(validateForSameAccount(authorisationList)) {
                if(validateForGranted(authorisationList)) {
                    Case upsertedcase = upsertCase(caseId, authorisationList[0].Service_Provider__r.Name, accountId);
                    upsertRelatedContacts(ListRelatedContact, upsertedcase.Id);
                    taxiErrorMessageStr = upsertedcase.Id;
                }
                else {
                    //Error message for "not Granted"
                    taxiErrorMessageStr = 'The Licence Number ' + errorListStringCovertion(errorTaxiLicenceList) + ' is not correct. Please refer to the Taxi Licence Holder.';
                    return taxiErrorMessageStr;
                }
            }
            else {
                //Error message for "Does not belong to Same Account", "Error List errorTaxiLicenceList"
                taxiErrorMessageStr = 'The ownership of Taxi Licence Number is not the same as the previous Taxi Licence Number. Please refer to the Taxi Licence Holder for confirmation.';
                return taxiErrorMessageStr;
            }
        }
        return taxiErrorMessageStr;
    }
    
    //function to fetch Authorisation data
    public static List<Authorisation__c> fetchAuthorisationRecords(List<String> taxiLicenceList, List<String> plateNumberList) {
        Map<String, Authorisation__c> taxiLicPlateNumVsAuthorisationMap = new Map<String, Authorisation__c>();
        List<Authorisation__c> authorisationList = new List<Authorisation__c>();
        List<Authorisation__c> authList = [SELECT Id, Name, Plate_Number__c, Service_Provider__c, Status__c, Service_Provider__r.Name  
                                                    FROM Authorisation__c 
                                                    WHERE Name IN: taxiLicenceList];
        for(Authorisation__c auth : authList) {
            if(taxiLicPlateNumVsAuthorisationMap.containsKey(auth.Name + '-' + auth.Plate_Number__c) && taxiLicPlateNumVsAuthorisationMap.get(auth.Name + '-' + auth.Plate_Number__c).Status__c != 'Granted' && auth.Status__c == 'Granted') {
                taxiLicPlateNumVsAuthorisationMap.put(auth.Name + '-' + auth.Plate_Number__c, auth);
                taxiLicAndPlateNumVsAuthorisationIdMap.put(auth.Name + '-' + auth.Plate_Number__c, auth.Id);
            }
            else if(!taxiLicPlateNumVsAuthorisationMap.containsKey(auth.Name + '-' + auth.Plate_Number__c)){
                taxiLicPlateNumVsAuthorisationMap.put(auth.Name + '-' + auth.Plate_Number__c, auth);
                taxiLicAndPlateNumVsAuthorisationIdMap.put(auth.Name + '-' + auth.Plate_Number__c, auth.Id);
            }
        }
        for(Authorisation__c authRec : taxiLicPlateNumVsAuthorisationMap.values()) {
            authorisationList.add(authRec);
        }
        return authorisationList;
    }
    
    //function to validate data for All the Taxi Licence number should be related to same Account
    public static Boolean validateForSameAccount(List<Authorisation__c> authorisationList) {
        Boolean isValidateForSameAccount = true;
        if(authorisationList != null && authorisationList.size() > 0) {
            String accId = authorisationList[0].Service_Provider__c;
            for(Authorisation__c authRec : authorisationList) {
                if(accId != authRec.Service_Provider__c) {
                    isValidateForSameAccount = false;
                    errorList.add(authRec.Name);
                    errorTaxiLicenceList.add(authRec.Name);
                }
            }
        }
        return isValidateForSameAccount;
    }
    
    //function to validate data for Taxi Licence authorisation is Granted
    public static Boolean validateForGranted(List<Authorisation__c> authorisationList) {
        Boolean isValidateForGranted = true;
        if(authorisationList != null && authorisationList.size() > 0) {
            for(Authorisation__c authRec : authorisationList) {
                if(authRec.Status__c != 'Granted') {
                    isValidateForGranted = false;
                    errorList.add(authRec.Name);
                    errorTaxiLicenceList.add(authRec.Name);
                }
            }
        }
        return isValidateForGranted;
    }
    
    //function to upsert Case record and return inserted Case
    public static Case upsertCase(String caseId, String authorisationAccountName, String accountId) {
        RecordType rt = fetchCaseRecodType();
        
        Case caseToUpsert = new Case();
        caseToUpsert.Id = caseId;
        caseToUpsert.RecordTypeId = rt.Id;
        caseToUpsert.Type = GlobalConstants.TAXI_CASE_TYPE;
        caseToUpsert.Sub_Type__c  = GlobalConstants.AGENT_LICENCE_AGREEMENT_SUB_TYPE;
        caseToUpsert.Status = GlobalConstants.CASE_NEW;
        caseToUpsert.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DRAFT;
        caseToUpsert.Subject = authorisationAccountName + ' - ' + caseToUpsert.Sub_Type__c;
        caseToUpsert.Description = authorisationAccountName + ' - ' + caseToUpsert.Sub_Type__c;
        caseToUpsert.Licence_Holder_Name__c = authorisationAccountName;
        caseToUpsert.Authorisation_Account_Name__c = authorisationAccountName;
        
        if(accountId != null && accountId != '') {
        
            User usr = fetchLoggedInUser();
            caseToUpsert.AccountId = accountId;
            
            List<Contact> primaryContact = [SELECT Primary_Contact__c, AccountId FROM Contact
                                             WHERE AccountId = :accountId AND Primary_Contact__c = TRUE
                                             ORDER BY LastModifiedDate DESC LIMIT 1];
                                             
            caseToUpsert.ContactId = (primaryContact != NULL && primaryContact.size() > 0) ? primaryContact[0].Id : NULL;
        }
        else {
            User usr = fetchLoggedInUser();
            caseToUpsert.AccountId = usr.AccountId;
            caseToUpsert.ContactId = usr.ContactId;
        }
        
        if(caseToUpsert != null) {
            upsert caseToUpsert;
        }
        return caseToUpsert;
    }
    
    //function to fetch Case record type reocrd of Agent_Registration
    public static RecordType fetchCaseRecodType() {
        String recordTypeDeveloperName = GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE_DEV_NAME;
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where DeveloperName =: recordTypeDeveloperName AND SobjectType = 'Case' LIMIT 1];
        return rt;
    }
    
    //function to fetch logged in user record
    public static User fetchLoggedInUser(){
        User usr = [SELECT Id, AccountId, Account.Name, ContactId FROM User WHERE Id = :UserInfo.getUSerId() LIMIT 1];
        return usr;
    }
    
    //function to upsert Related Contact records
    public static void upsertRelatedContacts(List<Related_Contact__c> ListRelatedContact, String upsertedCaseId) {
        RecordType rt = fetchRelatedContactRecodType();
        List<Related_Contact__c> relConListToUpsert = New List<Related_Contact__c>();
        for(Related_Contact__c recConRec : ListRelatedContact) {
            recConRec.Related_Application__c = upsertedCaseId;
            recConRec.RecordTypeId = rt.Id;
            recConRec.Taxi_Licence_Authorisation__c = taxiLicAndPlateNumVsAuthorisationIdMap.get(recConRec.Taxi_Licence__c + '-' + recConRec.Plate_Number__c); 
            relConListToUpsert.add(recConRec);                
        }
        if(relConListToUpsert != null && relConListToUpsert.size() > 0) {
            upsert relConListToUpsert;
        }
    }
    
    //function to fetch Related Contact record type reocrd of Agent_Agreement
    public static RecordType fetchRelatedContactRecodType() {
        String recordTypeDeveloperName = GlobalConstants.RELATED_CONTACT_AGENT_AGREEMENT_RECORD_TYPE_DEV_NAME;
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where DeveloperName =: recordTypeDeveloperName AND SobjectType = 'Related_Contact__c' LIMIT 1];
        return rt;
    }
    
    //function to update Case record from Upload Agreement Registration form
    @AuraEnabled
    public static String updateCase(String caseId) {
        Group queueRecordForCaseOwner = fetchQueueForCaseOwner();
        case caseToUpdate = fetchCaseRecord(caseId);
        caseToUpdate.Type = GlobalConstants.TAXI_CASE_TYPE;
        caseToUpdate.Sub_Type__c  = GlobalConstants.AGENT_LICENCE_AGREEMENT_SUB_TYPE;
        caseToUpdate.Status = GlobalConstants.LODGED_CASE_STATUS;
        caseToUpdate.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
        caseToUpdate.OwnerId = queueRecordForCaseOwner.Id;
        caseToUpdate.Date_Submitted__c = System.Now();
        
        if(caseToUpdate != null) {
            update caseToUpdate;
        }
        return caseToUpdate.CaseNumber;
    }
    
    //function to fetch Case record
    public static Case fetchCaseRecord(String caseId) {
        case caseRecord = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, OwnerId, Date_Submitted__c FROM Case WHERE Id =: caseId LIMIT 1];
        return caseRecord;
    }
    
    //function to fetch Queue record for Case Owner of Taxi Support Level 1
    public static Group fetchQueueForCaseOwner() {
        String queueDeveloperName = GlobalConstants.TAXI_LEVEL_1_QUEUE_DEV_NAME;
        String queueType = GlobalConstants.QUEUE;
        Group queueRecord = [SELECT Id FROM Group WHERE Type =: queueType AND DeveloperName =: queueDeveloperName LIMIT 1];
        return queueRecord;
    }
        
    //function to fetch Related Contact records
    @AuraEnabled
    public static List<Related_Contact__c> fetchRelatedContactRecords(String caseId) {
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Related_Application__c =: caseId];
        return relatedContactList;
    }
    
    //function to convert all type error list into string format
    public static String errorListStringCovertion(List<String> errorList) {
        String errorListString = '"';
        Integer count = 1;
        for(String errorStr : errorList) {
            errorListString += errorStr;
            if(count != errorList.size()) {
                errorListString += ', ';
            }
            count++;
        }
        errorListString += '"';
        return errorListString;
    }
    
    //function to delete Related Contact records
    @AuraEnabled
    public static Boolean deleteRelatedContactRecord(Related_Contact__c relatedConToDelete) {
       
       delete relatedConToDelete;
       
       return true;
    }
}