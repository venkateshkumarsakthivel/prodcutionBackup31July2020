/**
* Data Struture to serialize Tax Payer Registration
*/
public class LevySectionDataWrapper {
    
    public Tax_Payer_Registration__c  levyRegistrationRec;
    
    @TestVisible
    private String registrationId;
    
    @TestVisible
    private String accountId;
    
    public LevySectionDataWrapper(String registrationId, String accountId) {
        
        this.registrationId = registrationId;
        this.accountId = accountId;
    }
    
    public void loadCaseSectionData() {
        
        try {  
            
            System.debug('Registration Id: '+registrationId);
            
            if(registrationId == NULL || registrationId == '') {
                
                User loggedInUser = GlobalUtility.getLoggedInUser();
                
                Tax_Payer_Registration__c newLevyRegistration = new Tax_Payer_Registration__c();
                
                if(!String.isBlank(accountId)) {
                 
                 Account relatedAccount = [SELECT ABN__c, Registered_Business_Name__c, Notice_Address_Street__c, Notice_Address_City__c,
                                           Notice_Address_State__c, Notice_Address_Postal_Code__c, Notice_Address_Country__c
                                           FROM Account
                                           WHERE Id = :accountId];
                                          
                 newLevyRegistration.Service_Provider_Name__c = accountId;
                 newLevyRegistration.ABN__c = relatedAccount.ABN__c;
                 newLevyRegistration.Registered_Business_Name__c = relatedAccount.Registered_Business_Name__c;
                 newLevyRegistration.Levy_Notification_Address_Street__c = relatedAccount.Notice_Address_Street__c;
                 newLevyRegistration.Levy_Notification_Address_City__c = relatedAccount.Notice_Address_City__c;
                 newLevyRegistration.Levy_Notification_Address_State__c = relatedAccount.Notice_Address_State__c;
                 newLevyRegistration.Levy_Notification_Address_Postal_Code__c = relatedAccount.Notice_Address_Postal_Code__c;
                 newLevyRegistration.Levy_Notification_Address_Country__c = relatedAccount.Notice_Address_Country__c;
                 newLevyRegistration.New_Levy_Contact_Added__c = 'No';
                }
                
                this.levyRegistrationRec = newLevyRegistration;
            }
            else {
                
                system.debug('registrationId----->'+registrationId);
                this.levyRegistrationRec  = [SELECT Name, ABN__c, Bank_Account_Holder_s_Name__c, Bank_Account_Number__c, Annual_Trip_Estimate__c, Applied_For_Exemption__c,
                                             Applied_For_Rebate__c, BSB__c, Direct_Debit_Declaration__c, Exemption_Rebate_Declaration__c, Exemption_Comment__c,
                                             Exemption_Reason__c, Rebate_Comment__c, Rebate_Reason__c, Registered_Business_Name__c, Service_Provider_Name__c,
                                             Privacy_Declaration__c, Bank_Name__c, Bank_Suburb__c, Financial_Institution_Name__c, 
                                             Levy_Notification_Address_Street__c, Levy_Notification_Address_City__c, Levy_Notification_Address_State__c, Levy_Notification_Address_Postal_Code__c, Levy_Notification_Address_Country__c,
                                             New_Levy_Contact_Added__c, Person_Enters_Returns_for_Levy__c,
                                             Levy_Contact__c, Levy_Contact_First_Name__c, Levy_Contact_Last_Name__c, Levy_Contact_Email__c, Levy_Contact_Phone__c,
                                             Exemption_Supporting_Documents_Uploaded__c, Rebate_Supporting_Documents_Uploaded__c,
                                             Estimated_TSP_Transactions__c, Estimated_BSP_Transactions__c, Assessment_Rate_Type__c,
                                             Status__c, Sub_Status__c, Date_Registered__c, Revenue_NSW_Status__c
                                             FROM Tax_Payer_Registration__c WHERE Id = :registrationId];
                
            }
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevySectionDataWrapper', 'loadCaseSectionData', e.getMessage()+'REGid#'+registrationId, e);
            
        }
    }
    
}