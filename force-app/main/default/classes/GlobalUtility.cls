/*
Utility class containing globally acessed methods
*/
public without sharing class GlobalUtility {
    
    public static Boolean ALLOW_FILE_DELETE = false;
    
    //utility method to return details of ASP record types
    public static Set<Id> retrieveASPApplicationRecordTypes(){
        Set<Id> qualifiedRecordTypes = new Set<Id>();
        qualifiedRecordTypes.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.CASE_RECORDTYPE_CORPORATION).getRecordTypeId());
        qualifiedRecordTypes.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId());
        qualifiedRecordTypes.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(
            GlobalConstants.CASE_RECORDTYPE_PARTNERSHIP).getRecordTypeId());    
        
        
        return qualifiedRecordTypes;
    }
        
    //utility method to return details of logged in details
    public static User getLoggedInUser(){
        
        User loggedInUser = [SELECT ContactId, Name, FirstName, LastName, Email, Account.Name, Contact.Id, Account.OwnerId,
                             Contact.AccountId, Contact.Account.Name, AccountId, 
                             Account.Record_Type_Dev_Name__c, UserType, 
                             Account.ACN__c,Account.ABN__c,Account.Customer_Number__c,
                             Account.Document_Delivery_Preference__c, Account.Notice_Email__c, Account.Notice_Address_City__c,
                             Account.Notice_Address_Postal_Code__c, Account.Notice_Address_Country__c, Account.Notice_Address_State__c, Account.Notice_Address_Street__c,
                             Account.Phone, Account.Registered_Business_Name__c, Contact.Role__c,
                             Contact.Salutation, Contact.FirstName,Contact.LastName,Contact.MobilePhone,
                             Contact.Birthdate,Contact.Email, Contact.Other_given_name__c, Contact.Australian_Driver_Licence_Number__c, 
                             Contact.State__c, Contact.Phone, Contact.Other_Name_Details__c, 
                             Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, 
                             Contact.MailingPostalcode, Contact.Contact_Type__c, Profile.Name
                             FROM User
                             WHERE Id =: UserInfo.getUserId()];
        
        return loggedInUser;
    }
    
    public static List<NetworkMember> getNetworkMemberList(){	
     List<NetworkMember> NetworkMemberList= [SELECT Id, NetworkId, MemberId, PreferencesDisableAllFeedsEmail FROM NetworkMember where	
                                             networkId in (select Id from Network where Name in ('Industry Portal','Taxi Licence'))];	
        return NetworkMemberList;	
    }
    
    //utility method to return ASP user profile
    public static Profile getASPProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.ASP_PROFILE_NAME];
        return p;
    }
    
    //utility method to return PSP user profile
    public static Profile getPSPProfile(){
        Profile p = [SELECT Name FROM Profile WHERE Name = :GlobalConstants.PSP_PROFILE_NAME];
        return p;
    }
    
    //utility method to return System Admin user profile
    public static Profile getSysAdminProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.ADMIN_PROFILE_NAME];
        return p;
    }
    
    //utility method to return System Admin user profile
    public static Profile getP2POperationsLevel1Profile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.P2P_OPERATIONS_LEVEL_1];
        return p;
    }
    
    //utility method to return P2P Compliance user profile
    public static Profile getP2PComplianceProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.P2P_COMPLIANCE];
        return p;
    }
    
    //utility method to return taxi licence user user profile
    public static Profile getTaxiLicenceUserProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME];
        return p;
    }
    
    //utility method to return taxi agent user user profile
    public static Profile getTaxiAgentUserProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME];
        return p;
    }
    
    //utility method to return Account Manager
    public static Profile getTaxiAccountManagerProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME];
        return p;
    }
    
    //utility method to return Taxi And ASP user profile
    public static Profile getTaxiASPProfile(){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.Taxi_ASP_PROFILE_NAME];
        return p;
    }
    
    //Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause) {
        
        try{
            
            String selects = '';
            
            if(whereClause == null || whereClause == ''){ return null; }
            
            // Get a map of field name and field token
            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
            list<string> selectFields = new list<string>();
            
            if(fMap != null){
                
                for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if (fd.isCreateable()){ // field is creatable
                        selectFields.add(fd.getName());
                    }
                }
            }
            
            if(!selectFields.isEmpty()) {
                
                for(string s:selectFields) {
                    selects += s + ',';
                }
                
                if(selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
                return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
            }
            
            return null;            
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'GlobalUtility', 'getCreatableFieldsSOQL', ex.getMessage(),ex);
            return null;
        }  
    }
    
    //utility method to return default Business hours
    public static BusinessHours getDefaultBusinessHours(){
        return [SELECT Id, MondayStartTime, MondayEndTime FROM BusinessHours WHERE isDefault = true];    
    }
    
    //validates if passed datetime is within configured business hours and out of holidays
    public static boolean isInBusinessHours(BusinessHours bh, DateTime dateTimeToCheck) {
        
        try {
            
            return BusinessHours.isWithin(bh.Id, dateTimeToCheck);
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'GlobalUtility', 'isItBusinessHours', ex.getMessage(),ex);
            return NULL;
        }
    }
    
    public static Map<String, Id> getCustomerPortalProfiles(){
        Map<String, Id> profiles = new Map<String, Id>();
        for(Profile cspProfile : [SELECT Id, Name FROM Profile WHERE UserType = :GlobalConstants.CUSTOMER_COMMUNITY_USER_TYPE]){
            profiles.put(cspProfile.Name, cspProfile.Id);
        }
        return profiles;
    }
    
    public static String getAccEntityType(String recordTypeName){
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION)
            return Label.Account_Entity_Type_Corporate;
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)
            return Label.Account_Entity_Type_Individual;
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP)
            return Label.Account_Entity_Type_Individual_Partnership;
        
        if(recordTypeName == GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP)
            return Label.Account_Entity_Type_Corporate_Partnership;
        
        return Label.Account_Entity_Type_Individual;
    }
    
    public static Boolean isInternalUser(){
        String userType = UserInfo.getUserType();
        if(userType == GlobalConstants.CUSTOMER_COMMUNITY_USER_TYPE)
            return false;
        else
            return true;
    }
    
    //function to check if current time is within configured downtime settings for ASP portal
    //if yes then returns appropriate configured message, else returns NULL
    public static String validateIsASPDowntimeMessageConfigured(String downtimeMessageType) {
        
        List<ASP_Portal_Downtime_Setting__mdt> aspDowntimeSettings = new List<ASP_Portal_Downtime_Setting__mdt>();
        aspDowntimeSettings = [SELECT DeveloperName, Start_Time__c, End_Time__c, Message__c
                               FROM ASP_Portal_Downtime_Setting__mdt
                               WHERE DeveloperName = :downtimeMessageType
                               AND Start_Time__c != NULL
                               AND End_Time__c != NULL];
        
        DateTime currentDateTime = DateTime.Now();
        Integer offset = UserInfo.getTimezone().getOffset(currentDateTime);
        currentDateTime = currentDateTime.addSeconds(offset/1000);
        currentDateTime = DateTime.newInstance(currentDateTime.date(), Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), 0, 0));
        
        DateTime downTimeConfigStartDate = aspDowntimeSettings[0].Start_Time__c.addSeconds(offset/1000);
        DateTime downTimeConfigEndDate = aspDowntimeSettings[0].End_Time__c.addSeconds(offset/1000);
        
        System.debug('Config. Start Date Time: '+downTimeConfigStartDate);
        System.debug('Config. End Date Time: '+downTimeConfigEndDate);
        System.debug('Current Date Time: '+currentDateTime);
        System.debug('User has permission : ' + FeatureManagement.checkPermission(GlobalConstants.BYPASS_PORTAL_DOWNTIME_PERMISSION));
        
        //validate if there is come time configured and if yes does current time belong to that time frame 
        if((!aspDowntimeSettings.isEmpty() && !Test.isRunningTest())
           && currentDateTime >= downTimeConfigStartDate
           && currentDateTime <= downTimeConfigEndDate
           && !String.isBlank(aspDowntimeSettings[0].Message__c)
           && !isUserHasAssignedPermissionSet(GlobalConstants.BYPASS_PORTAL_DOWNTIME_PERMISSION))
            return aspDowntimeSettings[0].Message__c;
        
        return NULL;
    }

    //Retrive Nth business day
    public static Date retrieveNthBusinessDay(Date startDate, Integer NUMBER_OF_BUSINESS_DAYS){
        
        BusinessHours businessHours = [SELECT Id, MondayStartTime, MondayEndTime FROM BusinessHours WHERE isDefault = true];
        Date referenceDate = System.today();
        Integer offsetDays = 1;
        while(offsetDays < NUMBER_OF_BUSINESS_DAYS){
            referenceDate = GlobalUtility.retrieveBusinessDay(referenceDate, 1, businessHours);
            offsetDays++;
        }
        
        return referenceDate;
    }
        
    public static Date retrieveBusinessDay(Date startDate, Integer offsetDays, BusinessHours bhr){
        Integer SECS_IN_MIN = 60;
        Integer MINS_IN_HR = 60;
        Integer MILLIS_IN_SEC = 1000;
        
        if( !BusinessHours.isWithin(bhr.Id , startDate)){
            offsetDays++;
        }  
        Long startMillis = bhr.MondayStartTime.hour()* MINS_IN_HR* SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayStartTime.minute() * SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayStartTime.second() * MILLIS_IN_SEC + bhr.MondayStartTime.millisecond();
        
        Long endMillis = bhr.MondayEndTime.hour()* MINS_IN_HR* SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayEndTime.minute() * SECS_IN_MIN * MILLIS_IN_SEC 
            + bhr.MondayEndTime.second() * MILLIS_IN_SEC + bhr.MondayEndTime.millisecond();
        
        Long millisToAdd = (endMillis - startMillis) * offsetDays;
        
        Date businessDate = BusinessHours.add(bhr.Id, startDate, millisToAdd).date();
        System.debug(businessDate );
        return businessDate;
    }
    
    /*
     * @Description: Helper method to generate username for portal users based on contact first name and contact number.
     */
    public static Map<Id, String> generateUsernames(List<Id> conIds){
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, Contact_Number__c FROM Contact WHERE Id IN :conIds]);
        Map<Id, String> conVsUserName = new Map<Id, String>();
        for(Id conId : contacts.keySet()){
            conVsUserName.put(conId, generateUserName(contacts.get(conId)));
        }
        return conVsUserName;
    }
    
    //generate username in the format of 'FirstName.ContactNumber@pointtopoint.com'
    public static String generateUserName(Contact con){
       
       if(con == null){
           con = new Contact(FirstName = 'pointtopoint');
       }
       
       String firstName = con.FirstName;
       // Remove spaces from first name
       if(String.isNotBlank(firstName)){
           firstName = firstName.replaceAll( '\\s+', '');
       }       
       //return con.FirstName + '.' + (con.Contact_Number__c != null? con.Contact_Number__c : '' ) + '@pointtopoint.com';
       return firstName + '.' + (con.Contact_Number__c != null? con.Contact_Number__c : '' ) + '@pointtopoint.com';    
    }
    
    //function returns DDR service agreement content configured in custom metadata type- Levy DDR Service Agreement
    public static String getDDRServiceAgreement() {     
        
        List<Levy_DDR_Service_Agreement__mdt> ddrServiceAgreement = new List<Levy_DDR_Service_Agreement__mdt>();
        ddrServiceAgreement = [SELECT DeveloperName, Agreement_Content__c
                               FROM Levy_DDR_Service_Agreement__mdt
                               WHERE DeveloperName = :GlobalConstants.DDR_SERVICE_AGREEMENT_NAME
                               LIMIT 1];
        
        return ddrServiceAgreement.size() > 0 ? ddrServiceAgreement[0].Agreement_Content__c : '';
    }
    
    /* helper method to validate if registration record is pending with OSR or not */
    public static Boolean checkIfWithOSR(Tax_Payer_Registration__c taxPayerRegistration) {
        
        //fetch the current status of registration record  from the server
        Tax_Payer_Registration__c tempRegistration = [SELECT Status__c, Sub_Status__c, Revenue_NSW_Status__c 
                                                      FROM Tax_Payer_Registration__c
                                                      WHERE Id = :taxPayerRegistration.Id];
        
        
        return tempRegistration.Status__c == GlobalConstants.STATUS_ACTIVE && tempRegistration.Revenue_NSW_Status__c == GlobalConstants.REVENUE_NSW_STATUS_PENDING ? TRUE : FALSE;
        
    }
    
    /* helper method to clone specified registration record */
    public static Tax_Payer_Registration__c cloneRegistrationRecord(Tax_Payer_Registration__c taxPayerRegistration) {
        
        
        String soql = GlobalUtility.getCreatableFieldsSOQL('Tax_Payer_Registration__c','id=\''+taxPayerRegistration.Id+'\'');
        return soql != NULL ? (Tax_Payer_Registration__c)Database.query(soql) : NULL;
    }
    
    /* function to check if there exists any open cases related to specific registration record */
    public static Boolean hasRelatedOpenCases(String accountId, String registrationId) {     
        
        //query to all fetch related open cases agains the registration record
        List<Case> relatedOpenCases = [SELECT Status, Sub_Status__c FROM Case
                                       WHERE Tax_Payer_Registration__c = :registrationId 
                                       AND AccountId = :accountId
                                       AND Record_Type_Dev_Name__c = :GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_DEV_NAME
                                       AND Type = :GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                                       AND (Sub_Type__c = :GlobalConstants.Levy_Rebate_Case_SUB_TYPE
                                            OR Sub_Type__c = :GlobalConstants.Levy_Exemption_Case_SUB_TYPE)
                                       AND isCLosed = FALSE];
        
        
        return relatedOpenCases.size() > 0 ? TRUE : FALSE;
    }
    
    /* function to validate if only existing record needs to be updated, or clone for older version needs to be created */
    public static List<Tax_Payer_Registration__c> validateRegistrationUpdates(List<Tax_Payer_Registration__c> relatedRegistrations) {
      
      List<Tax_Payer_Registration__c> relatedRegistrationsToUpsert = new List<Tax_Payer_Registration__c>();
      
      for(Tax_Payer_Registration__c tempRegistration : relatedRegistrations) {
        
        //Scenario 1: Existing registration record status is 'Active' and sub status is 'Completed' and Revenue NSW status is not 'Pending'
        //Scenario 2: Existing registration record status is 'Active' and sub status is 'Pending with P2P and Revenue Status is 'Success' or 'Error'
        //then maintain the old version by clonning the record
        if(tempRegistration.Status__c == GlobalConstants.STATUS_ACTIVE 
            && (tempRegistration.Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED
                && tempRegistration.Revenue_NSW_Status__c != GlobalConstants.REVENUE_NSW_STATUS_PENDING
               || (tempRegistration.Sub_Status__c == GlobalConstants.SUB_STATUS_PENDING_P2P
                   && (tempRegistration.Revenue_NSW_Status__c == GlobalConstants.REVENUE_NSW_STATUS_SUCCESS
                       || tempRegistration.Revenue_NSW_Status__c == GlobalConstants.REVENUE_NSW_STATUS_ERROR)
                  )
               )) {
           
            tempRegistration = cloneRegistrationRecord(tempRegistration);
            Tax_Payer_Registration__c clonnedRegistration = tempRegistration.clone(false, true, false, false);
            clonnedRegistration.Status__c = GlobalConstants.STATUS_SUPERSEDED;
            relatedRegistrationsToUpsert.add(clonnedRegistration);
            
            //if registration sub status is completed and levy is exempted, update RNSW status as NA else pending
            if(tempRegistration.Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED && tempRegistration.Exemption_Approved__c == TRUE)
              tempRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
            else {
            
              tempRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
              if(tempRegistration.Sub_Status__c != GlobalConstants.SUB_STATUS_PENDING_P2P)
               tempRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW;
            }
        }
        
        //add existing record to the list as it always need to be updated
        //irrespective of whether clonned old version needs to be created or not
        relatedRegistrationsToUpsert.add(tempRegistration);        
      }
      
      return relatedRegistrationsToUpsert;
    }
    
    public static Boolean updateTaxPayerRegistrationRevenueNSWStatus(Id taxPayerId) {
        
        
        Tax_Payer_Registration__c taxPayerRegistration = new Tax_Payer_Registration__c();
        taxPayerRegistration.Id = taxPayerId;
        taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_ERROR;
        
        update taxPayerRegistration;
        return true;
    }
    
    public static Id getOwnerId() {
    
        Id ownerid = [SELECT Owner_Id__c from Community_Account_Contact_Owner__mdt limit 1][0].Owner_Id__c;
        return ownerid;
    }
    
    public static List<Authorisation__c> getAgentAccessibleAuthorisations(String authorisationAccountId) {
        
        Set<String> accessibleAuthIds = new Set<String>();
        
        for(Authorisation_Agent__c tempAuthAgent : [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                     Status__c, Expiry_Date__c
                                                     FROM Authorisation_Agent__c
                                                     WHERE Authorisation__r.Service_Provider__c = :authorisationAccountId
                                                     AND Status__c = :GlobalConstants.STATUS_ACTIVE]) {
              
              accessibleAuthIds.add(tempAuthAgent.Authorisation__c);                                        
        }
        
        return [SELECT Name, Agency__c, Agreement_Type__c 
                 FROM Authorisation__c
                 WHERE Id IN :accessibleAuthIds];
    }
    
    public static Boolean agentHasAccountAccess(String requiredAccountId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__r.Service_Provider__c = :requiredAccountId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    }
    
    public static Boolean agentHasAccountFullAccess(String requiredAccountId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__r.Service_Provider__c = :requiredAccountId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                         AND Agreement_Type__c = :GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    }
    
    public static Boolean agentHasAccountTransferAccess(String requiredAccountId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__r.Service_Provider__c = :requiredAccountId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                         AND Agreement_Type__c = :GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    }
    
    public static Boolean agentHasAuthorisationAccess(String requiredAuthorisationId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__c = :requiredAuthorisationId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    }
    
    public static Boolean agentHasAuthorisationFullAccess(String requiredAuthorisationId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__c = :requiredAuthorisationId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                         AND Agreement_Type__c = :GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE_FULL_ACCESS];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    }
    
    public static Boolean agentHasAuthorisationTransferAccess(String requiredAuthorisationId) {
        
        List<Authorisation_Agent__c> activeAuthAgent = [SELECT Account__c, Authorisation__c,Authorisation__r.Service_Provider__c,
                                                         Status__c, Expiry_Date__c
                                                         FROM Authorisation_Agent__c
                                                         WHERE Authorisation__c = :requiredAuthorisationId
                                                         AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                         AND Agreement_Type__c = :GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE];
                                                         
        return activeAuthAgent.size() > 0 ? TRUE : FALSE;
    } 
    
    //----This method checks if User is assigned with given permission or not
    public static Boolean isUserHasAssignedPermissionSet(String permissionName) {
      
      return FeatureManagement.checkPermission(permissionName);
    }   
       
    /**
     * Utility method to get the list of granted TSP Authorisations
     */
    public static List<Authorisation__c> getValidTSPAuthorisations(Id pServiceProviderId) {
    
        return [SELECT Id 
                FROM Authorisation__c 
                WHERE 
                Service_Provider__c = :pServiceProviderId
                AND Authorisation_Type__c = 'TSP' 
                AND Status__c IN ('Granted With Conditions', 'Granted Unconditionally')];
    }

    /**
     * Utility method to get the list of granted Taxi Licence Authorisations
     */
    public static List<Authorisation__c> getValidTaxiLicences(Set<String> pPlateNumbers, Integer pMaxRows) {
        
        return [SELECT Id, Plate_Number__c
                FROM Authorisation__c 
                WHERE Status__c = 'Granted' 
                AND Authorisation_Type__c = 'Taxi Licence'
                AND Plate_Number__c IN :pPlateNumbers LIMIT :pMaxRows];
    }
    
    /*Utility method to get the Locked Record Type Id of the Notice Record*/
    public static String getNoticeLockedRecordTypeId(Id noticeRecord){
        String lockedRTId = NULL;
        Map<Id, String> mapNoticeRTIdNDevName= new Map<Id,String>();
        Map<String, String> mapDevNameNNoticeRTId= new Map<String,String>();
        
        try{
            List<RecordType> noticeRecordType = [SELECT Id, DeveloperName   
                                                 FROM RecordType
                                                 WHERE SobjectType ='Notice_Record__c' AND IsActive =TRUE];
            
            for(RecordType nRT :noticeRecordType){
                mapNoticeRTIdNDevName.put(nRT.Id,nRT.DeveloperName);
                mapDevNameNNoticeRTId.put(nRT.DeveloperName,nRT.Id);
            }
            
            String currentNoticeApiName =  mapNoticeRTIdNDevName.get(noticeRecord);
            System.debug('currentNoticeApiName :'+currentNoticeApiName);
            
            List<Notice_Record_Config__mdt> noticeRecordConfig= [SELECT Locked_Record_Type_API_Name__c 
                                               FROM Notice_Record_Config__mdt
                                               WHERE Record_Type_API_Name__c=:currentNoticeApiName LIMIT 1];
            
            lockedRTId = mapDevNameNNoticeRTId.get(noticeRecordConfig[0].Locked_Record_Type_API_Name__c);
            
        } catch(exception ex){
            System.debug('Exception :'+ex.getMessage());
        }
        
        return lockedRTId;
    }
        
        
        
}