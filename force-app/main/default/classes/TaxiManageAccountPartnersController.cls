public with sharing class TaxiManageAccountPartnersController {

    //This function retrives account name related to logged in user. 
    @AuraEnabled
    public static String getLoggedInUserAccount() {
        try {
            User loggedInUser = GlobalUtility.getLoggedInUser();
            Account act = loggedInUser.Account;
            return JSON.serialize(act);  
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountPartnersController','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;
        }
    }
    
    // This function retrives all Individual and Corporate Partners related to logged in user's account.
    // Individual Partners => Contacts related to Account with Type = "Individual Partner" 
    // Corporate Partners => Accounts having Corporate_Partner__c as logged in user's account.
    @AuraEnabled
    public static String getAccountPartners() {
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Contact> individualPartners = [SELECT Id, Name, Phone, Email, Contact_Type__c  FROM Contact 
                                               WHERE Contact_Type__c = :GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE 
                                               AND Account.Id = :loggedInUser.AccountId
                                               ORDER BY CreatedDate ASC];
            
            List<Account> corporatePartners = [SELECT Id, Name, Phone, Notice_Email__c FROM Account 
                                                WHERE Corporate_Partner__c = :loggedInUser.AccountId
                                                ORDER BY CreatedDate ASC];
            
            List<Object> allPartners = new List<Object>();
            for(Contact individualPartner : individualPartners) {
                allPartners.add(individualPartner);
            }
            for(Account corporatePartner : corporatePartners) {
                allPartners.add(corporatePartner);
            }
            
            System.debug('[TaxiManageAccountPartnersController : individualPartners]' + individualPartners.size());
            System.debug('[TaxiManageAccountPartnersController : corporatePartners]' + corporatePartners.size());
            System.debug('[TaxiManageAccountPartnersController : getAccountPartners]' + allPartners.size());
            System.debug(allPartners);
            
            String result = JSON.serialize(allPartners);
            System.debug(result);
                
            return result;  
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiManageAccountPartnersController','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;
        }
    }
    
    //method used for agents to return the account data for specified accountId
    @AuraEnabled
    public static String getAccountDataForAgents(String accId){
        
         if(GlobalUtility.agentHasAccountAccess(accId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
         return TaxiAgentDataAccessProvider.getAccountDataForAgents(accId);
    } 
    
    // This function retrives all Individual and Corporate Partners related to logged in user's account.
    // Individual Partners => Contacts related to Account with Type = "Individual Partner" 
    // Corporate Partners => Accounts having Corporate_Partner__c as specified account.
    @AuraEnabled
    public static String getAccountPartnersForAgents(String requestedAccId) {
         
         if(GlobalUtility.agentHasAccountAccess(requestedAccId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
         return TaxiAgentDataAccessProvider.getAccountPartnersForAgents(requestedAccId);
    }
}