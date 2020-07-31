/**
* Server side rest resource controller for levy registeration update internal form
*/
public with sharing class LevyRegistrationUpdateInternalFormCon {

   
   /* This function retrives Tax Payer Registation details for specified Id */
   @AuraEnabled
   public static Tax_Payer_Registration__c getTaxPayerRegistrationDetails(String registrationId){
     
     try {
       
       Tax_Payer_Registration__c tempRegistration = [SELECT Service_Provider_Name__c, Status__c FROM Tax_Payer_Registration__c WHERE Id = :registrationId];
       
       LevySectionDataWrapper tempSectionDataWrapper = new LevySectionDataWrapper(registrationId, tempRegistration.Service_Provider_Name__c); 
       tempSectionDataWrapper.loadCaseSectionData();
       return tempSectionDataWrapper.levyRegistrationRec;
         
     }
     catch(Exception ex) {
            
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationUpdateInternalFormCon','getTaxPayerRegistrationDetails',ex.getMessage(),ex);
       return NULL;
     }
   }
   
   /* This funtion initialises the regisrtation record for updation before sending to the form */
   @AuraEnabled
   public static Tax_Payer_Registration__c setupTaxPayerRegistrationDetailsUpdate(Tax_Payer_Registration__c taxPayerRegistration) {
        
        try {

            Tax_Payer_Registration__c tempRegistration = new Tax_Payer_Registration__c();
            
            tempRegistration.Id = taxPayerRegistration.Id;
            
            tempRegistration.ABN__c = taxPayerRegistration.ABN__c;
            tempRegistration.Registered_Business_Name__c = taxPayerRegistration.Registered_Business_Name__c;
            tempRegistration.Levy_Notification_Address_Street__c = taxPayerRegistration.Levy_Notification_Address_Street__c;
            tempRegistration.Levy_Notification_Address_City__c = taxPayerRegistration.Levy_Notification_Address_City__c;
            tempRegistration.Levy_Notification_Address_State__c = taxPayerRegistration.Levy_Notification_Address_State__c;
            tempRegistration.Levy_Notification_Address_Postal_Code__c = taxPayerRegistration.Levy_Notification_Address_Postal_Code__c;
            tempRegistration.Levy_Notification_Address_Country__c = taxPayerRegistration.Levy_Notification_Address_Country__c;
            tempRegistration.Service_Provider_Name__c = taxPayerRegistration.Service_Provider_Name__c;
            tempRegistration.New_Levy_Contact_Added__c = 'No';
            tempRegistration.OwnerId = taxPayerRegistration.OwnerId;
            taxPayerRegistration.Status__c = GlobalConstants.STATUS_ACTIVE;
            
            // JIRA-285 
        tempRegistration.Bank_Account_Holder_s_Name__c =  taxPayerRegistration.Bank_Account_Holder_s_Name__c;
        tempRegistration.Bank_Account_Number__c =         taxPayerRegistration.Bank_Account_Number__c;
       tempRegistration.Financial_Institution_Name__c =  taxPayerRegistration.Financial_Institution_Name__c;
        tempRegistration.BSB__c =                         taxPayerRegistration.BSB__c;
        // levy contact 
       tempRegistration.Levy_Contact__c = taxPayerRegistration.Levy_Contact__c;
       tempRegistration.Person_Enters_Returns_for_Levy__c = taxPayerRegistration.Person_Enters_Returns_for_Levy__c;
       tempRegistration.Annual_Trip_Estimate__c = taxPayerRegistration.Annual_Trip_Estimate__c;
       tempRegistration.Estimated_BSP_Transactions__c = taxPayerRegistration.Estimated_BSP_Transactions__c;
       tempRegistration.Estimated_TSP_Transactions__c = taxPayerRegistration.Estimated_TSP_Transactions__c;
       tempRegistration.Privacy_Declaration__c =  true;    
       tempRegistration.Direct_Debit_Declaration__c = true;     
            return tempRegistration;
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyRegistrationUpdateInternalFormCon', 'setupTaxPayerRegistrationDetailsUpdate', e.getMessage(), e);           
            return NULL;
        }
   }
   
   //method to validate if logged in user from salesforce (non-community) is authorised to perform levy registration update or not
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
}