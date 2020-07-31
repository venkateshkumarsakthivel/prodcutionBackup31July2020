/**
* Server side rest resource controller for levy registeration form 
*/
public with sharing class LevyFormSectionDataController {
    
    @AuraEnabled
    public static Boolean isConsoleUser(){
            User user = GlobalUtility.getLoggedInUser();
         
            if (user.Profile.name == 'P2P Operations Level 3' || user.Profile.name == 'P2P Operations Level 2' || user.Profile.name == 'P2P Operations Level 1'){
                return true;
            }
            
            return false;
        }
    
    
    
    
    //function returns logged in user's account name
    @AuraEnabled
    public static String getAccountName(String accountId) {       
        
      
      User loggedInUser = GlobalUtility.getLoggedInUser();    
      String accountName = NULL;
            
      if(!String.isBlank(loggedInUser.AccountId)) {
                
        accountName = loggedInUser.Account.Name;
      }
      else if(!String.isBlank(accountId)) {
                
        accountName = [SELECT Name From Account WHERE Id = :accountId].Name;
      }
            
      return accountName;
    }
    
        @AuraEnabled
	public static String getuserUiThemec() {
    return UserInfo.getUIThemeDisplayed();
}
    
    @AuraEnabled
    public static Boolean hasAccountNoticeAddress(String accountId){
            User user = GlobalUtility.getLoggedInUser();
            
            Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c, Notice_Address__c, Notice_Address_Street__c, Notice_Address_City__c, 
                           Notice_Address_State__c, Notice_Address_Postal_Code__c
                           FROM Account
                           WHERE Id =: accountId limit 1];
        
            if (acc.Notice_Address_Street__c == null || acc.Notice_Address_Street__c == '' 
                ||acc.Notice_Address_City__c == null || acc.Notice_Address_City__c == ''
                ||acc.Notice_Address_State__c == null || acc.Notice_Address_State__c == ''
                ||acc.Notice_Address_Postal_Code__c == null || acc.Notice_Address_Postal_Code__c == ''){
                return false;
            }
            
            return true;
        }
    
    //function returns logged in user's account record type
    @AuraEnabled
    public static String getAccountEntityType(string accountId) { 
        
        User loggedInUser = GlobalUtility.getLoggedInUser();    
        String entityAccount = NULL;
        
        if(!String.isBlank(loggedInUser.AccountId)) {
                
        entityAccount = loggedInUser.Account.Record_Type_Dev_Name__c;
        }
        else if(!String.isBlank(accountId)) {
            
        entityAccount = [SELECT Record_Type_Dev_Name__c FROM Account WHERE Id = :accountId].Record_Type_Dev_Name__c;
        }           
        return entityAccount;        
      }
    
    //function returns all contacts from logged in user's account
    @AuraEnabled
    public static List<Contact> getAccountContacts(String accountId) {   
        
        List<Contact> listContacts = new List<Contact>();
        
        User loggedInUser = GlobalUtility.getLoggedInUser();
            
        System.debug('Account Id: '+accountId);
            
        if(String.isBlank(accountId) && String.isBlank(loggedInUser.AccountId) == FALSE)
         accountId = loggedInUser.AccountId;
            
        if(String.isBlank(accountId))
         return listContacts;
              
        listContacts = [SELECT Id, Name, Email, Phone, MobilePhone
                        FROM Contact 
                        WHERE AccountId = :accountId 
                        AND Eligible_For_Levy_Contact_Selection__c = TRUE
                        ORDER BY LastModifiedDate DESC];
            
        return listContacts;
    }
    
    //function returns authorisations from logged in user's account
    @AuraEnabled
    public static List<Authorisation__c> getAccountAuthorisations(String accountId) {   
        
        List<Authorisation__c> listAuthorisations = new List<Authorisation__c>();
        
        User loggedInUser = GlobalUtility.getLoggedInUser();
            
        if(String.isBlank(accountId) && String.isBlank(loggedInUser.AccountId) == FALSE)
         accountId = loggedInUser.AccountId;
            
        if(String.isBlank(accountId))
         return NULL;
              
        listAuthorisations = [SELECT Id, Authorisation_Type__c, Name, End_Date__c
                              FROM Authorisation__c
                              WHERE Service_Provider__c = :accountId
                              AND (Status__c = :GlobalConstants.GRANTED_UNCONDITIONALLY
                                   OR Status__c = :GlobalConstants.GRANTED_CONDITIONALLY 
                                   OR Status__c =:GlobalConstants.AUTHORISATION_SUSPENDED)
                              ORDER BY LastModifiedDate DESC];
            
        return listAuthorisations;
    }
    
    //function returns data for section of levy registeration form
    @AuraEnabled
    public static String getSectionData(String registrationId) {       
        
        
        User loggedInUser = GlobalUtility.getLoggedInUser();    
        LevySectionDataWrapper tempSectionDataWrapper;
            
        String loggedInUserAccountId = loggedInUser.AccountId;
 
        tempSectionDataWrapper = new LevySectionDataWrapper(registrationId, loggedInUserAccountId);
        tempSectionDataWrapper.loadCaseSectionData();
 
        return JSON.serialize(tempSectionDataWrapper.levyRegistrationRec);
    }
    
    //function to initialise the levy form when invoked from account
    @AuraEnabled
    public static String getSectionDataForAccount(String accountId) {
    
        LevySectionDataWrapper tempSectionDataWrapper;
            
        tempSectionDataWrapper = new LevySectionDataWrapper(null, accountId);
            
        tempSectionDataWrapper.loadCaseSectionData();
 
        return JSON.serialize(tempSectionDataWrapper.levyRegistrationRec);
    }
    
    //function to update the registration record
    @AuraEnabled
    public static String updateRegistrationRecord(String registrationData) {
    
      try {
          
        Tax_Payer_Registration__c levyRegistrationRecToUpdate = (Tax_Payer_Registration__c)JSON.deserialize(registrationData, Tax_Payer_Registration__c.class);
            
        System.debug('Registeration record to update: '+levyRegistrationRecToUpdate);
        
        //if applied foe exemption, update Revenue NSW status as N/A, else Pending
        if(levyRegistrationRecToUpdate.Applied_For_Exemption__c == GlobalConstants.YES_VALUE) 
         levyRegistrationRecToUpdate.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
        else
         levyRegistrationRecToUpdate.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
             
        //validates if specified registration record is pending with OSR, if yes then update existing record for bank detail updation
        //else supersede cloned record and update existing registration for bank detail updation
        if(GlobalUtility.checkIfWithOSR(levyRegistrationRecToUpdate)) {
          
          levyRegistrationRecToUpdate.Date_Registered__c = DateTime.Now();
          levyRegistrationRecToUpdate.Date_Sent_to_Revenue__c = null; 
          update levyRegistrationRecToUpdate;
          return getSectionData(levyRegistrationRecToUpdate.Id);
        }   
        else if(levyRegistrationRecToUpdate.Status__c != GlobalConstants.STATUS_SUPERSEDED) {
        
         System.debug('Not with OSR');
            
         Tax_Payer_Registration__c clonedRegistrationRecord = GlobalUtility.cloneRegistrationRecord(levyRegistrationRecToUpdate);
         clonedRegistrationRecord = clonedRegistrationRecord.clone(false, true, false, false);
         clonedRegistrationRecord.Levy_Notification_Address_Country__c = levyRegistrationRecToUpdate.Levy_Notification_Address_Country__c;
            
         //marking clonned registration record as superseded
         clonedRegistrationRecord.Status__c = GlobalConstants.STATUS_SUPERSEDED;
         insert clonedRegistrationRecord;
         
         levyRegistrationRecToUpdate.Status__c = GlobalConstants.STATUS_ACTIVE;
         
         if(levyRegistrationRecToUpdate.Applied_For_Exemption__c == GlobalConstants.YES_VALUE) 
          levyRegistrationRecToUpdate.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
         else
          levyRegistrationRecToUpdate.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                 
         //if service provider is exmepted from levy
         if(levyRegistrationRecToUpdate.Exemption_Approved__c && levyRegistrationRecToUpdate.Annual_Trip_Estimate__c == Label.Levy_Trip_Estimate_Less_Than_150_Value)
          levyRegistrationRecToUpdate.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
         else if(levyRegistrationRecToUpdate.Applied_For_Exemption__c == GlobalConstants.YES_VALUE 
                        || levyRegistrationRecToUpdate.Applied_For_Rebate__c == GlobalConstants.YES_VALUE)
          levyRegistrationRecToUpdate.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_P2P;
         else
          levyRegistrationRecToUpdate.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW;
         
         if(String.isNotBlank(levyRegistrationRecToUpdate.RNSWCustomerId__c))
          levyRegistrationRecToUpdate.IsAuthorisationUpdate__c = TRUE;
                 
         levyRegistrationRecToUpdate.Date_Registered__c = DateTime.Now(); 
         levyRegistrationRecToUpdate.Date_Sent_to_Revenue__c = null;
         update levyRegistrationRecToUpdate;
        
         return getSectionData(levyRegistrationRecToUpdate.Id);
        }
        
        return registrationData;
      }
      catch(Exception e) {
            
        System.debug('Exception: '+e);
        ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyFormSectionDataController', 'updateRegistrationRecord', e.getMessage(), e);
        return NULL;
      }
    }
    
    //function to submit the registration record
    @AuraEnabled
    public static String submitRegistrationRecord(String registrationData) {
        
        try {
            
            String registrationId = LevyFormSectionDataHelper.processRegistrationSubmission(registrationData);
            return registrationId != NULL ? getSectionData(registrationId) : NULL;     
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyFormSectionDataController', 'submitRegistrationRecord', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns DDR service agreement content configured in custom metadata type- Levy DDR Service Agreement
    @AuraEnabled
    public static String getDDRServiceAgreement() {     
     
        return GlobalUtility.getDDRServiceAgreement();
    }
    
    //method to return picklist values for Estimated TSP/BSP Transactions based on authType
    @AuraEnabled
    public static List<String> getEstimatedTransactionsCounts(String authType){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = authType == GlobalConstants.AUTHORISATION_TYPE_TSP ? Tax_Payer_Registration__c.Estimated_BSP_Transactions__c.getDescribe() : Tax_Payer_Registration__c.Estimated_TSP_Transactions__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    //method to validate if service provider has existing active registrations
    @AuraEnabled
    public static Boolean hasExistingActiveRegistrations(String accountId){
    
     
        User loggedInUser = GlobalUtility.getLoggedInUser();
            
        System.debug('Account Id: '+accountId);
            
        if(String.isBlank(accountId) && String.isBlank(loggedInUser.AccountId) == FALSE)
          accountId = loggedInUser.AccountId;
            
        if(String.isBlank(accountId))
          return FALSE;
              
        /* query all existing active registration records */
        List<Tax_Payer_Registration__c> existingRegistrationRecords = [SELECT Status__c, Sub_Status__c
                                                                       FROM Tax_Payer_Registration__c
                                                                       WHERE Service_Provider_Name__c = :accountId 
                                                                       AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        return existingRegistrationRecords.size() > 0 ? TRUE : FALSE;
    }
    
    //method to validate if logged in user from salesforce (non-community) is authorised to perform levy registration or not
    @AuraEnabled
    public static Boolean hasLevyRegistrationAccess(){
      
       //set to store names of profiles which can perform levy registration
       Set<String> registrationAllowedProfileNames = new Set<String>();
        
       //fetching names of profiles configure in metadata Levy_Registration_Allowed_Profile__mdt
       List<Levy_Registration_Allowed_Profile__mdt> levyRegistrationAllowedProfiles = [SELECT DeveloperName, Label
                                                                                       FROM Levy_Registration_Allowed_Profile__mdt];
        
       System.debug('List: '+levyRegistrationAllowedProfiles);
        
       //storing names of profiles which can delete attachments
       for(Levy_Registration_Allowed_Profile__mdt tempAllowedProfile : levyRegistrationAllowedProfiles)
        registrationAllowedProfileNames.add(tempAllowedProfile.Label);
        
       User loggedInUser = GlobalUtility.getLoggedInUser();
       if(registrationAllowedProfileNames.contains(loggedInUser.Profile.Name))
         return true;
       
       return false;
    }
    
    @AuraEnabled
    public static Boolean checkIfPortalUser(){
       
       return GlobalUtility.getLoggedInUser().ContactId != NULL ? TRUE : FALSE;
    }
}