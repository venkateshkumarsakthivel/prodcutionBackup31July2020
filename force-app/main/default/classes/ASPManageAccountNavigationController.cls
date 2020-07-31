public class ASPManageAccountNavigationController {
    
    //This function checks if Account Type of logged in user is Individual_Partnership or Corporate_Partnership. 
    @AuraEnabled
    public static Boolean validateIsPartnerAccount(){
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();
            
            List<Account> account = [SELECT Id, Record_Type_Dev_Name__c
                                     FROM Account WHERE Id =: loggedInUser.AccountId];
            
            if(account.size() > 0 && account[0].Record_Type_Dev_Name__c == 'Individual_Partnership' || account[0].Record_Type_Dev_Name__c == 'Corporate_Partnership') {
                return TRUE;
            }
            
            return FALSE;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountNavigationController','getAccountDetails',ex.getMessage(),ex);
            return FALSE;
        }
    }
}