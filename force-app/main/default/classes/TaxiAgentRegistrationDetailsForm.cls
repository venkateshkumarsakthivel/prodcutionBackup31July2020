//This class is used for taxi agent registration process

public  without sharing class TaxiAgentRegistrationDetailsForm {
    
    // Method for preparing data for case registration
    @AuraEnabled
    public static Case getCaseDetails() {
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE).getRecordTypeId();
        Case caseRecord =new case();
        caseRecord.RecordTypeId = recordTypeId;
        caseRecord.Status= GlobalConstants.CASE_NEW;
        caseRecord.Sub_Status__c= GlobalConstants.CASE_DRAFT;
        caseRecord.Type= GlobalConstants.SERVICE_TYPE_TAXI;
        caseRecord.Sub_Type__c= GlobalConstants.CASE_SUB_TYPE_AGENT_REGISTRATION;
        caseRecord.Subject = '';
        caseRecord.Is_Privacy_Statement_Declared__c = false;
        System.debug('Check Case: '+caseRecord);
        return caseRecord;
    }
    
    // Method for preparing data for related contact registration
    @AuraEnabled
    public static Related_Contact__c getRelatedContactDetails(String entityType) {
        
        system.debug('entityType======>'+ entityType);
        Related_Contact__c relatedContactRecord =new Related_Contact__c();
        Id individualRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_INDIVIDUAL_AGENT_RECORD_TYPE).getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_CORPORATE_AGENT_RECORD_TYPE).getRecordTypeId();
        system.debug('individualRecordTypeId======>'+ individualRecordTypeId);
        system.debug('corporateRecordTypeId======>'+ corporateRecordTypeId);
        
        relatedContactRecord.RecordTypeId = entityType == GlobalConstants.RELATED_CONTACT_INDIVIDUAL_RECORD_TYPE ? individualRecordTypeId : corporateRecordTypeId;
        system.debug('relatedContactRecord.RecordTypeId======>'+ relatedContactRecord.RecordTypeId);
        
        relatedContactRecord.First_Given_Name__c= '';
        relatedContactRecord.Family_Name__c = null;
        relatedContactRecord.Other_Given_Name__c= null;
        relatedContactRecord.Date_of_Birth__c = null;
        relatedContactRecord.Australian_Driver_Licence__c= null;
        relatedContactRecord.Australian_Driver_Licence_State__c = null;
        relatedContactRecord.Daytime_Phone__c= null;
        relatedContactRecord.Email__c= null;
        relatedContactRecord.ACN__c= null;
        relatedContactRecord.Corporation_Name__c= null;
        relatedContactRecord.Contact_Type__c= null;
        
        relatedContactRecord.Notice_Address_Street__c = null;
        relatedContactRecord.Notice_Address_City__c = null;
        relatedContactRecord.Notice_Address_State__c= null;
        relatedContactRecord.Notice_Address_Postal_Code__c= null;
        relatedContactRecord.Notice_Address_Country__c= null;        
        
        return relatedContactRecord; 
    }
    
    // Method to create case
    @AuraEnabled
    public static Case saveCaseRecord(Case caseRegistrationdata) {
    
        upsert caseRegistrationdata;
        return caseRegistrationdata;
    }
    
    // Method used to save case data
    @AuraEnabled
    public static String saveAgentCaseRecord(Case caseRegistrationdata) {
        
        //caseRegistrationdata.OwnerId = [SELECT Id from Group WHERE Type =:GlobalConstants.QUEUE AND DeveloperName =: GlobalConstants.TAXI_LEVEL_1_QUEUE_DEV_NAME LIMIT 1].Id;
        System.debug('Created Case: '+caseRegistrationdata);
        Case getCaseNumber = [SELECT CaseNumber,Subject FROM Case where Id=:caseRegistrationdata.Id];
        caseRegistrationdata.Subject = getCaseNumber.Subject;
        caseRegistrationdata.Date_Submitted__c = DateTime.now();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = TRUE;
        caseRegistrationdata.setOptions(dmo);
        
        //insert notifiableOccurrence Case with case assignment rule and email notification enabled.
        Database.update(caseRegistrationdata, dmo);
        
        System.debug('Upsert Case: '+caseRegistrationdata);
        return getCaseNumber.CaseNumber;
    }
    
    // Method to create related contact
    @AuraEnabled
    public static Related_Contact__c saveRelatedContactRecord(String entityType, Case registerCasedata, Related_Contact__c relatedContactRegistrationdata, String relatedContactdata) {
        
        Related_Contact__c relatedContactRecordDetails = new Related_Contact__c();
        
        Id individualRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_INDIVIDUAL_AGENT_RECORD_TYPE).getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_CORPORATE_AGENT_RECORD_TYPE).getRecordTypeId();
        system.debug('individualRecordTypeId======>'+ individualRecordTypeId);
        system.debug('corporateRecordTypeId======>'+ corporateRecordTypeId);
        
        relatedContactRecordDetails = relatedContactRegistrationdata;
        relatedContactRecordDetails.Notice_Address_Country__c = 'Australia';
        String caseSubjectPrefix = null;
        if(entityType == GlobalConstants.RELATED_CONTACT_INDIVIDUAL_RECORD_TYPE){
            
            relatedContactRecordDetails.RecordTypeId = individualRecordTypeId;
            caseSubjectPrefix = String.isBlank(relatedContactRegistrationdata.First_Given_Name__c) ? relatedContactRegistrationdata.Family_Name__c : relatedContactRegistrationdata.First_Given_Name__c + ' '+ relatedContactRegistrationdata.Family_Name__c;
            //caseSubjectPrefix = relatedContactRegistrationdata.First_Given_Name__c + ' '+ relatedContactRegistrationdata.Family_Name__c;
        }
        else{
            
            relatedContactRecordDetails.RecordTypeId = corporateRecordTypeId;
            relatedContactRecordDetails.Family_Name__c = relatedContactRegistrationdata.Corporation_Name__c;
            relatedContactRecordDetails.Registered_Business_Name__c = relatedContactRegistrationdata.Corporation_Name__c;
            
            caseSubjectPrefix = relatedContactRegistrationdata.Corporation_Name__c;
        }
        
        relatedContactRecordDetails.Contact_Type__c = relatedContactdata == GlobalConstants.RELATED_CONTACT_RELATED_CONTACT_TYPE ? GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE : GlobalConstants.CONTACT_GENERAL_CONTACT;
        relatedContactRecordDetails.Related_Application__c = registerCasedata.id;
        
        System.debug('Related Contact: '+relatedContactRecordDetails);
        System.debug('Related Contact: '+relatedContactRecordDetails.First_Given_Name__c);
        
        upsert relatedContactRecordDetails;
        
        Case updateCaseSubject = [SELECT Subject from Case WHERE Id =:registerCasedata.id];
        updateCaseSubject.Subject = String.isBlank(updateCaseSubject.Subject) ? caseSubjectPrefix + ' - ' +'Agent Account Application' : updateCaseSubject.Subject;
        updateCaseSubject.Description = String.isBlank(updateCaseSubject.Subject) ? caseSubjectPrefix + ' - ' +'Agent Account Application' : updateCaseSubject.Subject;
        
        update updateCaseSubject;
        
        if(relatedContactRecordDetails.Date_of_Birth__c != null)
            relatedContactRecordDetails.Date_of_Birth__c = Date.newInstance(relatedContactRecordDetails.Date_of_Birth__c.Year(), relatedContactRecordDetails.Date_of_Birth__c.Month(), relatedContactRecordDetails.Date_of_Birth__c.Day());
        
        return relatedContactRecordDetails;
    }
}