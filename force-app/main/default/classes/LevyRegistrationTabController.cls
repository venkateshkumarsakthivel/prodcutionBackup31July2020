/**
* Server side rest resource controller for levy registeration tab
*/
public with sharing class LevyRegistrationTabController {
    
    /* This function retrives Account details logged in user. */
    @AuraEnabled
    public static Account getAccountDetails(){
        
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            
            Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c
                           FROM Account
                           WHERE Id =: user.AccountId];
            
            return acc;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean hasAccountNoticeAddress(){
        
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            
            Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c, Notice_Address__c, Notice_Address_Street__c, Notice_Address_City__c, 
                           Notice_Address_State__c, Notice_Address_Postal_Code__c
                           FROM Account
                           WHERE Id =: user.AccountId];
            
            /*if (acc.Notice_Address__c == null || acc.Notice_Address__c == ''){
                return false;
            }*/
            
            if (acc.Notice_Address_Street__c == null || acc.Notice_Address_Street__c == '' 
                ||acc.Notice_Address_City__c == null || acc.Notice_Address_City__c == ''
                ||acc.Notice_Address_State__c == null || acc.Notice_Address_State__c == ''
                ||acc.Notice_Address_Postal_Code__c == null || acc.Notice_Address_Postal_Code__c == ''){
                return false;
            }
            
            return true;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    /* function returns authorisations for logged in user's account */
    @AuraEnabled
    public static List<Authorisation__c> getAccountAuthorisations() {   
        
        List<Authorisation__c> listAuthorisations = new List<Authorisation__c>();
        
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();    
            
            Set<String> activeAuthStatuses = new Set<String>();
            activeAuthStatuses.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
            activeAuthStatuses.add(GlobalConstants.GRANTED_CONDITIONALLY);
            activeAuthStatuses.add(GlobalConstants.AUTHORISATION_SUSPENDED);
            
            listAuthorisations = [SELECT Id, Authorisation_Type__c, Name, End_Date__c
                                  FROM Authorisation__c
                                  WHERE Service_Provider__c  =:loggedInUser.AccountId 
                                  AND Status__c IN :activeAuthStatuses
                                  ORDER BY LastModifiedDate DESC];
            
            
            return listAuthorisations;
        } 
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyRegistrationTabController', 'getAccountAuthorisations', e.getMessage(), e);
            return NULL;
        }
    }
    
    /* This function retrives Tax Payer Registation details logged in User */
    @AuraEnabled
    public static Tax_Payer_Registration__c getTaxPayerRegistrationDetails(){
        
        try {
            
            List<Tax_Payer_Registration__c> tpr = new List<Tax_Payer_Registration__c>();
            
            User user = GlobalUtility.getLoggedInUser();
            
            if(!String.isBlank(user.AccountId)) {
                
                Account acc = [SELECT Id, Name
                               FROM Account
                               WHERE Id =: user.AccountId];
                
                Set<String> activeRegistrationSubStatuses = new Set<String>();
                activeRegistrationSubStatuses.add(GlobalConstants.SUB_STATUS_PENDING_P2P);
                activeRegistrationSubStatuses.add(GlobalConstants.SUB_STATUS_PENDING_RNSW);
                activeRegistrationSubStatuses.add(GlobalConstants.SUB_STATUS_COMPLETED);
                
                tpr = [SELECT Id, ABN__c, Annual_Trip_Estimate__c, Exemption_Reason__c, Bank_Account_Holder_s_Name__c, BSB__c, Rebate_Reason__c, Person_Enters_Returns_for_Levy__c,
                       Applied_For_Exemption__c, Applied_For_Rebate__c, Financial_Institution_Name__c, Levy_Contact__c, 
                       Levy_Contact__r.FirstName, Levy_Contact__r.LastName, Levy_Contact__r.Phone, Levy_Contact__r.Email,Levy_Contact__r.Levy_Contact_Phone__c,
                       Levy_Notification_Address_Country__c, Levy_Notification_Address_Street__c, Levy_Notification_Address_City__c, Levy_Notification_Address_State__c, Levy_Notification_Address_Postal_Code__c,
                       Bank_Account_Number__c, Bank_Name__c, Bank_Suburb__c, Registered_Business_Name__c, New_Levy_Contact_Added__c,
                       Levy_Contact_Email__c, Levy_Contact_Last_Name__c, Levy_Contact_Phone__c, Levy_Contact_First_Name__c, Direct_Debit_Declaration__c,
                       Service_Provider_Name__r.OwnerId, Estimated_BSP_Transactions__c, Estimated_TSP_Transactions__c, OwnerId, Date_Registered__c, Revenue_NSW_Status__c,
                       Assessment_Rate_Type__c, RNSWCustomerId__c
                       FROM Tax_Payer_Registration__c
                       WHERE Service_Provider_Name__c =: acc.Id 
                       AND (Status__c =: GlobalConstants.STATUS_ACTIVE
                             OR  Status__c =: GlobalConstants.STATUS_REJECTED)
                       AND Sub_Status__c IN :activeRegistrationSubStatuses 
                       ORDER BY Date_Registered__c DESC Limit 1];
                
                if(tpr.size() > 0 && tpr[0].Levy_Contact__c != NULL) {
                    
                    tpr[0].Levy_Contact_First_Name__c = tpr[0].Levy_Contact__r.FirstName;
                    tpr[0].Levy_Contact_Last_Name__c = tpr[0].Levy_Contact__r.LastName;
                    tpr[0].Levy_Contact_Email__c = tpr[0].Levy_Contact__r.Email;
                    tpr[0].Levy_Contact_Phone__c = tpr[0].Levy_Contact__r.Levy_Contact_Phone__c;
                    
                }
            }
            
            return tpr.size() > 0 ? tpr[0] : NULL;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','getTaxPayerRegistrationDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    /* This function retrives Contact details of logged in User */
    /*
     @AuraEnabled
     public static Contact getContactDetails(){

      try{

       User user = GlobalUtility.getLoggedInUser();

       Contact contact = [SELECT Id, Email, Name, Phone, Levy_Contact_Phone__c
                          FROM Contact 
                          WHERE AccountId = :user.AccountId];

       return contact;
      }
      catch(Exception ex) {

       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','getContactDetails',ex.getMessage(),ex);
       return null;
      }
     }
    */
    
    /* This function validates if there are any open cases against specified registration record */
    @AuraEnabled
    public static Boolean checkOpenCases(Tax_Payer_Registration__c registrationRecord){
        
        try{
            
            Boolean hasOpenCases = GlobalUtility.hasRelatedOpenCases(registrationRecord.Service_Provider_Name__c, registrationRecord.Id);
            return hasOpenCases;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','checkOpenCases',ex.getMessage(),ex);
            return FALSE;
        }
    }
    
    //function returns all contacts from logged in user's account
    @AuraEnabled
    public static List<Contact> getAccountContacts() {   
        
        List<Contact> listContacts = new List<Contact>();
        try {
            
            User loggedInUser = GlobalUtility.getLoggedInUser();    
            
            listContacts = [SELECT Id, Name, Email, Phone, MobilePhone, Levy_Contact_Phone__c
                            FROM Contact 
                            WHERE AccountId =:loggedInUser.AccountId 
                            AND Eligible_For_Levy_Contact_Selection__c = TRUE
                            ORDER BY LastModifiedDate DESC];
            
            return listContacts;
        } 
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyRegistrationTabController', 'getAccountContacts', e.getMessage(), e);
            return NULL;
        }
    }
    
    /* This funtion determines if registration record needs to superseded using a clone record and updates the existing record
     * with new details
     */
    @AuraEnabled
    public static Tax_Payer_Registration__c updateTaxPayerRegistrationContactDetails(Tax_Payer_Registration__c taxPayerRegistration) {   
        
        try {
            
            //validates if specified registration record is pending with OSR, if yes then update existing registration record
            //else clone the record and stamp newly specified contact details on to it
            if(GlobalUtility.checkIfWithOSR(taxPayerRegistration))  
                LevyRegistrationTabHelper.processTaxPayerRegistrationContactUpdate(taxPayerRegistration);
            else if(taxPayerRegistration.Status__c != GlobalConstants.STATUS_SUPERSEDED) {
                
                Tax_Payer_Registration__c clonedRegistrationRecord = GlobalUtility.cloneRegistrationRecord(taxPayerRegistration);
                clonedRegistrationRecord = clonedRegistrationRecord.clone(false, true, false, false);
                clonedRegistrationRecord.Levy_Notification_Address_Country__c = taxPayerRegistration.Levy_Notification_Address_Country__c;
                
                //marking clonned registration record as superseded
                clonedRegistrationRecord.Status__c = GlobalConstants.STATUS_SUPERSEDED;
                insert clonedRegistrationRecord;
                
                taxPayerRegistration.Status__c = GlobalConstants.STATUS_ACTIVE;
                
                /*   
                if(taxPayerRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE) 
                 taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
                else
                 taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
             
                //if service provider is exmepted from levy
                if(taxPayerRegistration.Exemption_Approved__c && taxPayerRegistration.Annual_Trip_Estimate__c == Label.Levy_Trip_Estimate_Less_Than_150_Value)
                    taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
                else if(taxPayerRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE 
                        || taxPayerRegistration.Applied_For_Rebate__c == GlobalConstants.YES_VALUE)
                    taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_P2P;
                else
                    taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_RNSW;
                
                if(String.isNotBlank(taxPayerRegistration.RNSWCustomerId__c))
                 taxPayerRegistration.IsAuthorisationUpdate__c = TRUE;
                */
                
                LevyRegistrationTabHelper.processTaxPayerRegistrationContactUpdate(taxPayerRegistration);   
            }  
            
            return taxPayerRegistration;     
        } 
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyRegistrationTabController', 'updateTaxPayerRegistrationContactDetails', e.getMessage(), e);  
            return NULL;         
        }
    }
    
    /* This funtion initialises the regisrtation record for updation before sending to the form */
    @AuraEnabled
    public static Tax_Payer_Registration__c processTaxPayerRegistrationDetailsUpdate(Tax_Payer_Registration__c taxPayerRegistration) {
        
        
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
        tempRegistration.RNSWCustomerId__c = taxPayerRegistration.RNSWCustomerId__c;
        // testing 251 jira
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
      return tempRegistration;
        
    }
}