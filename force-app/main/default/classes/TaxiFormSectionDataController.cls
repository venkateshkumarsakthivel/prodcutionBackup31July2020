/**
* Server side rest resource controller for fetching section data in ASP form 
*/

public without sharing class TaxiFormSectionDataController {
    
    //function saves data for section of taxi form
    @AuraEnabled
    public static String saveSectionData(String caseData) {        
        
        try {
            
            Case caseRecToSave = (Case)JSON.deserialize(caseData, Case.class);
            if(caseRecToSave.Is_WAT_Application__c){
                caseRecToSave.Subject = GlobalConstants.WAT_LICENCE_APPLICATION_CASE_SUBJECT;
                caseRecToSave.Description = GlobalConstants.WAT_LICENCE_APPLICATION_CASE_SUBJECT;
                caseRecToSave.Sub_Type__c = GlobalConstants.WAT_APPLICATION_SUB_TYPE;
                caseRecToSave.ParentId = null;
                
                List<Operation_Area_Vs_Licence_Class__mdt> areaVsClass = [  SELECT Operation_Area__c, Taxi_Class__r.Licence_Class__c ,
                                                                                Taxi_Class__r.Licence_Type__c
                                                                            FROM Operation_Area_Vs_Licence_Class__mdt 
                                                                            WHERE Operation_Area__c = :caseRecToSave.Operation_Area__c];
                if(!areaVsClass.isEmpty()){
                    caseRecToSave.Licence_Class__c = areaVsClass[0].Taxi_Class__r.Licence_Class__c;
                    caseRecToSave.Licence_Type__c = areaVsClass[0].Taxi_Class__r.Licence_Type__c;
                }
            }
            else {
                list <Taxi_Class__mdt> mtd= new list<Taxi_Class__mdt>();
                mtd = [select Licence_Class__c from Taxi_Class__mdt where Is_WAT__c = 'yes' and Licence_Class__c = :caseRecToSave.Licence_Class__c];
                if ( mtd.size() != 0){
                caseRecToSave.ParentId = null;    
                }
            }
             
             
            System.debug('Case record to save: '+caseRecToSave);
            /*
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            caseRecToSave.setOptions(dmo);
            */
            upsert caseRecToSave;
            
            Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                        FROM Account
                                        WHERE Id = :caseRecToSave.AccountId];
            
            return getEntityType(applicantAccount.Record_Type_Dev_Name__c) + '-' + caseRecToSave.Id;
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e.getMessage());
            System.debug('Exception: '+e.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns data for individual section of ASP form
    @AuraEnabled
    public static String getSectionData(String caseId, String applicantAccId) {
        
        try {
            
            TaxiSectionDataWrapper tempTaxiSectionDataWrapper = new TaxiSectionDataWrapper(caseId, applicantAccId);
            tempTaxiSectionDataWrapper.loadCaseSectionData();
            
            System.debug(JSON.serialize(tempTaxiSectionDataWrapper.currentCaseRec));
            
            return JSON.serialize(tempTaxiSectionDataWrapper.currentCaseRec);
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    @AuraEnabled
    public static String getAccountDetails(String caseId){
        List<Case> cases = [SELECT Id, Account.Name, Account.ABN__c, Account.ACN__c,
                Account.Email__c, Account.Document_Delivery_Preference__c,
                Account.Notice_Address_City__c, Account.Notice_Address_Country__c,
                Account.Notice_Address_Postal_Code__c, Account.Notice_Address_State__c,
                Account.Notice_Address_Street__c, Account.Notice_Email__c,
                Account.Registered_Business_Name__c, Account.Phone, 
                Daytime_phone_number__c, Corporation_name__c
        FROM Case WHERE Id = :caseId];
        String returnStr;
        if(!cases.isEmpty() && cases[0].AccountId != null){
            returnStr = JSON.serialize(cases[0].Account);
        }
        return returnStr;
    }
    
    @AuraEnabled
    public static String getLicenceDetails(String caseId){
       
        System.debug('Case Id Licence Details: '+caseId);
        
        List<Authorisation__c> licence = [SELECT Id, Name, Application__c, Authorisation_Name__c, 
                                            Authorisation_Type__c, Licence_Class__c, Licence_Fee__c,
                                            Licence_Type__c, Operating_Locations__c, Operation_Area__c,
                                            Payment_Frequency__c, Plate_Number__c,
                                            SNSW_Plate_Pickup_Location__c, Start_Date__c, Status__c                                         
                                        FROM Authorisation__c
                                        WHERE Application__c = :caseId];
        String returnStr;
        if(!licence.isEmpty()){
            returnStr = JSON.serialize(licence[0]);
        }
        return returnStr;
    }
    
    private static String getEntityType(String recordType){
        String returnStr = 'Individual';
        if(recordType == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
                returnStr = 'Company';
            
        if(recordType == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
            returnStr = 'Individual';
            
        if(recordType == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP)
            returnStr = 'Individual Partner';
            
        if(recordType == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP)
            returnStr = 'Company Partner';
        
        return returnStr;
    }
    
    //function returns entity type of account of logged in user
    @AuraEnabled
    public static String getEntityType(String applicantAccountId, String caseId) {
        try{
            
            System.debug('Received Id: '+applicantAccountId);
            System.debug('Received Case Id: '+caseId);
            
            if(!String.isBlank(applicantAccountId)) {
            
                Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                         FROM Account
                                         WHERE Id = :applicantAccountId];
            
                return getEntityType(applicantAccount.Record_Type_Dev_Name__c);
            }
            else if(!String.isBlank(caseId)) {
             
                Case applicationCase = [SELECT Account.Record_Type_Dev_Name__c
                                     FROM Case
                                     WHERE Id = :caseId];
             
                return getEntityType(applicationCase.Account.Record_Type_Dev_Name__c);
            }
            else {             
                User loggedInUser = GlobalUtility.getLoggedInUser();            
                return getEntityType(loggedInUser.Account.Record_Type_Dev_Name__c);
            }
        }catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getEntityType', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns type of logged in user
    @AuraEnabled
    public static String getUserType() {
        
        try{  
        
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            return loggedInUser.UserType;
            
        }catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getUserType', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns case record using the requested id
    @AuraEnabled
    public static String getResumeCase(String caseId) {
     
        
        try{  
        
            Case requestedCase = [SELECT Status, Is_WAT_Application__c, Sub_Type__c
                                  FROM Case
                                  WHERE Id = :caseId];
            
            return JSON.serialize(requestedCase);
            
        }catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getCaseStatus', e.getMessage(), e);
            return NULL;
        }
    }
    
    //method to return picklist value for SNSW Plate Pickup Location picklist
    @AuraEnabled
    public static List<String> getPlateLocations(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Authorisation__c.SNSW_Plate_Pickup_Location__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    //method to return picklist value for Operating Locations picklist
    @AuraEnabled
    public static List<String> getOperatingLocations(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Authorisation__c.Operating_Locations__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
        options.add(f.getLabel());
        }
        
        return options;
    }
    
    //method to return picklist value for Operation Area picklist
    @AuraEnabled
    public static List<String> getOperationAreas(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Authorisation__c.Operation_Area__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
            // JIRA-254 change to remove the other pick list values for WAT taxi licence in the portal except the Metropolitan Transport District (Sydney) & NSW excluding Metro Transport District (Sydney)
            if(f.getLabel().contains('Transport District'))
            options.add(f.getLabel());
        }
        
       
        return options;
    }
    
    //method to return picklist value for Licence Class picklist
    @AuraEnabled
    public static List<String> getLicenceClassValues(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Authorisation__c.Licence_Class__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    //method to return picklist value for Licence Term picklist
    @AuraEnabled
    public static List<String> getLicenceTypes(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Authorisation__c.Licence_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
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
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getAccountId', e.getMessage(), e);
            return 'ERROR';
        }
    }
    
    //method to fetch nominated directors data associate with a case
    @AuraEnabled
    public static String getNominatedDirectors(String caseId) {
        try{
            List<Related_Contact__c> nominatedDirectors = [SELECT Id, Contact_Type__c, Title__c, First_Given_Name__c, Family_Name__c,
                                                           Other_Given_Name__c, Date_of_Birth__c, Australian_Driver_Licence__c,
                                                           Australian_Driver_Licence_State__c, Daytime_Phone__c,  Email__c,
                                                           Residential_Address_City__c, Residential_Address_Street__c, 
                                                           Residential_Address_Postcode__c, Residential_Address_State__c,
                                                           Proof_Of_Identity_Documents__c
                                                           FROM Related_Contact__c 
                                                           WHERE Related_Application__c = :caseId 
                                                           AND Contact_Type__c = :GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
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
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getNominatedDirectors', e.getMessage(), e);
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
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'deleteNominatedDirectors', e.getMessage(), e);
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
            if(directorsToSave.size() > 0) {
                upsert directorsToSave;            
                Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :directorsToSave[0].Related_Application__c];    
                    
                Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                            FROM Account
                                            WHERE Id = :applicantApplication.AccountId];
                
                return getEntityType(applicantAccount.Record_Type_Dev_Name__c) 
                        + '-' + directorsToSave[0].Related_Application__c;
            }
            return NULL;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveNominatedDirectors', e.getMessage(), e);
            return NULL;
        }
        
    }
    
    //function that saves application that is submitted by internal staff
    @AuraEnabled
    public static String submitTaxiApplication(String applicationId){
    
      Case applicationCase = new Case();
      applicationCase.Id = applicationId;
      applicationCase.Status = GlobalConstants.CASE_NEW;
      applicationCase.Sub_Status__c = GlobalConstants.READY_TO_BE_SENT_SUB_STATUS;
      
      if(UserInfo.getUserType() != 'Standard') {
      
       Database.DMLOptions dmo = new Database.DMLOptions();
       dmo.assignmentRuleHeader.useDefaultRule = true;
       applicationCase.setOptions(dmo);
      }
      
      update applicationCase;
      
      applicationCase = [SELECT CaseNumber, Status FROM Case WHERE Id = :applicationCase.Id];
      
      return JSON.serialize(applicationCase);
    }
    
    //function that creates related authorisation record for specified application
    @AuraEnabled
    public static String createAuthorisation(String applicationId) {
    
     try {
     
      Case applicationCase = [SELECT Status, AccountId, Licence_Class__c,
                              Licence_Type__c, Operating_Locations__c, Operation_Area__c, 
                              SNSW_Plate_Pickup_Location__c, Notice_Email__c, 
                              Apply_WAT_For_Existing_Licence__c, Existing_Taxi_Licence_Id__c, Is_WAT_Application__c,
                              Licence_Fee_Due__c, Existing_Plate_Number__c
                              FROM Case 
                              WHERE Id = :applicationId];
      
      List<Authorisation__c> existingAuths = [SELECT Id FROM Authorisation__c WHERE Application__c = :applicationId];
      
      Authorisation__c authorisation;
      
      if(existingAuths.isEmpty()) {
        authorisation = new Authorisation__c();
      } else {
        authorisation = existingAuths[0];
      }
           
      
       Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
      
       
       authorisation.Application__c = applicationId;
       authorisation.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
       authorisation.Service_Provider__c = applicationCase.AccountId;
       authorisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_NEW;
       //authorisation.Start_Date__c = System.today();
       //authorisation.End_Date__c = System.today().addYears(Integer.valueOf(Label.Default_Taxi_Term_period));
       authorisation.Service_Provider_Notice_Email__c = applicationCase.Notice_Email__c;
       authorisation.SNSW_Plate_Pickup_Location__c = applicationCase.SNSW_Plate_Pickup_Location__c;
       authorisation.Existing_Plate_Number__c = applicationCase.Existing_Plate_Number__c;
       authorisation.RecordTypeId = taxiAuthorisationRecordTypeId;
       authorisation.Licence_Fee__c = applicationCase.Licence_Fee_Due__c;
       authorisation.Operating_Locations__c = applicationCase.Operating_Locations__c;
       authorisation.Operation_Area__c = applicationCase.Operation_Area__c;
       authorisation.Licence_Class__c = applicationCase.Licence_Class__c;
       authorisation.Licence_Type__c = applicationCase.Licence_Type__c;
       
       if (authorisation.Licence_Class__c != null){   
              list <Taxi_Class__mdt> mtdLicence= new list<Taxi_Class__mdt>();
              mtdLicence = [select Licence_Class__c, Is_Renewable__c from Taxi_Class__mdt where Licence_Class__c = :authorisation.Licence_Class__c];
              if(mtdLicence.size() != 0){
                  if(mtdLicence[0].Is_Renewable__c == 'yes' && authorisation.Licence_Fee__c != 0){
                      authorisation.Payment_Frequency__c = 'At Renewal';   
                  }
                  else{
                      authorisation.Payment_Frequency__c = 'Not Applicable'; 
                  }
              }   
       
       }else if(authorisation.Licence_Fee__c == 0){
           authorisation.Payment_Frequency__c = 'Not Applicable';
       }
          
      upsert authorisation;    
      
      
      /*
      if(applicationCase.Apply_WAT_For_Existing_Licence__c == 'Yes' 
         && !String.isBlank(applicationCase.Existing_Taxi_Licence_Id__c)) {
       
        String soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c', 'id=\''+applicationCase.Existing_Taxi_Licence_Id__c+'\'');    
        Authorisation__c existingLicence = (Authorisation__c)Database.query(soql);
        authorisation.Related_Authorisation__c = existingLicence.Id;
        
        
        update authorisation;
      }
      */
      
      if(applicationCase.Is_WAT_Application__c) {
       
        List<Condition__c> defaultWATConditionsToAdd = new List<Condition__c>();
        
        for(Master_Condition__c watCondition : [SELECT Category__c, Condition_Details__c, Status__c, Type__c
                                                 FROM Master_Condition__c
                                                 WHERE Status__c = :GlobalConstants.MASTER_CONDITION_ACTIVE
                                                 AND Type__c = :GlobalConstants.TAXI_WAT_LICENCE_PROVIDER
                                                 AND Category__c = :GlobalConstants.TAXI_LICENCE_CONDITION_CATEGORY]) {
                                                
          
          Condition__c tempWATCondition = new Condition__c();
          tempWATCondition.Authority__c = authorisation.Id;
          tempWATCondition.Master_Condition__c = watCondition.Id;
          tempWATCondition.Condition_Details__c = watCondition.Condition_Details__c;
          defaultWATConditionsToAdd.add(tempWATCondition);
                                                
        }
                                             
        if(defaultWATConditionsToAdd.size() > 0)
          insert defaultWATConditionsToAdd;
      }
                                                                               
      return authorisation.Id;
     }
     catch(Exception e) {
      
      System.debug('Exception: '+e);
      ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'createAuthorisation', e.getMessage(), e);
      return NULL;
     }
     
    }
    
    //function to fetch licence conditions against the application's authorisation record
    @AuraEnabled
    public static List<Condition__c> getConditions(String applicationId) {
        
         Map<String, Condition__c> masterVsConditions = new Map<String, Condition__c>();
         Map<String, String> authVsConditionType = new Map<String, String>();
         String authRecordId;
        
         authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_TSP, 
                                GlobalConstants.TAXI_SERVICE_PROVIDER);
         authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_BSP,     
                                 GlobalConstants.BOOKING_SERVICE_PROVIDER);
         authVsConditionType.put(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,     
                                GlobalConstants.TAXI_LICENCE_PROVIDER);
                
        if(!String.isBlank(applicationId)) {
        
         //retrieve authorisation details
         List<Authorisation__c> authorisation = [SELECT Id, Authorisation_Type__c
                                                 FROM Authorisation__c
                                                 WHERE Application__c  = :applicationId
                                                 AND Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE
                                                 ORDER BY CreatedDate DESC LIMIT 1];
         
         if(authorisation.size() == 0)
            authRecordId = NULL;
         else 
            authRecordId = authorisation[0].Id;
        }
           
        if(UserInfo.getUserType() == 'Standard') {
         
         for(Master_Condition__c master :[SELECT Id, Condition_Details__c, Type__c
                                          FROM Master_Condition__c
                                          WHERE Status__c = :GlobalConstants.MASTER_CONDITION_ACTIVE
                                          AND Type__c = :GlobalConstants.TAXI_LICENCE_PROVIDER
                                          AND Category__c = :GlobalConstants.TAXI_LICENCE_CONDITION_CATEGORY]) {
                                            
            Condition__c condition = new Condition__c();
            condition.Condition_Details__c = master.Condition_Details__c;
            condition.Authority__c = authRecordId;
            condition.Master_Condition__c = master.Id;
            masterVsConditions.put(master.Id, condition);
         }
        
        } 
        
        Integer manualConditionCount = 1;
        for(Condition__c condition :[SELECT Id, Condition_Details__c, Authority__c,
                                     Internal_Notes__c, Master_Condition__c, Authority__r.Authorisation_Type__c 
                                     FROM Condition__c 
                                     WHERE Authority__c = :authRecordId]){
                                     
            if(condition.Master_Condition__c != null){
                masterVsConditions.put(condition.Master_Condition__c, condition);
            } else {
                masterVsConditions.put(String.valueOf(manualConditionCount), condition);
                manualConditionCount++;
            }
            
        }
        
        if(UserInfo.getUserType() == 'Standard') {
        
         //add record for one manual entry for condtion
         masterVsConditions.put(null, new Condition__c(Authority__c = authRecordId, 
                            Condition_Details__c = '', Internal_Notes__c = ''));
        }
        
        return masterVsConditions.values();
       
     }
     
     //function to save licence conditions against the application's authorisation record
     @AuraEnabled
     public static void attachConditions(String unSelectedConditions, String selectedConditions) {
        
        System.debug('unSelectedConditions '+unSelectedConditions);
        System.debug('selectedConditions '+selectedConditions);
        
        List<Condition__c> selectedConditionsToInsert = (List<Condition__c>)JSON.deserialize(selectedConditions, List<Condition__c>.class);
        List<Condition__c> unselectedConditionsToDelete = (List<Condition__c>)JSON.deserialize(unSelectedConditions, List<Condition__c>.class);
        
                
        if(selectedConditionsToInsert.size() > 0)
            upsert selectedConditionsToInsert;
        
        if(unselectedConditionsToDelete.size() > 0)
            delete unselectedConditionsToDelete;
        
    }
    
   
    //function saves data for Corporate Partnership section of ASP form
    @AuraEnabled
    public static String saveCorporatePartnershipData(String corporatesData, String applicantsData) {
        
        try {
            System.debug('[Corporate Partnership - Corporate Section] Related Contacts to save: ' + corporatesData);
            System.debug('[Corporate Partnership - Applicant Section] Related Contacts to save: ' + applicantsData);
            
            List<Related_Contact__c> corporateContactsToSave = (List<Related_Contact__c>)JSON.deserialize(corporatesData, List<Related_Contact__c>.class);
            System.debug('[Corporate Partnership - Corporate Section] Related Contacts to save: ' + corporateContactsToSave);
            
            Id corpRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c corpCon : corporateContactsToSave){
                corpCon.RecordTypeId = corpRecordTypeId;
            }
            
            List<Related_Contact__c> applicantContactsToSave = (List<Related_Contact__c>)JSON.deserialize(applicantsData, List<Related_Contact__c>.class);
            System.debug('[Corporate Partnership - Applicant Section] Related Contacts to save: ' + applicantContactsToSave);
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            for(Related_Contact__c indivCon : applicantContactsToSave){
                indivCon.RecordTypeId = indivRecordTypeId;
            }
            
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
            
            return getEntityType(applicantAccount.Record_Type_Dev_Name__c) 
                    + '-' + corporateContactsToSave[0].Related_Application__c;
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveCorporatePartnershipData', e.getMessage(), e);
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
                                                          Is_Nominee_of_Good_repute__c, Nominee_Not_of_Good_Repute_Details__c
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
                                                          Residential_Address_Postcode__c, Residential_Address_Country__c, Proof_Of_Identity_Documents__c
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
                Case currentCase = [SELECT Account.Name, Account.ACN__c, Account.ABN__c, Account.Registered_Business_Name__c From Case Where ID = :caseId ];
                
                corporateContacts.add(new Related_Contact__c(Related_Application__c = caseId, Contact_Type__c = GlobalConstants.CONTACT_CORPORATE_PARTNERSHIP_TYPE, 
                                                             Corporation_Name__c = currentCase.Account.Name, ACN__c = currentCase.Account.ACN__c, ABN__c = currentCase.Account.ABN__c, 
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
                                                           Has_had_authorisation_refused__c, Auth_Refusal_Details__c, Proof_Of_Identity_Documents__c
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
            for(Related_Contact__c indivCon : individualContactsToSave){
                indivCon.RecordTypeId = indivRecordTypeId;
            }
            
            if(individualContactsToSave.size() > 0)
                upsert individualContactsToSave;
            
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :individualContactsToSave[0].Related_Application__c];    
            
            Account applicantAccount = [SELECT Id, Record_Type_Dev_Name__c 
                                        FROM Account
                                        WHERE Id = :applicantApplication.AccountId];
            
            return getEntityType(applicantAccount.Record_Type_Dev_Name__c) 
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
    
    // Function to save Related contact data on Case for Taxi Form Corporation Details section
    @AuraEnabled
    public static String saveCorporationDetailsSectionData(String corporationData) {
        
        try {
            
            System.debug('Corporation details to save: ' + corporationData);
            
            Related_Contact__c corporationRelatedContact = (Related_Contact__c)JSON.deserialize(corporationData, Related_Contact__c.class);
            
            Id corporateContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            corporationRelatedContact.RecordTypeId = corporateContactRecordTypeId;
            
            upsert corporationRelatedContact;
            
            System.debug('Corporate Related contact created Id : ' + corporationRelatedContact.Id); 
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :corporationRelatedContact.Related_Application__c];
            
            Account account = [SELECT Id, Record_Type_Dev_Name__c 
                               FROM Account
                               WHERE Id = : applicantApplication.AccountId];
            
            return getEntityType(account.Record_Type_Dev_Name__c) + '-' + corporationRelatedContact.Related_Application__c;
        }
        catch(Exception e) {
            
            System.debug('Exception: ' + e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveCorporationDetailsSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    // Function to fetch Related contact data from Case for Taxi Form Corporation Details section
    @AuraEnabled
    public static String getCorporationDetailsSectionData(String caseId) {
        
        try {
            
            String jsonResponse;
            Id corporateContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            
            List<Related_Contact__c> corporateContacts = [SELECT Id, Contact_Type__c, Corporation_Name__c, Family_Name__c, Registered_business_name__c, 
                                                          ACN__c, ABN__c, Daytime_Phone__c
                                                          FROM Related_Contact__c 
                                                          WHERE Related_Application__c = :caseId 
                                                          AND Contact_Type__c = :GlobalConstants.CONTACT_GENERAL_CONTACT
                                                          AND RecordTypeId = :corporateContactRecordTypeId
                                                          ORDER BY CreatedDate DESC];
            
            if(corporateContacts.size() > 0) {
                
                jsonResponse = JSON.serialize(corporateContacts[0]);
            }
            else {
                
                Related_Contact__c newPrimaryContact = new Related_Contact__c();
                newPrimaryContact.Related_Application__c = caseId;
                
                Case applicationCase = [SELECT Account.Name, Account.ACN__c, Account.ABN__c, Account.Registered_Business_Name__c, Account.Phone
                                        FROM Case
                                        WHERE Id = :caseId];
                
                if(GlobalUtility.getLoggedInUser().ContactId != NULL) {
                    
                    newPrimaryContact.Corporation_Name__c = GlobalUtility.getLoggedInUser().Account.Name;
                    newPrimaryContact.ACN__c = GlobalUtility.getLoggedInUser().Account.ACN__c;
                    newPrimaryContact.ABN__c = GlobalUtility.getLoggedInUser().Account.ABN__c;
                    newPrimaryContact.Registered_Business_Name__c = GlobalUtility.getLoggedInUser().Account.Registered_Business_Name__c;
                    newPrimaryContact.Daytime_Phone__c = GlobalUtility.getLoggedInUser().Account.Phone;
                }
                else {
                    
                    newPrimaryContact.Corporation_Name__c = applicationCase.Account.Name;
                    newPrimaryContact.ACN__c = applicationCase.Account.ACN__c;
                    newPrimaryContact.ABN__c = applicationCase.Account.ABN__c;
                    newPrimaryContact.Registered_Business_Name__c = applicationCase.Account.Registered_Business_Name__c;
                    newPrimaryContact.Daytime_Phone__c = applicationCase.Account.Phone;
                }
                
                newPrimaryContact.RecordTypeId = corporateContactRecordTypeId;
                jsonResponse = JSON.serialize(newPrimaryContact);
            }  
            
            return jsonResponse;  
        }
        catch(Exception e) {
            
            System.debug('Exception: ' + e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getCorporationDetailsSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    // Function to save Related contact data on Case for Taxi Form Individual Details section
    @AuraEnabled
    public static String saveIndividualDetailsSectionData(String individualData) {
        
        try {
            
            System.debug('Individual details to save: ' + individualData);
            
            Related_Contact__c individualRelatedContact = (Related_Contact__c)JSON.deserialize(individualData, Related_Contact__c.class);
            
            Id individualContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            individualRelatedContact.RecordTypeId = individualContactRecordTypeId;
            
            upsert individualRelatedContact;
            
            System.debug('Individual Related contact created Id : ' + individualRelatedContact.Id); 
            
            Case applicantApplication = [SELECT AccountId FROM Case WHERE Id = :individualRelatedContact.Related_Application__c];
            
            Account account = [SELECT Id, Record_Type_Dev_Name__c 
                               FROM Account
                               WHERE Id = : applicantApplication.AccountId];
            
            return getEntityType(account.Record_Type_Dev_Name__c) + '-' + individualRelatedContact.Related_Application__c;
        }
        catch(Exception e) {
            
            System.debug('Exception: ' + e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'saveIndividualDetailsSectionData', e.getMessage(), e);
            return NULL;
        }
    }
    
    // Function to fetch Related contact data from Case for Taxi Form Individual Details section
    @AuraEnabled
    public static String getIndividualDetailsSectionData(String caseId) {
        
        try {
            
            String jsonResponse;
            Id individualRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            
            List<Related_Contact__c> individualContacts = [SELECT Id, Contact_Type__c, 
                                                           Title__c, First_Given_Name__c, Family_Name__c, Other_Given_Name__c, 
                                                           Date_of_Birth__c, Daytime_Phone__c, 
                                                           Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                           Proof_Of_Identity_Documents__c,
                                                           Residential_Address_City__c, Residential_Address_State__c,
                                                           Residential_Address_Postcode__c, Residential_Address_Street__c,
                                                           Residential_Address_Country__c, Residential_International_Address__c
                                                           FROM Related_Contact__c 
                                                           WHERE Related_Application__c = :caseId 
                                                           AND Contact_Type__c = :GlobalConstants.CONTACT_GENERAL_CONTACT
                                                           AND RecordTypeId = :individualRecordTypeId
                                                           ORDER BY CreatedDate DESC];
            
            if(individualContacts.size() > 0) {
                
                jsonResponse = JSON.serialize(individualContacts[0]);
            }
            else {
                Related_Contact__c newPrimaryContact = new Related_Contact__c();
                newPrimaryContact.Related_Application__c = caseId;
                
                if(GlobalUtility.getLoggedInUser().ContactId != NULL) {
                    
                    newPrimaryContact.First_Given_Name__c = GlobalUtility.getLoggedInUser().FirstName;
                    newPrimaryContact.Family_Name__c = GlobalUtility.getLoggedInUser().LastName;
                    newPrimaryContact.Title__c = GlobalUtility.getLoggedInUser().Contact.Salutation;
                    newPrimaryContact.Birthdate__c = GlobalUtility.getLoggedInUser().Contact.Birthdate;
                    newPrimaryContact.Date_of_Birth__c = GlobalUtility.getLoggedInUser().Contact.Birthdate;
                }
                
                newPrimaryContact.RecordTypeId = individualRecordTypeId;
                jsonResponse = JSON.serialize(newPrimaryContact);
            }  
            
            return jsonResponse;  
        }
        catch(Exception e) {
            
            System.debug('Exception: ' + e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiFormSectionDataController', 'getIndividualDetailsSectionData', e.getMessage(), e);
            return NULL;
        }
    }
}