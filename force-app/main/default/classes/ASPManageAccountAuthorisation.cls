/*
Server side rest resource controller for Authorisation section of Accounts tab
*/
public without sharing class ASPManageAccountAuthorisation {
    
    //method to return the account name of logged in community user
    @AuraEnabled
    public static String getLoggedInUserAccount(){  
        User loggedInUser = GlobalUtility.getLoggedInUser();
        Account act = loggedInUser.Account;
        return JSON.serialize(act); 
    } 
    
    //method to fetch list of Notifiable Occurrences records belonging to community user's account
    @AuraEnabled
    public static List<Case> getNotifiableOccurrencesRecords() {
        try{
            Id caseNotifiableOccurrenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_LABEL_NOTIFIABLE_OCCURRENCE).getRecordTypeId();
            User loggedInUser = GlobalUtility.getLoggedInUser();
            List<Case> notifiableOccurrencesList = [SELECT Id, CaseNumber,Authorisation__r.Name,
                                                    Commencement_Date_Time__c,
                                                    Postcode__c,
                                                    City__c,State__c,Street_Address_Line_1__c
                                                    FROM Case 
                                                    WHERE AccountId = :loggedInUser.AccountId
                                                    AND RecordTypeId = :caseNotifiableOccurrenceRecordTypeId
                                                    ORDER BY CaseNumber ASC];
            return notifiableOccurrencesList;   
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','getNotifiableOccurrencesRecords',ex.getMessage(),ex);
            return null;
        }   
    }
    
    //method to fetch list of authorisation records belonging to community user's account
    @AuraEnabled
    public static List<Authorisation__c> getAuthorisationRecords() {
        try{
            List<String> authorisationTypes = new List<String>{GlobalConstants.AUTHORISATION_TYPE_TSP, GlobalConstants.AUTHORISATION_TYPE_BSP};
                
                List<String> activeAuthorisationStatus = new List<String>{GlobalConstants.GRANTED_UNCONDITIONALLY, GlobalConstants.GRANTED_CONDITIONALLY, GlobalConstants.AUTHORISATION_SUSPENDED };
                    
                    User loggedInUser = GlobalUtility.getLoggedInUser();
            List<Authorisation__c> authorisationList = [SELECT Id, Authorisation_Type__c, Name, Start_Date__c, End_Date__c,
                                                        Status__c, Service_Provider__r.Name, isGranted__c,
                                                        Decision_Reason__c, Decision_Made_By__c, 
                                                        Return_Requested__c, Renewal_Requested__c 
                                                        FROM Authorisation__c 
                                                        WHERE Service_Provider__c = :loggedInUser.AccountId
                                                        AND Status__c IN :activeAuthorisationStatus
                                                        AND Authorisation_Type__c IN :authorisationTypes
                                                        ORDER BY CreatedDate DESC];
            return authorisationList;   
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','getAuthorisationRecords',ex.getMessage(),ex);
            return null;
        }   
    }
    
    //method to log return request for the selected authorisation record
    @AuraEnabled
    public static String surrenderAuthorisation(String authorisationId, String surrenderdate) {
        try {
            List<Authorisation__c> authorisationList = [SELECT Id, Authorisation_Type__c, Name, Start_Date__c, End_Date__c,
                                                        Status__c, Service_Provider__r.Name, Service_Provider__r.Notice_Email__c, isGranted__c,
                                                        Decision_Made_By__c, Decision_Reason__c, Record_Type_Dev_Name__c
                                                        FROM Authorisation__c
                                                        WHERE Id = :authorisationId];
            
            if(authorisationList.size() > 0) {
                
                User loggedInUser = GlobalUtility.getLoggedInUser();
                authorisationList[0].Decision_Made_By__c = UserInfo.getUserId();
                authorisationList[0].Decision_Reason__c = GlobalConstants.AUTHORISATION_SURRENDER_REASON;
                authorisationList[0].Return_Requested__c = TRUE;
                authorisationList[0].Surrender_Date__c= date.valueOf(surrenderdate);
                authorisationList[0].Decision_Date__c= date.valueOf(surrenderdate);
                update authorisationList;
                
                //Id supportRequestCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                Id returnRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
                
                Case newSupportCase = new Case();
                newSupportCase.Subject = GlobalConstants.SURRENDER_AUTHORISATION_CASE_SUBJECT;
                newSupportCase.Date_Submitted__c = System.now();
                newSupportCase.RecordTypeId = returnRecordTypeId;
                newSupportCase.AccountId = loggedInUser.AccountId;
                newSupportCase.ContactId = loggedInUser.ContactId;
                // Adding Surrender date for conga template:Notice of Voluntary Surrender 
                newSupportCase.ASPSurrenderDate__c = date.valueOf(surrenderdate);
                newSupportCase.Authorisation__c = authorisationList[0].Id;
                
                
                if(authorisationList[0].Record_Type_Dev_Name__c != GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME) {
                    
                    newSupportCase.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
                }
                else {
                    
                    newSupportCase.Type = GlobalConstants.CASE_TAXI_TYPE;
                }
                
                newSupportCase.Sub_Type__c = GlobalConstants.CASE_VOLUNTARY_RETURN_SUB_TYPE;
                newSupportCase.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
                
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                newSupportCase.setOptions(dmo);
                
                insert newSupportCase;
                
                newSupportCase = [SELECT CaseNumber FROM Case WHERE Id = :newSupportCase.Id];
                
                authorisationList[0].Related_Request_Case_Id__c = newSupportCase.Id;
                authorisationList[0].Decision_Made_By__c = UserInfo.getuserId();
                authorisationList[0].Decision_Reason__c = GlobalConstants.SURRENDER_AUTHORISATION_CASE_SUBJECT;
                
                update authorisationList[0];
                
                return newSupportCase.CaseNumber;
            }
            return NULL;
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','surrenderAuthorisation',ex.getMessage(),ex);
            return null;
        }
    }
    
    //method to log renewal request for the selected authorisation record
    @AuraEnabled
    public static String renewAuthorisation(String authorisationId) {
        
        try {
            List<Authorisation__c> authorisationList = [SELECT Id, Application__c 
                                                        FROM Authorisation__c
                                                        WHERE Id = :authorisationId
                                                        AND Application__c != NULL];
            
            if(authorisationList.size() > 0) {
                
                authorisationList[0].Renewal_Requested__c = TRUE;
                
                update authorisationList[0];
                
                Case renewalApplication = new Case();
                
                renewalApplication.Status = GlobalConstants.CASE_DRAFT; 
                renewalApplication.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
                renewalApplication.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
                
                insert renewalApplication;
                
                List<Authorisation_Contact__c> authContacts = [SELECT Id, Email__c, 
                                                               Daytime_Phone__c, Contact_Type__c, 
                                                               Contact__r.FirstName, Contact__r.LastName,
                                                               Contact__r.MailingCity, Contact__r.MailingCountry, 
                                                               Contact__r.MailingStreet, Contact__r.MailingPostalCode, 
                                                               Contact__r.MailingState, Contact__r.Birthdate, 
                                                               Contact__r.Australian_Driver_Licence_Number__c, 
                                                               Contact__r.Ever_been_known_by_another_name__c,
                                                               Contact__r.Other_given_name__c, Contact__r.Other_Name_Details__c, 
                                                               Contact__r.State__c, Contact__r.Title
                                                               FROM Authorisation_Contact__c
                                                               WHERE Authorisation__c = :authorisationId];
                
                List<Related_Contact__c> clonedContacts = new List<Related_Contact__c>();
                Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_RECORD_TYPE_INDIVIDUAL).getRecordTypeId();
                for(Authorisation_Contact__c tempContact : authContacts) {
                    Related_Contact__c clonedRelatedContact = createRelatedContact(tempContact);
                    clonedRelatedContact.RecordTypeId = indivRecordTypeId;
                    clonedRelatedContact.Related_Application__c = renewalApplication.Id;
                    clonedContacts.add(clonedRelatedContact);
                }
                
                if(clonedContacts.size() > 0)
                    insert clonedContacts;
                
                return renewalApplication.Id;
            }
            
            return NULL;
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','renewAuthorisation',ex.getMessage(),ex);
            return null;
        }
    }
    
    public static Related_Contact__c createRelatedContact(Authorisation_Contact__c tempContact){
        Related_Contact__c clonedRelatedContact = new Related_Contact__c();
        clonedRelatedContact.Australian_Driver_Licence__c = tempContact.Contact__r.Australian_Driver_Licence_Number__c;
        clonedRelatedContact.Date_of_Birth__c = tempContact.Contact__r.Birthdate;
        clonedRelatedContact.Daytime_Phone__c = tempContact.Daytime_Phone__c;
        clonedRelatedContact.Email__c = tempContact.Email__c;
        clonedRelatedContact.Family_Name__c = tempContact.Contact__r.LastName;
        clonedRelatedContact.First_Given_Name__c = tempContact.Contact__r.FirstName;
        clonedRelatedContact.Known_by_Other_Names_Details__c = tempContact.Contact__r.Other_Name_Details__c;
        clonedRelatedContact.Have_been_known_by_other_names__c = tempContact.Contact__r.Ever_been_known_by_another_name__c == GlobalConstants.YES_VALUE ? true : false;
        clonedRelatedContact.Australian_Driver_Licence_State__c = tempContact.Contact__r.State__c;
        clonedRelatedContact.Other_Given_Name__c = tempContact.Contact__r.Other_given_name__c;
        clonedRelatedContact.Related_Contact__c = tempContact.Contact__c;
        clonedRelatedContact.Residential_Address_City__c = tempContact.Contact__r.MailingCity;
        clonedRelatedContact.Residential_Address_Country__c = tempContact.Contact__r.MailingCountry;
        clonedRelatedContact.Residential_Address_Postcode__c = tempContact.Contact__r.MailingPostalCode;
        clonedRelatedContact.Residential_Address_State__c = tempContact.Contact__r.MailingState;
        clonedRelatedContact.Residential_Address_Street__c = tempContact.Contact__r.MailingStreet;
        clonedRelatedContact.Title__c = tempContact.Contact__r.Title;
        
        return clonedRelatedContact;
    }
}