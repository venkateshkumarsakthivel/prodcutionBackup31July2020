//This class is used to manage account page from Manage acount menu.

public with sharing class TaxiManageAccountCases {
    
    public class BaseException extends Exception {}
    /*This function retrives the record of logged in user. */
    @AuraEnabled
    public static String getLoggedInUserAccount() {
        
        User userRec = GlobalUtility.getLoggedInUser();
        system.debug('Account.Name: '+UserRec.AccountId);
        Account act = userRec.Account;
        return JSON.serialize(act);  
    }
    
    /* 
     * Helper method to retrieve all notice records associated with accounts
     * 
     */
    @AuraEnabled
    public static String getNoticeDetails(String requiredAccId){
        
        String noticesStr;
        
        try {  
        
            User user =  GlobalUtility.getLoggedInUser();
            
            Id accountId = String.isBlank(requiredAccId) ? user.AccountId : requiredAccId;
            
            List<Notice_Record__c> notices = [SELECT Id, Name,Served_to__r.Name, 
                                              Date_Issued__c, Method_of_Service__c, Notice_Type__c
                                              FROM Notice_Record__c 
                                              WHERE Issued_To__c = :accountId AND Show_On_Industry_Portal__c = 'Yes'  
                                              ORDER BY Date_Issued__c DESC];
             
            
            noticesStr = JSON.serialize(notices);            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(
                GlobalConstants.ERROR,'ASPManageAccountCases'
                ,'getNoticeDetails',ex.getMessage(),ex);
        }
        return noticesStr;
    }    
    
    
    /* Used in Applicaions tab
     * This function retrives the List of Applications related to logged in user sorted by descending order in string format. 
     */
    @AuraEnabled
    public static String getApplicationCases() {
        
         String NON_RENEWALEXPIRY = 'Non Renewal Expiry';
        
        Id rtIdforTaxiIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiJointHolder = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_JOINT_HOLDER_APPLICATION).getRecordTypeId();
        Id rtIdforTransfer = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Id rtIdforTaxiLicenceAdminsitration = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Id rtIdforReviewableDecisions       = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_REVIEWABLE_DECISIONS).getRecordTypeId();
       
        User user = GlobalUtility.getLoggedInUser();
        
        Id communityId =  Network.getNetworkId();
        system.debug('++++++++'+communityId);
        
        Id accountId = user.AccountId;
        
        List<Case> casesList = [SELECT Id, AccountId, Authorisation__c, Account.Name, CaseNumber, Service_Type__c, 
                                Status, CreatedBy.Name, LastModifiedDate, Contact.Name, RecordType.Name,
                                Is_WAT_Application__c, Sub_Status__c, Sub_Type__c, IsClosed, Date_Submitted__c,CreatedDate,
                                (SELECT Id, Status FROM Orders__r)
                                FROM Case 
                                WHERE AccountId = :accountId
                                AND (Sub_Type__c!= :NON_RENEWALEXPIRY)
                                AND (RecordTypeId = :rtIdforTaxiIndividual 
                                     OR RecordTypeId = :rtIdforTaxiCorporation
                                     OR RecordTypeId = :rtIdforTaxiJointHolder
                                     OR RecordTypeId = :rtIdforTransfer
                                     OR (RecordTypeId = :rtIdforTaxiLicenceAdminsitration AND Sub_Type__c!= :GlobalConstants.SURRENDER_CASE_SUB_TYPE)
                                     OR RecordTypeId = :rtIdforReviewableDecisions
                                     OR(Type = :GlobalConstants.TAXI_CASE_TYPE 
                                        AND (Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER 
                                             OR Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                             //OR Sub_Type__c = :GlobalConstants.SURRENDER_CASE_SUB_TYPE
                                            ))) 
                                AND (Status = :GlobalConstants.CASE_DRAFT
                                     OR Status = :GlobalConstants.APPLICATION_STATUS_LODGED
                                     OR (Status = :GlobalConstants.CASE_NEW AND Is_WAT_Application__c = TRUE)
                                     OR (Status = :GlobalConstants.CASE_NEW AND Origin = :GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL))
                                ORDER BY CreatedDate 
                                DESC];
        String cases = JSON.serialize(casesList);
        
        return cases;   
        
    }
    
    @AuraEnabled
    public static String cancelTaxiApplication(Case caseRec) {
           
        return TaxiAgentDataAccessProvider.cancelTaxiApplication(caseRec);
    }
    
    //method used for agents to return the account data for specified accountId
    @AuraEnabled
    public static String getAccountDataForAgents(String accId){
        
        if(GlobalUtility.agentHasAccountAccess(accId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
        
        return TaxiAgentDataAccessProvider.getAccountDataForAgents(accId);
    }
    
    /* Used in Applicaions tab
     * This function retrives the List of Applications for agents sorted by descending order in string format. 
     */
    @AuraEnabled
    public static String getApplicationCasesForAgent(String requiredAccId) {
       
       if(GlobalUtility.agentHasAccountAccess(requiredAccId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
       return TaxiAgentDataAccessProvider.getApplicationCasesForAgent(requiredAccId);
    }
}