/*
 * Helper class to identify if specific fields are changed on registration record 
 * then update IsAuthorisationUpdate falg on such records. Needed for RNSW integration purpose.
*/
public with sharing class RegIntegrationRelatedUpdateIdentifier {
    
    private Map<Id, Tax_Payer_Registration__c> newRegistrations;
    private Map<Id, Tax_Payer_Registration__c> oldRegistrations;
    
    public RegIntegrationRelatedUpdateIdentifier(Map<Id, Tax_Payer_Registration__c> newRegistrations, Map<Id, Tax_Payer_Registration__c> oldRegistrations){
        
        this.newRegistrations = newRegistrations;
        this.oldRegistrations = oldRegistrations;
    }
    
    /*
     *  Method to identify if specific fields are changed on registration record 
     *  then update IsAuthorisationUpdate falg on such records. Needed for RNSW integration purpose.
     */
    public void validateIntegrationUpdates() {
        
        try {
          
          for(Tax_Payer_Registration__c tempRegistration : newRegistrations.values()) {
            
            Tax_Payer_Registration__c oldRegistration = oldRegistrations.get(tempRegistration.Id);
            
            //check if bank details, notification address or levy contact have changed 
            if((tempRegistration.BSB__c != oldRegistration.BSB__c
                || tempRegistration.Bank_Account_Holder_s_Name__c != oldRegistration.Bank_Account_Holder_s_Name__c
                || tempRegistration.Bank_Account_Number__c != oldRegistration.Bank_Account_Number__c
                || tempRegistration.Levy_Contact__c != oldRegistration.Levy_Contact__c
                || tempRegistration.Levy_Notification_Address_City__c != oldRegistration.Levy_Notification_Address_City__c
                || tempRegistration.Levy_Notification_Address_Postal_Code__c != oldRegistration.Levy_Notification_Address_Postal_Code__c
                || tempRegistration.Levy_Notification_Address_State__c != oldRegistration.Levy_Notification_Address_State__c
                || tempRegistration.Levy_Notification_Address_Street__c != oldRegistration.Levy_Notification_Address_Street__c
                || tempRegistration.Annual_Trip_Estimate__c != oldRegistration.Annual_Trip_Estimate__c
                || tempRegistration.Estimated_BSP_Transactions__c != oldRegistration.Estimated_BSP_Transactions__c
                || tempRegistration.Estimated_TSP_Transactions__c != oldRegistration.Estimated_TSP_Transactions__c
                || tempRegistration.Applied_For_Exemption__c != oldRegistration.Applied_For_Exemption__c
                || tempRegistration.Applied_For_Rebate__c != oldRegistration.Applied_For_Rebate__c)) {
                    
                System.debug('Levy Contact New :'+tempRegistration.Levy_Contact__c);
                System.debug('Levy Contact Old :'+oldRegistration.Levy_Contact__c);
                
                    if(String.isNotBlank(tempRegistration.RNSWCustomerId__c)) {
                        
                        tempRegistration.IsAuthorisationUpdate__c = TRUE;
                        tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                        tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
                    }
                    
                    if(String.isBlank(tempRegistration.RNSWCustomerId__c)) {
                        
                        tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                        tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
                    }
                    
            }    
          }
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RegIntegrationRelatedUpdateIdentifier', 'processApprovalRejectionActions', e.getMessage(), e);
        }
        
    }
}