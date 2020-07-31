/**
* Server side rest resource controller for fetching section data in ASP form 
*/
public without sharing class ASPFormSectionDataController {
    
    //function returns data for section of ASP form
    @AuraEnabled
    public static String getSectionData(String caseId) {       
        try {
            User loggedInUser = GlobalUtility.getLoggedInUser();    
            SectionDataWrapper tempSectionDataWrapper;
            if(loggedInUser.AccountId != null){
                tempSectionDataWrapper = new SectionDataWrapper(caseId, loggedInUser.AccountId);
            } else {
                tempSectionDataWrapper = new SectionDataWrapper(caseId, null);
            }
            tempSectionDataWrapper.loadCaseSectionData();
            
           // System.debug(JSON.serialize(tempSectionDataWrapper.currentCaseRec));
            
            return JSON.serialize(tempSectionDataWrapper.currentCaseRec);
        } catch(Exception e) {
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns data for section of ASP form using account id
    @AuraEnabled
    public static String getAccountSectionData(String accountId) {
        try {            
            SectionDataWrapper tempSectionDataWrapper = new SectionDataWrapper(null, accountId);
            tempSectionDataWrapper.loadCaseSectionData();
            
            System.debug(JSON.serialize(tempSectionDataWrapper.currentCaseRec));
            
            return JSON.serialize(tempSectionDataWrapper.currentCaseRec);
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getAccountSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns entity type of account of logged in user
    @AuraEnabled
    public static String getEntityType(String caseId) {
        try{
            
            if(caseId != null) {                
                Case applicationCase = [SELECT Account.Record_Type_Dev_Name__c
                                        FROM Case
                                        WHERE Id = :caseId];                
                return getAccEntityType(applicationCase.Account.Record_Type_Dev_Name__c);                  
            }
            else {                
                User loggedInUser = GlobalUtility.getLoggedInUser();                
                return getAccEntityType(loggedInUser.Account.Record_Type_Dev_Name__c);
            }
        }catch(Exception e) {
            
            System.debug('Exception: '+e.getLineNumber());
            System.debug('Exception: '+e.getMessage());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getEntityType', e.getMessage(), e);
            return NULL;
        }
    }
    
    private static String getAccEntityType(String recordTypeName){
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
            return 'Company';
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
            return 'Individual';
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP)
            return 'Individual Partner';
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP)
            return 'Company Partner';
        
        return 'Individual';
    }
    
    //function returns entity type of account of logged in user
    @AuraEnabled
    public static String getAccountEntityType(String applicantAccountId) {
        try{
            
            if(applicantAccountId != null) {
                
                Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                            FROM Account
                                            WHERE Id = :applicantAccountId];
                
                return getAccEntityType(applicantAccount.Record_Type_Dev_Name__c);
            } else {                
                User loggedInUser = GlobalUtility.getLoggedInUser();
                return getAccEntityType(loggedInUser.Account.Record_Type_Dev_Name__c);                
            }
        }catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getAccountEntityType', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns type of logged in user
    @AuraEnabled
    public static String getUserType() {
        User loggedInUser = GlobalUtility.getLoggedInUser();
        return loggedInUser.UserType;        
    }
    
    //function saves data for individual section of ASP form
    @AuraEnabled
    public static String saveSectionData(String caseData) {
        try {
            
            Case caseRecToSave = (Case)JSON.deserialize(caseData, Case.class);
            System.debug('Case record to save: '+caseRecToSave);
            
            //process additional checks
            processAdditionalChecks(caseRecToSave);
            System.debug('@@caseRecToSave: ' + caseRecToSave);
            upsert caseRecToSave;
            
            caseRecToSave = [SELECT AccountId, Account.Record_Type_Dev_Name__c 
                             FROM Case
                             WHERE Id = :caseRecToSave.Id];
            
            return getAccEntityType(caseRecToSave.Account.Record_Type_Dev_Name__c) 
                + '-' + caseRecToSave.Id;            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    
    @AuraEnabled
    public static String saveApplicantData(String applicantData) {
        
        try {
            
            System.debug('Case record to save: '+applicantData);
            
            Related_Contact__c applicantRecToSave = (Related_Contact__c)JSON.deserialize(applicantData, Related_Contact__c.class);
            
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            applicantRecToSave.RecordTypeId = indivRecordTypeId;
            
            applicantRecToSave.Applicant_Details__c = True;
            upsert applicantRecToSave;
            
            System.debug('Case record to save: '+applicantRecToSave.Id);                        
            
            return applicantRecToSave.Id;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveApplicantData', e.getMessage(), e);
            return NULL;
        }
    }
    
    
    @AuraEnabled
    public static String getApplicantDetails(String caseId) {
        
        List<Related_Contact__c> applicantsData = [SELECT Id, Related_Application__c,Title__c, Family_Name__c, First_Given_Name__c, 
                                                   Other_given_name__c, Date_of_Birth__c, Australian_Driver_Licence__c, 
                                                   Australian_Driver_Licence_State__c, Daytime_Phone__c, Email__c, Known_by_Other_Names_Details__c, 
                                                   Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c, 
                                                   Residential_Address_Postcode__c, Contact_Type__c, 
                                                   Have_been_known_by_other_names__c, Related_Contact__c, Role__c,
                                                   Proof_Of_Company_Extract__c, Proof_Of_Criminal_History_Check__c,
                                                   Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, Proof_Of_Endorsement_By_Director_Company__c,
                                                   Country_Stayed_During_Last_5_Years__c, Resided_In_Australia_For_Past_5_Years__c,
                                                   Corp_Convicted_Of_Disqualifying_Offence__c, Corp_Disqualifying_Offence_Details__c,
                                                   Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c,
                                                   Has_had_authorisation_refused__c, Auth_Refusal_Details__c,
                                                   Authorisation_Cancelled__c, Auth_Cancellation_Details__c
                                                   FROM Related_Contact__c
                                                   WHERE Applicant_Details__c = TRUE
                                                   AND Related_Application__c = :caseId
                                                   ORDER BY CreatedDate DESC];
        
        if(applicantsData.isEmpty()) {
            
            User userDetails = GlobalUtility.getLoggedInUser();
            
            if(userDetails.ContactId != null) {
            
                Related_Contact__c relContact = new Related_Contact__c();
                
                if(GlobalUtility.getLoggedInUser().ContactId != NULL) {
                
                 relContact.Title__c = userDetails.Contact.Salutation;
                 relContact.Family_Name__c = userDetails.Contact.LastName;
                 relContact.First_Given_Name__c = userDetails.Contact.FirstName;
                 relContact.Other_given_name__c = userDetails.Contact.Other_given_name__c;
                 relContact.Date_of_Birth__c = userDetails.Contact.Birthdate;
                 relContact.Australian_Driver_Licence__c = userDetails.Contact.Australian_Driver_Licence_Number__c;
                 relContact.Australian_Driver_Licence_State__c = userDetails.Contact.State__c;
                 relContact.Daytime_Phone__c = userDetails.Contact.Phone;
                 relContact.Known_by_Other_Names_Details__c = userDetails.Contact.Other_Name_Details__c;
                 relContact.Residential_Address_City__c = userDetails.Contact.MailingCity;
                 relContact.Residential_Address_Postcode__c  = userDetails.Contact.MailingPostalcode;
                 relContact.Residential_Address_State__c = userDetails.Contact.MailingState;
                 relContact.Residential_Address_Street__c = userDetails.Contact.MailingStreet;
                 relContact.Contact_Type__c = userDetails.Contact.Contact_Type__c;
                 relContact.Related_Contact__c = userDetails.ContactId;
                 relContact.Role__c = userDetails.Contact.Role__c;
                }
                
                
                relContact.Email__c = userDetails.Email;
                relContact.Applicant_Details__c = true;                
                relContact.RecordTypeId  = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
                
                return JSON.serialize(relContact);
            } else {
                return null;
            }           
        }
        return JSON.serialize(applicantsData[0]);        
    }
    
    //method to fetch nominated directors data associate with a case
    @AuraEnabled
    public static String getNominatedDirectors(String caseId) {
        try{
            List<Related_Contact__c> nominatedDirectors = [SELECT Id, First_Given_Name__c, Family_Name__c,
                                                           Title__c, Daytime_Phone__c, Date_of_Birth__c, Email__c,
                                                           Other_Given_Name__c,Australian_Driver_Licence_State__c,
                                                           Australian_Driver_Licence__c, Known_by_Other_Names_Details__c, 
                                                           Residential_Address_City__c, Residential_Address_Street__c, 
                                                           Residential_Address_Postcode__c, Residential_Address_State__c,
                                                           Have_been_known_by_other_names__c, Contact_Type__c, Role__c,
                                                           Proof_Of_Company_Extract__c, Proof_Of_Criminal_History_Check__c,
                                                           Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, 
                                                           Proof_Of_Endorsement_By_Director_Company__c, Proof_of_Director_Appointment__c
                                                           FROM Related_Contact__c 
                                                           WHERE Related_Application__c = :caseId
                                                           AND Applicant_Details__c = FALSE 
                                                           AND Contact_Type__c = :GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
                                                           AND Primary_Contact__c = FALSE
                                                           ORDER BY CreatedDate ASC Limit 3];
            
            
            if(nominatedDirectors.isEmpty()) {    
                nominatedDirectors.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE));
            }
            
            if(nominatedDirectors.size() == 1) {
                nominatedDirectors.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE));
            }
            
            if(nominatedDirectors.size() == 2) {
                nominatedDirectors.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE));
            }
            
            return JSON.serialize(nominatedDirectors);
        } catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getNominatedDirectors', e.getMessage(), e);
            return Null;
        }
    }
    
    //function saves data for nominated director/manager section of ASP form
    @AuraEnabled
    public static String saveNominatedDirectors(String directorsData) {
        
        
        try {
            
            List<Related_Contact__c> directorsToSave = (List<Related_Contact__c>)JSON.deserialize(directorsData, List<Related_Contact__c>.class);
            System.debug('Directors to save: '+directorsToSave);
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c director : directorsToSave){
                director.RecordTypeId = indivRecordTypeId;
            }
            
            System.debug('@@directorsToSave: '+directorsToSave);
            
            if(directorsToSave.size() > 0)
                upsert directorsToSave;
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :directorsToSave[0].Related_Application__c];    
            
            Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                        FROM Account
                                        WHERE Id = :applicantApplication.AccountId];
            
            return getAccEntityType(applicantAccount.Record_Type_Dev_Name__c) 
                + '-' + directorsToSave[0].Related_Application__c;            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e.getMessage());
            System.debug('Exception: '+e.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveNominatedDirectors', e.getMessage(), e);
            return NULL;
        }
    }
    
    
    //function deletes data for nominated director/manager section of ASP form
    @AuraEnabled
    public static void deleteNominatedDirectors(String directorsData) {
        
        try {
            
            List<Related_Contact__c> directorsToDelete = (List<Related_Contact__c>)JSON.deserialize(directorsData, List<Related_Contact__c>.class);
            System.debug('Directors to delete: '+directorsToDelete);
            
            if(directorsToDelete.isEmpty())
                delete directorsToDelete;
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'deleteNominatedDirectors', e.getMessage(), e);
            
        }
    }  
    
    //method to return accountId of the application to resume
    @AuraEnabled
    public static String getAccountId(String resumedCase){
        
        try {
            
            Case applicationCase = [SELECT AccountId 
                                    FROM Case 
                                    WHERE AccountId != NULL
                                    AND Id = :resumedCase];
            
            return applicationCase.AccountId;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getAccountId', e.getMessage(), e);
            return 'ERROR';
        }
    }
    
    //function return status of the requested case using id
    @AuraEnabled
    public static String getCaseStatus(String caseId) {
        
        
        try{  
            
            Case requestedCase = [SELECT Status, Account.Record_Type_Dev_Name__c
                                  FROM Case
                                  WHERE Id = :caseId];
            
            String entityType;
            
            entityType =  getAccEntityType(requestedCase.Account.Record_Type_Dev_Name__c);
            return requestedCase.Status+'-split-'+entityType;
            
        }catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getCaseStatus', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function saves data for Corporate Partnership section of ASP form
    @AuraEnabled
    public static String saveCorporatePartnershipData(String corporatesData, String applicantsData) {
        
        try {
            List<Related_Contact__c> corporateContactsToSave = (List<Related_Contact__c>)JSON.deserialize(corporatesData, List<Related_Contact__c>.class);
            System.debug('[Corporate Partnership - Corporate Section] Related Contacts to save: ' + corporateContactsToSave);
            
            Id corpRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c corpCon : corporateContactsToSave){
                corpCon.RecordTypeId = corpRecordTypeId;
            }
            
            List<Related_Contact__c> applicantContactsToSave = (List<Related_Contact__c>)JSON.deserialize(applicantsData, List<Related_Contact__c>.class);
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c indivCon: applicantContactsToSave){
                indivCon.RecordTypeId = indivRecordTypeId;
            }
            System.debug('[Corporate Partnership - Applicant Section] Related Contacts to save: ' + applicantContactsToSave);
            
            if(corporateContactsToSave.size() > 0)
                upsert corporateContactsToSave;
            
            for(Integer i = 0; i < corporateContactsToSave.size(); i++) {
                
                applicantContactsToSave[i].Related_Corporate__c = corporateContactsToSave[i].Id;
            }
            
            if(applicantContactsToSave.size() > 0)
                upsert applicantContactsToSave;
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :corporateContactsToSave[0].Related_Application__c];    
            
            Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                        FROM Account
                                        WHERE Id = :applicantApplication.AccountId];
            
            return getAccEntityType(applicantAccount.Record_Type_Dev_Name__c) 
                + '-' + corporateContactsToSave[0].Related_Application__c;            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e.getMessage());
            System.debug('Exception: '+e.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveCorporatePartnershipData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function deletes data for Corporate Partnership section of ASP form 
    //This method deletes realated contacts asociated with Case of Type Corporate Partners and associated Nominated Directors 
    @AuraEnabled
    public static void deleteCorporatePartnershipData(String corporatesData, String applicantsData) {
        
        try {
            List<Related_Contact__c> corporateContactsToDelete = (List<Related_Contact__c>)JSON.deserialize(corporatesData, List<Related_Contact__c>.class);
            System.debug('[Corporate Partnership - Corporate Section] Related Contacts to delete: ' + corporateContactsToDelete);
            
            List<Related_Contact__c> applicantContactsToDelete = (List<Related_Contact__c>)JSON.deserialize(applicantsData, List<Related_Contact__c>.class);
            System.debug('[Corporate Partnership - Applicant Section] Related Contacts to delete: ' + applicantContactsToDelete);
            
            if(corporateContactsToDelete.size() > 0)
                delete corporateContactsToDelete;
            
            if(applicantContactsToDelete.size() > 0)
                delete applicantContactsToDelete;
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'deleteCorporatePartnershipData', e.getMessage(), e);
        }
    } 
    
    //function to fetch  data for Corporate Partnership section of ASP form
    @AuraEnabled
    public static String getCorporatePartnershipData(String caseId) {
        
        try {
            
            List<Related_Contact__c> corporateContacts = [SELECT Id, Contact_Type__c, Related_Corporate__c,
                                                          Corporation_name__c, ACN__c, Daytime_Phone__c, Email__c, Registered_business_name__c, ABN__c,
                                                          Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c,
                                                          Is_current_authorised_service_provider__c, Current_ASP_Details__c, Does_ASP_have_additional_standards__c, ASP_additional_standard_details__c,
                                                          Has_authorisation_subject_to_action__c, Auth_Action_Details__c, Has_had_authorisation_refused__c, Auth_Refusal_Details__c ,   
                                                          Is_Nominee_of_Good_repute__c, Nominee_Not_of_Good_Repute_Details__c,
                                                          Resided_In_Australia_For_Past_5_Years__c, Country_Stayed_During_Last_5_Years__c,
                                                          Number_Type__c, Website__c, Role__c, Corp_Convicted_Of_Disqualifying_Offence__c, Corp_Disqualifying_Offence_Details__c,
                                                          Proof_Of_Company_Extract__c, Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, Proof_Of_Endorsement_By_Director_Company__c,
                                                          Proof_Of_Criminal_History_Check__c, Close_Associate_Info_Provided__c, 
                                                          Authorisation_Cancelled__c, Auth_Cancellation_Details__c, Primary_Contact__c
                                                          FROM Related_Contact__c 
                                                          WHERE Related_Application__c = :caseId 
                                                          AND Contact_Type__c = :GlobalConstants.CONTACT_CORPORATE_PARTNERSHIP_TYPE
                                                          ORDER BY CreatedDate ASC];
            Set<Id> parentRecordIds = new Set<Id>();
            for(Related_Contact__c corporateContact : corporateContacts) {
                parentRecordIds.add(corporateContact.Id);
            }
            
            List<Related_Contact__c> applicantContacts = [SELECT Id, Contact_Type__c, Related_Corporate__c,
                                                          Title__c, Date_of_Birth__c,
                                                          First_Given_Name__c, Family_Name__c, Other_Given_Name__c,
                                                          Email__c, Daytime_Phone__c, Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                          Have_been_known_by_other_names__c, Known_by_Other_Names_Details__c,
                                                          Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c, 
                                                          Residential_Address_Postcode__c, Residential_Address_Country__c,
                                                          Resided_In_Australia_For_Past_5_Years__c, Country_Stayed_During_Last_5_Years__c,
                                                          Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c,
                                                          Corp_Convicted_Of_Disqualifying_Offence__c, Corp_Disqualifying_Offence_Details__c,
                                                          Proof_Of_Company_Extract__c, Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, Proof_Of_Endorsement_By_Director_Company__c,
                                                          Proof_Of_Criminal_History_Check__c, Close_Associate_Info_Provided__c, 
                                                          Authorisation_Cancelled__c, Has_had_authorisation_refused__c,
                                                          Auth_Cancellation_Details__c, Auth_Refusal_Details__c,
                                                          Number_Type__c, Role__c, Primary_Contact__c
                                                          FROM Related_Contact__c 
                                                          WHERE Related_Corporate__c IN :parentRecordIds
                                                          ORDER BY CreatedDate ASC];
            
            List<Related_Contact__c> sortedApplicantContacts = new List<Related_Contact__c>();
            
            for(Related_Contact__c parentContact : corporateContacts) {
                
                for(Related_Contact__c childContact : applicantContacts) {
                    
                    if(parentContact.Id == childContact.Related_Corporate__c) {
                        sortedApplicantContacts.add(childContact);
                        break;
                    }
                }
            }
            
            if(corporateContacts.isEmpty()) {  
                Case currentCase = [SELECT Account.Name, Account.ACN__c, Account.Registered_Business_Name__c From Case Where ID = :caseId ];
                
                corporateContacts.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_CORPORATE_PARTNERSHIP_TYPE, 
                                                             Corporation_Name__c = currentCase.Account.Name, ACN__c = currentCase.Account.ACN__c, 
                                                             Registered_Business_Name__c = currentCase.Account.Registered_Business_Name__c));
                
                
                sortedApplicantContacts.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE));
            }
            
            Map<String, List<Related_Contact__c>> data = new Map<String, List<Related_Contact__c>>
            {'parentContacts' => corporateContacts, 'childContacts' => sortedApplicantContacts};
                
                String jsonResult = JSON.serialize(data);
            
            System.debug('getCorporatePartnershipData Result: ' + jsonResult );
            
            return jsonResult;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getCorporatePartnershipData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function to fetch  data for Individual Partnership section of ASP form
    @AuraEnabled
    public static String getIndividualPartnershipData(String caseId) {
        
        try {
            
            List<Related_Contact__c> individualContacts = [SELECT Id, Contact_Type__c, Related_Corporate__c,
                                                           Title__c, First_Given_Name__c, Family_Name__c, Other_Given_Name__c, Date_of_Birth__c,
                                                           Have_been_known_by_other_names__c, Known_by_Other_Names_Details__c, Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                           Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c,
                                                           Residential_Address_Postcode__c, Residential_Address_Country__c, Residential_International_Address__c,
                                                           Daytime_Phone__c, Email__c, ABN__c, Registered_business_name__c,
                                                           Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c, Is_current_authorised_service_provider__c, Current_ASP_Details__c,
                                                           Does_ASP_have_additional_standards__c, ASP_additional_standard_details__c, Has_authorisation_subject_to_action__c, Auth_Action_Details__c,
                                                           Has_had_authorisation_refused__c, Auth_Refusal_Details__c, Close_Associate_Info_Provided__c,
                                                           Proof_Of_National_Police_Check__c, Proof_Of_Police_Certificate_From_Country__c,
                                                           Proof_Of_Identity_Documents__c, Proof_Of_Partnership_Declaration__c,
                                                           Resided_In_Australia_For_Past_5_Years__c, Country_Stayed_During_Last_5_Years__c,
                                                           Primary_Contact__c
                                                           FROM Related_Contact__c 
                                                           WHERE Related_Application__c = :caseId 
                                                           AND Contact_Type__c = :GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE
                                                           ORDER BY CreatedDate ASC];
            
            Map<String, List<Related_Contact__c>> data = new Map<String, List<Related_Contact__c>>
            {'parentContacts' => individualContacts};
                
                String jsonResult = JSON.serialize(data);
            
            System.debug('getIndividualPartnershipData Result: ' + jsonResult );
            
            return jsonResult;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getIndividualPartnershipData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function saves data for Individual Partnership section of ASP form
    @AuraEnabled
    public static String saveIndividualPartnershipData(String individualsData) {
        
        try {
            
            List<Related_Contact__c> individualContactsToSave = (List<Related_Contact__c>)JSON.deserialize(individualsData, List<Related_Contact__c>.class);
            System.debug('[Individual Partnership - Individual Section] Related Contacts to save: ' + individualContactsToSave);
            
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c indivCon: individualContactsToSave){
                indivCon.RecordTypeId = indivRecordTypeId;
            }
            
            upsert individualContactsToSave;
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :individualContactsToSave[0].Related_Application__c];    
            
            Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                        FROM Account
                                        WHERE Id = :applicantApplication.AccountId];
            
            return getAccEntityType(applicantAccount.Record_Type_Dev_Name__c) 
                + '-' + individualContactsToSave[0].Related_Application__c;         
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveIndividualPartnershipData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function deletes data for Individual Partnership section of ASP form 
    //This method deletes realated contacts asociated with Case of Type Individual Partners and Close Associates 
    @AuraEnabled
    public static void deleteIndividualPartnershipData(String individualsData) {
        
        try {
            
            List<Related_Contact__c> individualContactsToDelete = (List<Related_Contact__c>)JSON.deserialize(individualsData, List<Related_Contact__c>.class);
            System.debug('[Individual Partnership - Individual Section] Related Contacts to delete: ' + individualContactsToDelete);
            
            delete individualContactsToDelete;
        }
        catch(Exception e) {            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'deleteIndividualPartnershipData', e.getMessage(), e);
        }
    } 
    
    
    //function to save data for Corporate/Individual Primary Contact of ASP form
    @AuraEnabled
    public static String savePrimaryContactData(String primaryContactData) {
    
      try {
      
       Related_Contact__c primaryContact = (Related_Contact__c) JSON.deserialize(primaryContactData, Related_Contact__c.class);
       upsert primaryContact;
       
       Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :primaryContact.Related_Application__c];    
            
       Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                   FROM Account
                                   WHERE Id = :applicantApplication.AccountId];
            
       return getAccEntityType(applicantAccount.Record_Type_Dev_Name__c) + '-' + primaryContact.Related_Application__c; 
       
      }
      catch(Exception e) {
            
        System.debug('Exception: '+ e);
        ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'saveCorporatePrimaryContactData', e.getMessage(), e);
        return NULL;
      }
    }
    
    //function to fetch data for Corporate Primary Contact of ASP form
    @AuraEnabled
    public static String getCorporatePrimaryContactData(String caseId) {
        
        try {
            
            String jsonResponse;
            Id corpRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            
            List<Related_Contact__c> corporateContacts = [SELECT Id, Contact_Type__c, Related_Corporate__c,
                                                          Corporation_Name__c, Family_Name__c, ACN__c, Daytime_Phone__c, Email__c, Website__c,
                                                          Registered_business_name__c, ABN__c, 
                                                          Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c,
                                                          Has_had_authorisation_refused__c, Auth_Refusal_Details__c,
                                                          Close_Associate_Info_Provided__c, Proof_Of_Company_Extract__c, Number_Type__c
                                                          FROM Related_Contact__c 
                                                          WHERE Related_Application__c = :caseId 
                                                          AND Contact_Type__c = :GlobalConstants.CONTACT_GENERAL_CONTACT
                                                          AND RecordTypeId = :corpRecordTypeId
                                                          ORDER BY CreatedDate DESC];
                                                          
            if(corporateContacts.size() > 0) {
              
              jsonResponse = JSON.serialize(corporateContacts[0]);
            }
            else {
              
              Related_Contact__c newPrimaryContact = new Related_Contact__c();
              newPrimaryContact.Related_Application__c = caseId;
              
              
              Case applicationCase = [SELECT Account.Name, Account.ACN__c, Account.ABN__c, Account.Registered_Business_Name__c
                                 FROM Case
                                 WHERE Id = :caseId];
                                 
              if(GlobalUtility.getLoggedInUser().ContactId != NULL) {
              
               newPrimaryContact.Corporation_Name__c = GlobalUtility.getLoggedInUser().Account.Name;
               newPrimaryContact.ACN__c = GlobalUtility.getLoggedInUser().Account.ACN__c;
               newPrimaryContact.ABN__c = GlobalUtility.getLoggedInUser().Account.ABN__c;
			   newPrimaryContact.Registered_Business_Name__c = GlobalUtility.getLoggedInUser().Account.Registered_Business_Name__c; 
              }
              else {
               
               newPrimaryContact.Corporation_Name__c = applicationCase.Account.Name;
               newPrimaryContact.ACN__c = applicationCase.Account.ACN__c;
               newPrimaryContact.ABN__c = applicationCase.Account.ABN__c;
			   newPrimaryContact.Registered_Business_Name__c = applicationCase.Account.Registered_Business_Name__c;
              }
              
              newPrimaryContact.RecordTypeId = corpRecordTypeId;
              jsonResponse = JSON.serialize(newPrimaryContact);
            }  
            
            
            return jsonResponse;  
                                                          
         }
         catch(Exception e) {
            
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getCorporatePartnershipData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function to fetch data for Individual Primary Contact of ASP form
    @AuraEnabled
    public static String getIndividualPrimaryContactData(String caseId) {
        
        try {
            
            String jsonResponse;
            Id individualRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            
            List<Related_Contact__c> individualContacts = [SELECT Id, Title__c, Contact_Type__c, Related_Corporate__c,
                                                          First_Given_Name__c, Family_Name__c, Other_Given_Name__c, Date_of_Birth__c, 
                                                          Daytime_Phone__c, Email__c, Website__c,
                                                          Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                          Registered_Business_Name__c, ABN__c, Related_Contact__c,
                                                          Known_by_Other_Names_Details__c, Proof_Of_Identity_Documents__c,
                                                          Residential_Address_City__c, Residential_Address_State__c,
                                                          Residential_Address_Postcode__c, Residential_Address_Street__c,
                                                          Residential_Address_Country__c, Residential_International_Address__c,
                                                          Has_convicted_or_disqualifying_offence__c, Disqualifying_Offence_Details__c,
                                                          Has_had_authorisation_refused__c, Auth_Refusal_Details__c,
                                                          Close_Associate_Info_Provided__c, Proof_Of_Company_Extract__c, Number_Type__c,
                                                          Country_Stayed_During_Last_5_Years__c, Proof_Of_National_Police_Check__c, 
                                                          Proof_Of_Police_Certificate_From_Country__c, Resided_In_Australia_For_Past_5_Years__c,
                                                          Is_current_authorised_service_provider__c, Business_Address_City__c,
                                                          Business_Address_Country__c, Business_Address_Postal_Code__c, Business_Address_State__c,
                                                          Business_Address_Street__c, Business_International_Address__c, 
                                                          Related_Application__r.Business_Address_City__c,
                                                          Related_Application__r.Business_Address_Country__c, Related_Application__r.Business_Address_Postal_Code__c, 
                                                          Related_Application__r.Business_Address_State__c,
                                                          Related_Application__r.Business_Address_Street__c, Related_Application__r.Business_International_Address__c,
                                                          Have_been_known_by_other_names__c
                                                          FROM Related_Contact__c 
                                                          WHERE Related_Application__c = :caseId 
                                                          AND Contact_Type__c = :GlobalConstants.CONTACT_GENERAL_CONTACT
                                                          AND RecordTypeId = :individualRecordTypeId
                                                          ORDER BY CreatedDate DESC];
                                                          
            if(individualContacts.size() > 0) {
              
               individualContacts[0].Business_Address_City__c = individualContacts[0].Related_Application__r.Business_Address_City__c;
                individualContacts[0].Business_Address_Country__c = individualContacts[0].Related_Application__r.Business_Address_Country__c;
                individualContacts[0].Business_Address_Postal_Code__c = individualContacts[0].Related_Application__r.Business_Address_Postal_Code__c;
                individualContacts[0].Business_Address_State__c = individualContacts[0].Related_Application__r.Business_Address_State__c;
                individualContacts[0].Business_Address_Street__c = individualContacts[0].Related_Application__r.Business_Address_Street__c;
                individualContacts[0].Business_International_Address__c = individualContacts[0].Related_Application__r.Business_International_Address__c;
              jsonResponse = JSON.serialize(individualContacts[0]);
            }
            else {
                Case caserec = [SELECT Business_Address_City__c, Business_Address_Country__c, Business_Address_Postal_Code__c, Business_Address_State__c,
                                Business_Address_Street__c, Business_International_Address__c, Account.ABN__c,Account.Registered_Business_Name__c FROM Case WHERE Id =: caseId];
                
                Related_Contact__c newPrimaryContact = new Related_Contact__c();
                newPrimaryContact.Related_Application__c = caseId;
                
                User currentUser = GlobalUtility.getLoggedInUser();
                if(currentUser.ContactId != NULL) {
                 
                 newPrimaryContact.First_Given_Name__c = currentUser.FirstName;
                 newPrimaryContact.Family_Name__c = currentUser.LastName;
                 newPrimaryContact.Title__c = currentUser.Contact.Salutation;
                 newPrimaryContact.Related_Contact__c = currentUser.Contact.Id;
                 newPrimaryContact.Email__c = currentUser.Email;
                 newPrimaryContact.ABN__c = GlobalUtility.getLoggedInUser().Account.ABN__c;
                 newPrimaryContact.Registered_Business_Name__c = GlobalUtility.getLoggedInUser().Account.Registered_Business_Name__c;   
                }
                
                newPrimaryContact.RecordTypeId = individualRecordTypeId;
                newPrimaryContact.Business_Address_City__c = caserec.Business_Address_City__c;
                newPrimaryContact.Business_Address_Country__c = caseRec.Business_Address_Country__c;
                newPrimaryContact.Business_Address_Postal_Code__c = caseRec.Business_Address_Postal_Code__c;
                newPrimaryContact.Business_Address_State__c = caseRec.Business_Address_State__c;
                newPrimaryContact.Business_Address_Street__c = caseRec.Business_Address_Street__c;
                newPrimaryContact.Business_International_Address__c = caseRec.Business_International_Address__c;
                newPrimaryContact.ABN__c = caseRec.Account.ABN__c;
                newPrimaryContact.Registered_Business_Name__c = caseRec.Account.Registered_Business_Name__c;
                
                jsonResponse = JSON.serialize(newPrimaryContact);
            }  
            
            
            return jsonResponse;  
                                                          
         }
         catch(Exception e) {
            
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'getIndividualPrimaryContactData', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static Boolean isApplicantFromNSW(String caseId) {
        List<Related_Contact__c> applicant = [SELECT Id FROM Related_Contact__c 
                                            WHERE Primary_Contact__c = true 
                                                AND Related_Application__c = :caseId
                                                AND Residential_Address_State__c = :GlobalConstants.CONTACT_WITH_NSW_ADDRESS ];
        return !applicant.isEmpty();
    }
    
    public static void processAdditionalChecks(Case pCase){
        try{
            //Process complex application check based on niminated directors address
            String STATE_NSW = 'NSW';
            String PO_BOX = 'POBOX';
            if(pCase.Id != null){
                //Retrieve all Nominated Directors contacts for the application
                List<Related_Contact__c> nominatedDirectors = [SELECT Id,  
                                                            Residential_Address_Street__c, 
                                                            Residential_Address_State__c,
                                                            Contact_Type__c, Role__c
                                                            FROM Related_Contact__c 
                                                            WHERE Related_Application__c = :pCase.Id
                                                            AND Contact_Type__c = :GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
                                                            ORDER BY CreatedDate ASC];
                //Iterate each contact to check the adress details
                Boolean bIsComplex = false;
                for(Related_Contact__c con : nominatedDirectors){
                    if(String.isNotBlank(con.Residential_Address_State__c) && con.Residential_Address_State__c != STATE_NSW ){
                        bIsComplex = true;
                        if(!Test.isRunningTest())
                            break;
                    }
                    if(con.Residential_Address_Street__c != Null){
                        String sOnlyChars = con.Residential_Address_Street__c.replaceAll('[^A-Za-z]+', '');
                        if(String.isNotBlank(sOnlyChars) 
                            && sOnlyChars.toUpperCase().startsWith(PO_BOX)){
                            bIsComplex = true;
                            break;
                        }
                    }
                }
                if(bIsComplex){
                    pCase.Is_Complex_Application__c = true;
                    System.debug('bIsComplex: '+ bIsComplex);
                }
            }
        }
       catch(Exception e) {
            System.debug('Exception: '+ e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'ASPFormSectionDataController', 'processAdditionalChecks', e.getMessage(), e);
        }       
     }
}