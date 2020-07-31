/**
* 
*/ 
public with sharing class P2POSRFacade {
    public P2POSRPostalAddress p2pOSRPostalAddress { get; private set; } { this.p2pOSRPostalAddress = null; }
    public P2POSRStreetAddress p2pOSRStreetAddress { get; private set; } { this.p2pOSRStreetAddress = null; }
    public P2POSRCompanyClient p2pOSRCompanyClient { get; private set; } { this.p2pOSRCompanyClient = null; }
    public P2POSRIndividualClient p2pOSRIndividualClient { get; private set; } { this.p2pOSRIndividualClient = null; }
    public P2POSRClientDetails p2pOSRClientDetails { get; private set; } { this.p2pOSRClientDetails = null; }
    public P2POSRProviderDetail p2POSRProviderDetail { get; private set; } { this.p2POSRProviderDetail = null; }
    public P2POSRAuthorisations p2pOSRAuthorisations {get; private set; } { this.p2pOSRAuthorisations = null; }
    public P2POSRAuthorisation p2pOSRAuthorisation {get; private set; } { this.p2pOSRAuthorisation = null; }
    
    private String query() {
    String soquery = 'SELECT Id,Taxi_Service_Provider_Number__r.FirstIssueDateCheck__c,Booking_Service_Provider_Number__r.FirstIssueDateCheck__c,Taxi_Service_Provider_Number__c, Taxi_Service_Provider_Number__r.Prior_Status__c, Booking_Service_Provider_Number__c, Service_Provider_Name__c,' +
                     'IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c, IsProviderUpdate__c, IsAuthorisationUpdate__c,' +
                     'Levy_Notification_Address_Street__c, Levy_Notification_Address_City__c ,Levy_Notification_Address_Postal_Code__c, Levy_Notification_Address_State__c, BSB__c, Bank_Account_Number__c,' +
                     'Bank_Account_Holder_s_Name__c, Levy_Contact_First_Name__c, Levy_Contact_Last_Name__c,Levy_Contact_Phone__c, Levy_Contact_Email__c, Taxi_Service_Provider_Number__r.Start_Date__c, ' + 
                     'Booking_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.Status__c, Booking_Service_Provider_Number__r.Status__c,Booking_Service_Provider_Number__r.Prior_Status__c, Service_Provider_Name__r.Customer_Number__c,' + 
                     'Service_Provider_Name__r.RecordType.Name, Service_Provider_Name__r.ABN__c,Service_Provider_Name__r.Name,Service_Provider_Name__r.Registered_Business_Name__c, Service_Provider_Name__r.ShippingStreet,' + 
                     'Service_Provider_Name__r.ShippingPostalCode, Service_Provider_Name__r.ShippingState, Service_Provider_Name__r.ShippingCity,' +
                     'Taxi_Service_Provider_Number__r.Decision_Date__c, Booking_Service_Provider_Number__r.Decision_Date__c' +
                     ' FROM Tax_Payer_Registration__c WHERE Status__c = \'' + GlobalConstants.STATUS_ACTIVE + 
                     '\' AND Revenue_NSW_Status__c =\'' + GlobalConstants.REVENUE_NSW_STATUS_PENDING+'\'';  
     return soquery;
    }
    
    public List<P2POSRRequestParameter> createProviderAuthorisationRequestParameters() {
        
        P2POSRRequestParameter p2pOSRRequestParameter; 
        List<P2POSRRequestParameter> p2pOSRRequestParameters = new List<P2POSRRequestParameter>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Contact> accountIdVsPrimaryContact = new Map<Id,Contact>();        
        String soquery = this.query() + ' AND IsProviderUpdate__c = false AND IsAuthorisationUpdate__c  = false AND IsTSPAuthorisationCreate__c = false AND IsBSPAuthorisationCreate__c = false';
        system.debug('Query ' + soquery);
        List<Tax_Payer_Registration__c> taxPayers = database.query(soquery);
       
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            accountIds.add(taxPayer.Service_Provider_Name__c);   
        }
        
        /* Storing Account which has primary contact */
        for(Contact primaryContact : [SELECT Id,LastName, FirstName, Birthdate, AccountId FROM Contact WHERE Primary_Contact__c = true AND AccountId IN :accountIds ]) {
            accountIdVsPrimaryContact.put(primaryContact.AccountId, primaryContact);
            
        }
        
        
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            p2POSRProviderDetail = new P2POSRProviderDetail();
            p2pOSRAuthorisations = new P2POSRAuthorisations(null, null);
            p2pOSRClientDetails = new P2POSRClientDetails(null, null);
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            
            p2pOSRRequestParameter.referenceId =  taxPayer.Id;
            
            p2POSRProviderDetail.providerType = (true == taxPayer.Service_Provider_Name__r.RecordType.Name.equalsIgnoreCase(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)) ? 'I' : 'C';
            p2POSRProviderDetail.TfNSWProviderNumber = taxPayer.Service_Provider_Name__r.Customer_Number__c;
            p2POSRProviderDetail.abn = null;
            p2POSRProviderDetail.email = null;
            p2POSRProviderDetail.tradingName = null;
            
            if(p2POSRProviderDetail.providerType == 'C') {
                p2POSRProviderDetail.abn = taxPayer.Service_Provider_Name__r.ABN__c;
                p2pOSRClientDetails.company = new P2POSRCompanyClient(taxPayer.Service_Provider_Name__r.Registered_Business_Name__c , null, null, null);
            } else if(p2POSRProviderDetail.providerType == 'I') {
                if(accountIdVsPrimaryContact.containsKey(taxPayer.Service_Provider_Name__c) ) {
                    Contact contact = accountIdVsPrimaryContact.get(taxPayer.Service_Provider_Name__c);
                    p2pOSRClientDetails.individual = new P2POSRIndividualClient(contact.FirstName, contact.LastName, String.valueOf(contact.birthDate), null, null, null);
                }
            }
            
            p2POSRProviderDetail.clientDetails = p2pOSRClientDetails;
            
            
            p2POSRProviderDetail.providerPostalAddress = new P2POSRPostalAddress (taxPayer.Levy_Notification_Address_Street__c,null,
                                                                                  taxPayer.Levy_Notification_Address_City__c,
                                                                                  taxPayer.Levy_Notification_Address_Postal_Code__c, 
                                                                                  taxPayer.Levy_Notification_Address_State__c);
            
            
            p2pOSRPostalAddress = new P2POSRPostalAddress(taxPayer.Levy_Notification_Address_Street__c, null,
                                                          taxPayer.Levy_Notification_Address_City__c,
                                                          taxPayer.Levy_Notification_Address_Postal_Code__c,
                                                          taxPayer.Levy_Notification_Address_State__c);
            
            if(taxPayer.Taxi_Service_Provider_Number__c != null) {            
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.tspAuthorisation = new P2POSRAuthorisation('TT', String.valueOf(taxPayer.Taxi_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            
            if(taxPayer.Booking_Service_Provider_Number__c != null) {
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.bspAuthorisation = new P2POSRAuthorisation('TB', String.valueOf(taxPayer.Booking_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            p2pOSRRequestParameter.providerDetail=p2POSRProviderDetail;
            p2pOSRRequestParameter.providerAuthorisations = p2pOSRAuthorisations;
            p2pOSRRequestParameters.add(p2pOSRRequestParameter);
        }
        return p2pOSRRequestParameters;
    }
    
    public List<P2POSRRequestParameter> updateProviderRequestParameters() {
        P2POSRRequestParameter p2pOSRRequestParameter; 
        List<P2POSRRequestParameter> p2pOSRRequestParameters = new List<P2POSRRequestParameter>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Contact> accountIdVsPrimaryContact = new Map<Id,Contact>();
        
        String soquery = this.query() + ' AND IsProviderUpdate__c = true AND RNSWCustomerId__c != null';
        List<Tax_Payer_Registration__c> taxPayers = database.query(soquery);
        
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            accountIds.add(taxPayer.Service_Provider_Name__c);   
        }
        
        /* Storing Account which has primary contact */
        for(Contact primaryContact : [SELECT Id,LastName, FirstName, Birthdate, AccountId FROM Contact WHERE Primary_Contact__c = true AND AccountId IN :accountIds ]) {
            accountIdVsPrimaryContact.put(primaryContact.AccountId, primaryContact);
        }
        
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            p2POSRProviderDetail = new P2POSRProviderDetail();
            p2pOSRClientDetails = new P2POSRClientDetails(null, null);
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            
            p2pOSRRequestParameter.referenceId =  taxPayer.Id;
            
            p2POSRProviderDetail.providerType = (true == taxPayer.Service_Provider_Name__r.RecordType.Name.equalsIgnoreCase(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL)) ? 'I' : 'C';
            p2POSRProviderDetail.TfNSWProviderNumber = taxPayer.Service_Provider_Name__r.Customer_Number__c;
            p2POSRProviderDetail.abn = null;
            p2POSRProviderDetail.email = null;
            p2POSRProviderDetail.tradingName = null;
            
            if(p2POSRProviderDetail.providerType == 'C')
            {
                p2pOSRClientDetails.company = new P2POSRCompanyClient(taxPayer.Service_Provider_Name__r.Registered_Business_Name__c, null, null, null);
                p2POSRProviderDetail.abn = taxPayer.Service_Provider_Name__r.ABN__c;
            }
            else if(p2POSRProviderDetail.providerType == 'I'){
                if(accountIdVsPrimaryContact.containsKey(taxPayer.Service_Provider_Name__c) ) {
                    Contact contact = accountIdVsPrimaryContact.get(taxPayer.Service_Provider_Name__c);
                    p2pOSRClientDetails.individual = new P2POSRIndividualClient(contact.FirstName, contact.LastName, String.valueOf(contact.birthDate), null, null, null);
                }
            }
            
            p2POSRProviderDetail.clientDetails = p2pOSRClientDetails;
            
            
           p2POSRProviderDetail.providerPostalAddress = new P2POSRPostalAddress (taxPayer.Levy_Notification_Address_Street__c,null,
                                                                                  taxPayer.Levy_Notification_Address_City__c,
                                                                                  taxPayer.Levy_Notification_Address_Postal_Code__c, 
                                                                                  taxPayer.Levy_Notification_Address_State__c); 
            p2pOSRRequestParameter.providerDetail=p2POSRProviderDetail;
            p2pOSRRequestParameters.add(p2pOSRRequestParameter);
        }
        return p2pOSRRequestParameters;
    }
    
    public List<P2POSRRequestParameter> createAuthorisationRequestParameters() {
        P2POSRRequestParameter p2pOSRRequestParameter; 
        List<P2POSRRequestParameter> p2pOSRRequestParameters = new List<P2POSRRequestParameter>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Contact> accountIdVsPrimaryContact = new Map<Id,Contact>();
        
        String soquery = this.query() + ' AND (IsTSPAuthorisationCreate__c = true OR IsBSPAuthorisationCreate__c = true) AND RNSWCustomerId__c != null';
        
        List<Tax_Payer_Registration__c> taxPayers = database.query(soquery);
        
        
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            p2pOSRAuthorisations = new P2POSRAuthorisations(null, null);
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            system.debug('Ids '+ taxPayer.Id);
            
            p2pOSRRequestParameter.referenceId =  taxPayer.Id;
            
            p2pOSRPostalAddress = new P2POSRPostalAddress(taxPayer.Levy_Notification_Address_Street__c, null,
                                                          taxPayer.Levy_Notification_Address_City__c,
                                                          taxPayer.Levy_Notification_Address_Postal_Code__c,
                                                          taxPayer.Levy_Notification_Address_State__c);
            
            if(taxPayer.Taxi_Service_Provider_Number__c != null && taxPayer.IsTSPAuthorisationCreate__c == True ) {
                
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.tspAuthorisation = new P2POSRAuthorisation('TT', String.valueOf(taxPayer.Taxi_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            
            if(taxPayer.Booking_Service_Provider_Number__c != null && taxPayer.IsBSPAuthorisationCreate__c == True) {
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.bspAuthorisation = new P2POSRAuthorisation('TB', String.valueOf(taxPayer.Booking_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            p2pOSRRequestParameter.providerAuthorisations = p2pOSRAuthorisations;
            p2pOSRRequestParameter.tfNSWProviderNumber = taxPayer.Service_Provider_Name__r.Customer_Number__c;
            p2pOSRRequestParameters.add(p2pOSRRequestParameter);
        }
        
        return p2pOSRRequestParameters;
    }
    
    public List<P2POSRRequestParameter> updateAuthorisationRequestParameters() {
        
        P2POSRRequestParameter p2pOSRRequestParameter; 
        List<P2POSRRequestParameter> p2pOSRRequestParameters = new List<P2POSRRequestParameter>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Contact> accountIdVsPrimaryContact = new Map<Id,Contact>();
        
      String soquery = this.query() + ' AND IsAuthorisationUpdate__c = true AND RNSWCustomerId__c != null AND ((Taxi_Service_Provider_Number__c != null AND Taxi_Service_Provider_Number__r.Status__c != \''+GlobalConstants.AUTHORISATION_STATUS_CANCELLED +
                                                                               '\') OR (Booking_Service_Provider_Number__c != null AND Booking_Service_Provider_Number__r.Status__c != \'' +GlobalConstants.AUTHORISATION_STATUS_CANCELLED +'\'))';
       
         
        
        List<Tax_Payer_Registration__c> taxPayers = database.query(soquery);
        
        system.debug('My Query' + soquery);
        
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            p2pOSRAuthorisations = new P2POSRAuthorisations(null, null);
            
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            p2pOSRRequestParameter.referenceId =  taxPayer.Id;
            
            p2pOSRPostalAddress = new P2POSRPostalAddress(taxPayer.Levy_Notification_Address_Street__c, null,
                                                          taxPayer.Levy_Notification_Address_City__c,
                                                          taxPayer.Levy_Notification_Address_Postal_Code__c,
                                                          taxPayer.Levy_Notification_Address_State__c);
            
            if(taxPayer.Taxi_Service_Provider_Number__c != null  && taxPayer.IsTSPAuthorisationCreate__c == false && taxPayer.Taxi_Service_Provider_Number__r.Status__c != GlobalConstants.AUTHORISATION_STATUS_CANCELLED) {
                
                system.debug('start date null Payload');
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.tspAuthorisation = new P2POSRAuthorisation('TT', null,
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            
            if(taxPayer.Booking_Service_Provider_Number__c != null && taxPayer.IsBSPAuthorisationCreate__c == false  && taxPayer.Booking_Service_Provider_Number__r.Status__c !=  GlobalConstants.AUTHORISATION_STATUS_CANCELLED ) {
                
                 system.debug('start date null Payload');
                String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.bspAuthorisation = new P2POSRAuthorisation('TB', null,
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
       
            //Srikanth: JIRA 284 change - checking prior status and also first issue date to know auth is New to be send to Revenue.
                   if(taxPayer.Taxi_Service_Provider_Number__c != null && taxPayer.IsAuthorisationUpdate__c == true  && taxPayer.IsTSPAuthorisationCreate__c == false
                      && (taxPayer.Taxi_Service_Provider_Number__r.Prior_Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED || taxPayer.Taxi_Service_Provider_Number__r.Prior_Status__c =='Decision Pending' && (taxPayer.Taxi_Service_Provider_Number__r.FirstIssueDateCheck__c == true)) && taxPayer.Taxi_Service_Provider_Number__r.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY) {
                
                          system.debug('Reactivation Payload');
                          
                          String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.tspAuthorisation = new P2POSRAuthorisation('TT', String.valueOf(taxPayer.Taxi_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            
            if(taxPayer.Booking_Service_Provider_Number__c != null &&  taxPayer.IsAuthorisationUpdate__c == true  && taxPayer.IsBSPAuthorisationCreate__c == false  
               && (taxPayer.Booking_Service_Provider_Number__r.Prior_Status__c ==  GlobalConstants.AUTHORISATION_STATUS_CANCELLED || taxPayer.Booking_Service_Provider_Number__r.Prior_Status__c =='Decision Pending' && (taxPayer.Booking_Service_Provider_Number__r.FirstIssueDateCheck__c == true)) && taxPayer.Booking_Service_Provider_Number__r.Status__c ==  GlobalConstants.GRANTED_UNCONDITIONALLY) {
                
                    system.debug('Reactivation Payload');
                   
                   String contactName = validateAndGenerateContactName(taxPayer.Levy_Contact_First_Name__c, taxPayer.Levy_Contact_Last_Name__c);
                p2pOSRAuthorisations.bspAuthorisation = new P2POSRAuthorisation('TB',String.valueOf(taxPayer.Booking_Service_Provider_Number__r.Start_Date__c),
                                                                                taxPayer.BSB__c, taxPayer.Bank_Account_Number__c,
                                                                                taxPayer.Bank_Account_Holder_s_Name__c, contactName,
                                                                                taxPayer.Levy_Contact_Phone__c, taxPayer.Levy_Contact_Email__c, p2pOSRPostalAddress,null);
            }
            
       
            
            
            
            p2pOSRRequestParameter.providerAuthorisations = p2pOSRAuthorisations;
            p2pOSRRequestParameter.tfNSWProviderNumber = taxPayer.Service_Provider_Name__r.Customer_Number__c;
            p2pOSRRequestParameters.add(p2pOSRRequestParameter);
        }
        
        return p2pOSRRequestParameters;
    }
    
    public List<P2POSRRequestParameter> cancelAuthorisationRequestParameters() {
        P2POSRRequestParameter p2pOSRRequestParameter; 
        List<P2POSRRequestParameter> p2pOSRRequestParameters = new List<P2POSRRequestParameter>();
       
        String soquery = this.query() + ' AND RNSWCustomerId__c != null AND IsAuthorisationCancel__c = true AND ((Taxi_Service_Provider_Number__c != null AND Taxi_Service_Provider_Number__r.Status__c = \''+GlobalConstants.AUTHORISATION_STATUS_CANCELLED +
                                                                                   '\') OR (Booking_Service_Provider_Number__c != null AND Booking_Service_Provider_Number__r.Status__c = \'' +GlobalConstants.AUTHORISATION_STATUS_CANCELLED +'\'))';
        system.debug('My Query' + soquery);
        List<Tax_Payer_Registration__c> taxPayers = database.query(soquery);
         
        for(Tax_Payer_Registration__c taxPayer : taxPayers) {
            p2pOSRAuthorisations = new P2POSRAuthorisations(null, null);
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            
            p2pOSRRequestParameter.referenceId =  taxPayer.Id;
            
            p2pOSRPostalAddress = new P2POSRPostalAddress(taxPayer.Levy_Notification_Address_Street__c, null,
                                                          taxPayer.Levy_Notification_Address_City__c,
                                                          taxPayer.Levy_Notification_Address_Postal_Code__c,
                                                          taxPayer.Levy_Notification_Address_State__c);
            
            system.debug('Status>>' +taxPayer.Taxi_Service_Provider_Number__r.Status__c+'<<');            
            
            if(taxPayer.Taxi_Service_Provider_Number__c != null && taxPayer.IsTSPAuthorisationCreate__c == false  && taxPayer.Taxi_Service_Provider_Number__r.Status__c ==  GlobalConstants.AUTHORISATION_STATUS_CANCELLED) {
                p2pOSRAuthorisations.tspAuthorisation = new P2POSRAuthorisation();
                p2pOSRAuthorisations.tspAuthorisation.type = 'TT';
                p2pOSRAuthorisations.tspAuthorisation.effectiveDate = String.valueOf(taxPayer.Taxi_Service_Provider_Number__r.Decision_Date__c);
            }
            
            if(taxPayer.Booking_Service_Provider_Number__c != null  && taxPayer.IsBSPAuthorisationCreate__c == false  && taxPayer.Booking_Service_Provider_Number__r.Status__c ==  GlobalConstants.AUTHORISATION_STATUS_CANCELLED) {
                p2pOSRAuthorisations.bspAuthorisation = new P2POSRAuthorisation();
                p2pOSRAuthorisations.bspAuthorisation.type = 'TB';
                p2pOSRAuthorisations.bspAuthorisation.effectiveDate = String.valueOf(taxPayer.Booking_Service_Provider_Number__r.Decision_Date__c);
                
            }
            p2pOSRRequestParameter.providerAuthorisations = p2pOSRAuthorisations;
            p2pOSRRequestParameter.tfNSWProviderNumber = taxPayer.Service_Provider_Name__r.Customer_Number__c;
            p2pOSRRequestParameters.add(p2pOSRRequestParameter);
            
        }
        return p2pOSRRequestParameters;
    }
    
    /*
     * Method to validate and return concatenation of levy contact's first name and last name
     * if less than 50 else concatenate only 1st initial of first name and last name and then return 
     */
    public String validateAndGenerateContactName(String firstName, String lastName) {
    
       String concatenation = firstName+' '+lastName;
       return concatenation.length() > 50 && String.isNotBlank(firstName) ? firstName.substring(0, 1)+' '+lastName : firstName+' '+lastName;
       
    }
}