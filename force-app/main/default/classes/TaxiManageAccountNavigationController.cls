/*
 * Class on purpose executed in without sharing mode as agents are
 * not having access on account records whose licence they maintain
 */
public without sharing class TaxiManageAccountNavigationController {
    
    //This function checks if Account Type of logged in user is Individual_Partnership or Corporate_Partnership. 
    @AuraEnabled
    public static Boolean validateIsPartnerAccount(String requiredAccId){
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            requiredAccId = String.isBlank(requiredAccId) ? loggedInUser.AccountId : requiredAccId;
            
            Account account = [SELECT Id, Record_Type_Dev_Name__c
                               FROM Account WHERE Id = :requiredAccId];
            
            if(account.Record_Type_Dev_Name__c == 'Individual_Partnership' || account.Record_Type_Dev_Name__c == 'Corporate_Partnership') {
                return TRUE;
            }
            
            return FALSE;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountNavigationController','getAccountDetails',ex.getMessage(),ex);
            return FALSE;
        }
    }
    
    @AuraEnabled
    public static Boolean validateIfAgentHasAccess(String requiredAccId){
       
        Set<String> accessibleAccountIds = new Set<String>();
        
        for(Authorisation_Agent__c tempAuthAgent : [SELECT Authorisation__c, Authorisation__r.Service_Provider__c
                                                     FROM Authorisation_Agent__c
                                                     WHERE Status__c = :GlobalConstants.STATUS_ACTIVE
                                                     AND Authorisation__c != NULL]) {
            
              accessibleAccountIds.add(tempAuthAgent.Authorisation__r.Service_Provider__c);                                           
        }
        
        return accessibleAccountIds.contains(requiredAccId) ? TRUE : FALSE;
    }
    
}