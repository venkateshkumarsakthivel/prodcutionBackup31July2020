/**
* Apex controller created for ASPNotifiableFormAuthorisation. 
* Server side class for fetching authorisation details and creating Notifiable Occurrence Case.
*/


public without sharing class ASPNotifiableFormAuthorisation {
    
    
    //function returns selected Authorisation details.
    @AuraEnabled
    public static String getAuthorisation(String authorisationId){
        System.debug('Auth is :' + authorisationId);
        Authorisation__c authorisation = [SELECT Id, Name, Service_Provider__r.Name,Contact__r.Id, Contact__r.Name, Contact__r.Role__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.State__c, Contact__r.Phone FROM Authorisation__c where Id =: authorisationId];
        return JSON.serialize(authorisation);
    }
    
    //function returns selected Case details.
    @AuraEnabled
    public static String getCaseDetails(String caseId){
        System.debug('caseId is :' + caseId);
        Case caseDetails = [SELECT Id, Account.Name,Authorisation__r.Name,
                            Contact.FirstName, Contact.LastName,Description_of_follow_up_action__c,
                            Contact.Email,ContactPhone,Commencement_Date_Time__c,Became_Aware_Date_Time__c,
                            City__c, State__c, Postcode__c,Street_Address_Line_1__c,A__c,B__c,C__c,D__c,E__c,
                            Full_Occurrence_description__c,Description_of_cause_contributing_factor__c,Covid_Notifiable_Occurence__c
                            FROM Case WHERE Id =: caseId];
        return JSON.serialize(caseDetails);
    }
    
    //function returns selected Authorisation details.
    @AuraEnabled
    public static String getLoggedInUserContact(){
        
        System.debug('In User method');
        String loggedInUserId = UserInfo.getUserId();
        User loggedInUserContactId = [SELECT ContactId from USER WHERE Id =: loggedInUserId];
        String userContactId = loggedInUserContactId.ContactId;
        
        Contact userLoggedInContactDetails = [SELECT Id, FirstName, LastName, Name, Email, Title,Role__c, Phone from Contact where Id =: userContactId];
        return JSON.serialize(userLoggedInContactDetails);
        
        //System.debug('Auth is :' + authorisationId);
        //Authorisation__c authorisation = [Select Id, Name, Service_Provider__r.Name,Contact__r.Id, Contact__r.Name, Contact__r.Role__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.State__c, Contact__r.Phone FROM Authorisation__c where Id =: authorisationId];
        //return JSON.serialize(authorisation);
    }
    
    //function creates a case with record type as "Notifiable Occurrence" with the fetched Authorisation details.
    @AuraEnabled
    public static String createNotifiableOccurenceCase(String data){
        
        
        System.debug('Details of NO case to be created: ' +data);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_NOTIFIABLE_OCCURRENCE).getRecordTypeId();
        
        ASPNotifiableCaseAttributes newCase = (ASPNotifiableCaseAttributes) System.JSON.deserialize(data, ASPNotifiableCaseAttributes.class);
        
        Case notifiableOccurrence = new Case();
        
        notifiableOccurrence.RecordTypeId = recordTypeId;
        notifiableOccurrence.Covid_Notifiable_Occurence__c= newCase.CovidNO;
        notifiableOccurrence.Status = GlobalConstants.CASE_NEW;
        notifiableOccurrence.Origin = GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL;
        
        notifiableOccurrence.AccountId = newCase.accId;
        notifiableOccurrence.Authorisation__c = newCase.authId;
        notifiableOccurrence.ContactId = newCase.contactId;
        
        notifiableOccurrence.Subject = newCase.accountName;
        notifiableOccurrence.Description = 'Notifiable Occurrence reported by '+newCase.contactName;
        notifiableOccurrence.Commencement_Date_Time__c = newCase.no_date;
        notifiableOccurrence.Became_Aware_Date_Time__c = newCase.no_Became_Aware_Date_Time;
        notifiableOccurrence.Street_Address_Line_1__c = newCase.streetadd;
        notifiableOccurrence.City__c= newCase.cityadd;
        notifiableOccurrence.State__c = newCase.stateadd;
        notifiableOccurrence.Postcode__c= newCase.postCodeadd;
        
        notifiableOccurrence.A__c = newCase.a;
        notifiableOccurrence.B__c = newCase.b;
        notifiableOccurrence.C__c = newCase.c;
        notifiableOccurrence.D__c = newCase.d;
        notifiableOccurrence.E__c = newCase.e;
        
        notifiableOccurrence.Full_Occurrence_description__c = newCase.occurenceDesc;
        notifiableOccurrence.Description_of_cause_contributing_factor__c = newCase.contFact;
        notifiableOccurrence.Description_of_follow_up_action__c  = newCase.followDesc;
        
        System.debug('RecordTypeId: ' + recordTypeId);
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = TRUE;
        dmo.EmailHeader.triggerUserEmail = TRUE ;
        notifiableOccurrence.setOptions(dmo);
        
        System.debug('DMO :'+dmo);
        System.debug('Hi there');
        
        //insert notifiableOccurrence Case with case assignment rule and email notification enabled.
        Database.insert(notifiableOccurrence, dmo);
        
        return JSON.serialize(notifiableOccurrence);
        
    }
}