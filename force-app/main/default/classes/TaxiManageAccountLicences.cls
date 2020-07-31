public without sharing class TaxiManageAccountLicences {
    
    //function returns type of logged in user
    @AuraEnabled
    public static String getUserType() {
    
        try {  
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            return loggedInUser.UserType;    
        } 
        catch(Exception e) {
          
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'getUserType', e.getMessage(), e);
            return NULL;
        }
    }
    
    //function returns entity type of account of logged in user
    @AuraEnabled
    public static String getEntityType() {
        
        try{                    
        
            User loggedInUser = GlobalUtility.getLoggedInUser();            
            return getEntityType(loggedInUser.Account.Record_Type_Dev_Name__c);
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'getEntityType', e.getMessage(), e);
            return NULL;
        }
    }
    
    @TestVisible
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
    
    //method to return the account name of logged in community user
    @AuraEnabled
    public static String getLoggedInUserAccount(){
        
        try{
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            Account act = loggedInUser.Account;
            return JSON.serialize(act);
        }
        catch(Exception ex){
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountLicences','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;
        }  
    } 
    
    //method to validate if any open renewal requests associated with licence
    @AuraEnabled
    public static String checkOpenRenewalRequest(String authId) {
        
        try {

            List<Case> openRenewalRequests = [SELECT CaseNumber, Status
                                              FROM Case 
                                              WHERE IsClosed = FALSE
                                              AND Authorisation__c = :authId
                                              AND (Record_Type_Dev_Name__c = :GlobalConstants.TAXI_CORPORATION_CASE_RECORD_TYPE_DEV_NAME
                                                   OR Record_Type_Dev_Name__c = :GlobalConstants.TAXI_INDIVIDUAL_CASE_RECORD_TYPE_DEV_NAME
                                                   OR Record_Type_Dev_Name__c = :GlobalConstants.TAXI_PARTNERSHIP_CASE_RECORD_TYPE_DEV_NAME
                                                   OR Record_Type_Dev_Name__c = :GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME)
                                              AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                              AND Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION];
            
            
            Authorisation__c licenceAuth = [SELECT Licence_Class__c FROM Authorisation__c WHERE Id = :authId];
            
            Pricebook2 priceBook = [SELECT Name, Id, IsActive FROM Pricebook2 where Name =: Label.ASP_Pricebook AND IsActive = true];
            
            if(!String.isBlank(licenceAuth.Licence_Class__c)) {
                
                
                String renewalProductName = Label.Taxi_Renewal_Application_Product_Name+' '+licenceAuth.Licence_Class__c;
                
                System.debug('Renewal Product Name: '+renewalProductName);
                
                Product2 product = [SELECT Name, Id, ProductCode, IsActive FROM Product2 Where Name = :renewalProductName AND IsActive = true];
                
                PricebookEntry pricebookEntry = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive, Name FROM PricebookEntry WHERE Product2Id =: product.Id AND Pricebook2Id =: priceBook.Id];
                
                return String.valueOf(openRenewalRequests.size())+'-'+String.valueOf(pricebookEntry.UnitPrice);
            }
            
            return String.valueOf(openRenewalRequests.size());
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'checkOpenRenewalRequest', ex.getMessage(), ex);
            return null;
        }
    }
    
    //method to fetch CPI value configured in custom setting
    @AuraEnabled
    public static String getCPIPercentage() {
        
        
        try {
            
            List<Consumer_Price_Index_Configuration__mdt> taxiCPIConfig = [SELECT CPI__c
                                                                           FROM Consumer_Price_Index_Configuration__mdt
                                                                           WHERE DeveloperName = 'Consumer_Price_Index' 
                                                                           LIMIT 1];
            
            if(taxiCPIConfig.size() > 0)                                            
                return String.valueOf(taxiCPIConfig[0].CPI__c);
            else
                return '2';
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'getCPIPercentage', ex.getMessage(), ex);
            return null;
        }
    }
    
    //method to fetch taxi licence config defined in custom meta
    @AuraEnabled
    public static String getTaxiLicenceSettings() {
        
        
        try {
            
            List<Taxi_Class__mdt> taxiConfig = [SELECT Description__c, Is_Legacy_Only__c,
                                                Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                                Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                                Renew_Months__c
                                                FROM Taxi_Class__mdt];
            
            return JSON.serialize(taxiConfig);
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountLicences','getTaxiLicenceSettings',ex.getMessage(),ex);
            return null;
        }
    }
    
    //method to fetch list of authorisation records belonging to community user's account
    @AuraEnabled
    public static List<Authorisation__c> getAuthorisationRecords(String requiredAccId) {
        
        try {
            
            ID accID;
            Id contactId;
            
            List<Authorisation__c> authorisationList = new List<Authorisation__c>();
            
            if(String.isBlank(requiredAccId)) {
            
             contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
             accID  = [Select AccountID from Contact where id =: contactid].AccountId;
             
             Set<String> authStatusValues = new Set<String>();
             authStatusValues.add(GlobalConstants.AUTHORISATION_GRANTED);
             authStatusValues.add(GlobalConstants.AUTHORISATION_SUSPENDED);
     
             authorisationList = [SELECT Id, Application__c, Authorisation_Type__c, Name, Licence_Class__c, Licence_Type__c, Plate_Number__c, Start_Date__c, End_Date__c,
                                         Status__c, Service_Provider__r.Name,Service_Provider__r.Notice_Address__c, isGranted__c, Authorisation_Name__c,
                                         Decision_Reason__c, Decision_Made_By__c,Operating_Locations__c,Term__c, 
                                         Return_Requested__c, Renewal_Requested__c, Eligible_For_Renewal__c, Can_Attempt_Licence_Renewal__c,
                                         Licence_Fee__c, Payment_Frequency__c, Operation_Area__c,
                                         Final_Expiry_Date__c, Last_Transferred_Date__c,Renewal_Count_Remaining__c,First_Issued_Date__c,
                                         Agreement_Type__c, Agency__c, Agency__r.Name, No_of_Active_Auth_Agents__c
                                         FROM Authorisation__c 
                                         WHERE Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  
                                         AND Status__c IN :authStatusValues  
                                         AND Service_Provider__c = :accID  
                                         ORDER BY End_Date__c DESC];
            }
            else {
              
              accID = requiredAccId;
              
              if(GlobalUtility.agentHasAccountAccess(accID) == FALSE)
                return NULL;
               
              authorisationList = TaxiAgentDataAccessRestrictor.getTaxiAuthorisationRecords(accId);
            }
            
            System.debug('[authorisationList]' + authorisationList);
            return authorisationList;
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountLicences','getAuthorisationRecords',ex.getMessage(),ex);
            return null;
        }   
    }
    
    //method to log return request for the selected authorisation record
    @AuraEnabled
    public static String surrenderAuthorisation(String authorisationId) {
        
        try {
        
            List<Authorisation__c> authorisationList = [SELECT Id, Authorisation_Type__c, Name, Start_Date__c, End_Date__c,
                                                        Status__c, Service_Provider__r.Name, Service_Provider__r.Notice_Email__c, isGranted__c,
                                                        Decision_Made_By__c, Decision_Reason__c, Record_Type_Dev_Name__c, Operation_Area__c
                                                        FROM Authorisation__c
                                                        WHERE Id = :authorisationId];
            
            if(authorisationList.size() > 0) {
                
                User loggedInUser = GlobalUtility.getLoggedInUser();
                authorisationList[0].Decision_Made_By__c = UserInfo.getUserId();
                authorisationList[0].Decision_Reason__c = GlobalConstants.AUTHORISATION_SURRENDER_REASON;
                authorisationList[0].Return_Requested__c = TRUE;
                
                update authorisationList;
                
                //Id supportRequestCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
                Id returnRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CANCEL_SUSPEND_VARY_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
                
                Case newSupportCase = new Case();
                newSupportCase.Subject = GlobalConstants.SURRENDER_LICENCE_CASE_SUBJECT;
                newSupportCase.Date_Submitted__c = System.now();
                newSupportCase.RecordTypeId = returnRecordTypeId;
                newSupportCase.AccountId = loggedInUser.AccountId;
                newSupportCase.ContactId = loggedInUser.ContactId;
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
                
                authorisationList[0].Related_Request_Case_Id__c = newSupportCase.Id;
                authorisationList[0].Decision_Made_By__c = UserInfo.getuserId();
                authorisationList[0].Decision_Reason__c = GlobalConstants.SURRENDER_LICENCE_CASE_SUBJECT;
                
                update authorisationList[0];
                
                return 'SUCCESS';
            }
            return NULL;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','surrenderAuthorisation',ex.getMessage(),ex);
            return null;
        }
    }
    
    /*Function that validates if authorisation record should be allowed
     *for variation or not.
     */
    @AuraEnabled
    public static String validateAuthorisationRecord(String authId) { 
     
        try {
            
            Authorisation__c tempAuth = [SELECT Status__c, Authorisation_Name__c,
                                         Eligible_For_Renewal__c, End_Date__c,
                                         Licence_Class__c, Application__c, Payment_Frequency__c,
                                         Can_Attempt_Licence_Renewal__c, Licence_Fee__c, Operation_Area__c
                                         FROM Authorisation__c
                                         WHERE Id = :authId];
            
            if(tempAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY 
               || tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS 
               || tempAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY
               || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) {
                   
                   return JSON.serialize(tempAuth);    
               }
            //return 'SUCCESS-'+tempAuth.Eligible_For_Renewal__c+'-'+tempAuth.Can_Attempt_Licence_Renewal__c;

            return 'ERROR'; 
        }  
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountLicences','validateAuthorisationRecord',ex.getMessage(),ex);
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static boolean isExistingTransferApplicationOpen(String authorisationId) {
        
        try {
            
            if(GlobalUtility.getLoggedInUser().Profile.Name == GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME 
                && GlobalUtility.agentHasAuthorisationAccess(authorisationId) == FALSE)
                return NULL;
            
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, 
                                    Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c
                                    FROM Case 
                                    WHERE IsClosed = false 
                                    AND RecordTypeId =: transferRecordTypeId 
                                    AND Type =: GlobalConstants.SERVICE_TYPE_TAXI
                                    AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER
                                    AND Authorisation__c =: authorisationId];
            
            if(casesList.size() > 0) {
                return true;
            }
            else {
                return false;
            }
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'isExistingTransferApplicationOpen', e.getMessage(), e);
            return null;
        }
    }
    
    @AuraEnabled
    public static String checkOtherSubTypeCasesforAuthorisation(String authorisationId) {
        
        try {
           
           if(GlobalUtility.getLoggedInUser().Profile.Name == GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME
               && GlobalUtility.agentHasAuthorisationFullAccess(authorisationId) == FALSE)
              return GlobalConstants.UNAUTHORISED_ACCESS;
            
           Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
           Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
           
           Authorisation__c tempAuth = [Select Name, End_Date__c from Authorisation__c where id =: authorisationId];
           String authorisationName = tempAuth.Name;
            
           List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c
                                    FROM Case
                                    WHERE (RecordTypeId =: taxiLicenseAdministrationRecordTypeId OR RecordTypeId =: transferRecordTypeId)
                                    AND (Status != 'Closed')
                                    AND Type =: GlobalConstants.TAXI_CASE_TYPE
                                    AND (Sub_Type__c =: GlobalConstants.UNSUSPEND_REQUEST_TYPE OR Sub_Type__c =: GlobalConstants.SUSPEND_CASE_SUB_TYPE
                                         OR Sub_Type__c =: GlobalConstants.CANCEL_CASE_SUB_TYPE OR Sub_Type__c =: GlobalConstants.EXPIRY_CASE_SUB_TYPE
                                         OR Sub_Type__c = 'Transfer - Proposed Owner')
                                    AND Authorisation__r.Name =: authorisationName];
            
            System.debug('Check this -->'+casesList);
            System.debug('RecordTypeId -->'+taxiLicenseAdministrationRecordTypeId);
            System.debug('RecordTypeId -->'+transferRecordTypeId);
            System.debug('Type -->'+ GlobalConstants.TAXI_CASE_TYPE);
            System.debug('Authorisation__c -->'+authorisationId);
            
            //P2PSUPPORT-147 Don't allow surrender if the End Date is less than or equal to 28 days
            Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
            if(tempAuth.End_Date__c <= currentPlus28Days){
                return 'RequestInRenewalPeriod';
            }
            /*Obsolete code
            List<Case> getExistingTransferCase = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, RecordTypeId FROM Case
                                                         WHERE Authorisation__c =: authorisationId AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER AND RecordTypeId =:transferRecordTypeId];
            */
            if(casesList.size() > 0) { 
                return 'OtherCaseExists';
            }
            else {
                return 'NoOtherCaseExists';
            }
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'checkSurrenderCasesforAuthorisation', e.getMessage(), e);
            return null;
        }
    }
    
    @AuraEnabled
    public static boolean checkSurrenderCasesforAuthorisation(String authorisationId) {
        
        try {
            
            Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();            
            
            List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c, Status, Sub_Status__c, 
                                    Transfer_Reason__c, Licence_Fee_Due__c, Beneficiary_Type__c, Is_Privacy_Statement_Declared__c, Origin
                                    FROM Case
                                    WHERE RecordTypeId =: taxiLicenseAdministrationRecordTypeId 
                                    AND (Status != 'Closed' AND Sub_Status__c != 'Approved')
                                    AND Type =: GlobalConstants.TAXI_CASE_TYPE
                                    AND (Sub_Type__c =: GlobalConstants.SURRENDER_CASE_SUB_TYPE)
                                    AND Authorisation__c =: authorisationId];
            
            if(casesList.size() > 0) { 
                return true;
            }
            else {
                return false;
            }
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TaxiManageAccountLicences', 'checkSurrenderCasesforAuthorisation', e.getMessage(), e);
            return null;
        }
    }
    
    //method used for agents to return the account data for specified accountId
    @AuraEnabled
    public static String getAccountDataForAgents(String accId){
        
        if(GlobalUtility.getLoggedInUser().Profile.Name == GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME 
             && GlobalUtility.agentHasAccountAccess(accId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
        Account requiredAccount = [SELECT Name, Customer_Number__c FROM Account WHERE Id =:accId];
        return JSON.serialize(requiredAccount);
    }  
    
    //method to fetch map of authorisation record id vs active authorisation record belonging to community user's account
    @AuraEnabled
    public static Map<Id, Authorisation_Agent__c> getAuthorisationAgentMap() {
       
       String requiredAccId = GlobalUtility.getLoggedInUser().AccountId;
       
       Map<Id, Authorisation_Agent__c> tempAuthAgentMap = new Map<Id, Authorisation_Agent__c>();
       
       for(Authorisation_Agent__c tempAuthAgent : [SELECT Account__c, Account__r.Name, Agreement_Type__c, Approved_Date__c,
                                                    Expiry_Date__c, Authorisation__c, Authorisation__r.Authorisation_Type__c, Status__c
                                                    FROM Authorisation_Agent__c
                                                    WHERE Authorisation__r.Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE
                                                    AND (Authorisation__r.Status__c = 'Granted' OR Authorisation__r.Status__c = 'Suspended')
                                                    AND Authorisation__r.Service_Provider__c = :requiredAccId
                                                    AND Status__c = :GlobalConstants.STATUS_ACTIVE]) {
              
             tempAuthAgentMap.put(tempAuthAgent.Authorisation__c, tempAuthAgent);                                       
       }
       
       return tempAuthAgentMap;
    }
}