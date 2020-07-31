/*
 * Helper class to create contact/account for corressponding related contacts
 * when authorisation record is granted 
 */
public with sharing class RelatedContactToAccountContactConversion {

    private Map<Id, Authorisation__c> newAuthorisations;
    private Map<Id, Authorisation__c> oldAuthorisations;
    
    public RelatedContactToAccountContactConversion(Map<Id, Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisations) {
    
        this.newAuthorisations = newAuthorisations;
        this.oldAuthorisations = oldAuthorisations;
    }
    
    /*
     * Method validating granted authorisations and creating/upadting   
     * corresposnding related contacts by performing de-duplication
     * within the same account.
     * Account de-dup criteria is based on ACN
     * Contact de-dup criteria is based on FirstName, LastName and BirthDate
     */
    public void validateContactAccountCreation() {
     
     try {
     
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.optAllorNone = FALSE;
      dmo.DuplicateRuleHeader.allowSave = true;
      dmo.DuplicateRuleHeader.runAsCurrentUser = false;
      
      Set<Id> targetAplicationAccounts = new Set<Id>();
      Set<Id> targetAplicationAccountsPartnerAccounts = new Set<Id>();
      
      Map<Id, Id> authIdVsApplicationId = new Map<Id, Id>();
      Map<Id, List<Related_Contact__c>> applicationIdVsRelatedContacts = new Map<Id, List<Related_Contact__c>>(); 
      
      Map<String, Related_Contact__c> identifierVsRelatedContact = new Map<String, Related_Contact__c>();
      
      //maps to store eixsting contacts and accounts
      Map<String, Contact> identifierVsContact = new Map<String, Contact>();
      Map<String, Account> identifierVsAccount = new Map<String, Account>(); 
        
      Map<String, String> corporateDirectorVsPartnerMap = new Map<String, String>(); 
      Map<String, String> identifierVsUpsertedAccountsMap = new Map<String, String>();  
        
      List<Contact> contactsToInsert = new List<Contact>();
      List<Contact> contactsToUpdate = new List<Contact>();
      
      List<Account> accountsToInsert = new List<Account>();
      List<Account> accountsToUpdate = new List<Account>();
        
      for(Authorisation__c tempAuth : newAuthorisations.values()) {
      
         //validate if authorisation is granted
         if(tempAuth.Status__c != oldAuthorisations.get(tempAuth.Id).Status__c
            && (((tempAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                  || tempAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY)
                  && tempAuth.Record_Type_Dev_Name__c != GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME)  
                  || (tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS
                       && tempAuth.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME))) {
            
              authIdVsApplicationId.put(tempAuth.Id, tempAuth.Application__c);     
         }
      }
      
      System.debug('In Basic Check');
      
      if(authIdVsApplicationId.size() > 0) {
      
      
       for(Related_Contact__c tempRelatedContact : [SELECT Related_Application__c, Related_Application__r.AccountId, ABN__c, ACN__c, 
                                                    Australian_Driver_Licence__c, Australian_Driver_Licence_State__c, Date_of_Birth__c, 
                                                    Business_Address_City__c, Business_Address_Country__c, Business_Address_Postal_Code__c,
                                                    Business_Address_State__c, Business_Address_Street__c, Business_International_Address__c, Contact_Type__c,
                                                    Corporation_Name__c, Daytime_Phone__c, Email__c, Family_Name__c, First_Given_Name__c,
                                                    Primary_Contact__c, Related_Contact__c, Residential_Address_City__c, Residential_Address_Country__c,
                                                    Residential_Address_Postcode__c, Residential_Address_State__c, Residential_Address_Street__c,
                                                    Residential_International_Address__c, Title__c, Role__c, Registered_Business_Name__c,
                                                    Have_been_known_by_other_names__c, Known_by_Other_Names_Details__c, Other_Given_Name__c,
                                                    Related_Corporate__c, Related_Corporate__r.ACN__c, Record_Type_Dev_Name__c,Website__c
                                                    FROM Related_Contact__c
                                                    WHERE Related_Application__c IN : authIdVsApplicationId.values()
                                                    AND Record_Type_Dev_Name__c != :GlobalConstants.RELATED_CONTACT_AGENT_AGREEMENT_RECORD_TYPE_DEV_NAME
                                                    AND Related_Application__r.AccountId != NULL]) {
                                                   
         
         targetAplicationAccounts.add(tempRelatedContact.Related_Application__r.AccountId);
         
         //if related contacts are linked to existing contact.
         if(!String.isBlank(tempRelatedContact.Related_Contact__c)){
            identifierVsRelatedContact.put(tempRelatedContact.Related_Contact__c, tempRelatedContact);
            continue;
         }
         
         //identify if related contact is either for individual or individual partnership         
         if(String.isBlank(tempRelatedContact.ACN__c)) {
          
           String identifier = getContactIdentifier(tempRelatedContact.Related_Application__r.AccountId, tempRelatedContact.First_Given_Name__c, tempRelatedContact.Family_Name__c, tempRelatedContact.Date_of_Birth__c);
           identifierVsRelatedContact.put(identifier, tempRelatedContact);
           
           if(tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
               && tempRelatedContact.Related_Corporate__r != NULL) {
           
             String coporatePartnerIdentifier = getAccountIdentifier(tempRelatedContact.Related_Application__r.AccountId, tempRelatedContact.Related_Corporate__r.ACN__c);
             corporateDirectorVsPartnerMap.put(identifier, coporatePartnerIdentifier);
           }
         }
         else {
           
           //related contact is either for company or company partnership
           String identifier = getAccountIdentifier(tempRelatedContact.Related_Application__r.AccountId, tempRelatedContact.ACN__c);
           identifierVsRelatedContact.put(identifier, tempRelatedContact);
          
           
         }
      }
      //date : 14/10/2019
     for(Account tempPartnerAccount : [SELECT Id,Name, ACN__c, Corporate_Partner__c
                                        FROM Account 
                                        WHERE Id IN :targetAplicationAccounts]) {
           
           String identifier = getAccountIdentifier(tempPartnerAccount.Id, tempPartnerAccount.ACN__c); 
           identifierVsAccount.put(identifier, tempPartnerAccount);
           
          
      }
      //date : 14/10/2019 end
          
          
      //find all existing partner accounts under target accounts
      for(Account tempPartnerAccount : [SELECT Name, ACN__c, Corporate_Partner__c
                                        FROM Account 
                                        WHERE Corporate_Partner__c IN :targetAplicationAccounts]) {
           
           String identifier = getAccountIdentifier(tempPartnerAccount.Corporate_Partner__c, tempPartnerAccount.ACN__c); 
           identifierVsAccount.put(identifier, tempPartnerAccount);
           
           targetAplicationAccountsPartnerAccounts.add(tempPartnerAccount.Id);
      }
      
      
      //find all existing contacts under target accounts
      for(Contact con : [SELECT AccountId, FirstName, LastName, BirthDate 
                         FROM Contact 
                         WHERE AccountId IN :targetAplicationAccounts]) {
                
           String identifier = getContactIdentifier(con.AccountId, con.FirstName, con.LastName, con.BirthDate); 
           identifierVsContact.put(identifier, con);
           identifierVsContact.put(con.Id, con);
      }
      
      //find all existing contacts under target partner accounts
      for(Contact con : [SELECT AccountId, FirstName, LastName, BirthDate, Account.Corporate_Partner__c
                         FROM Contact 
                         WHERE AccountId IN :targetAplicationAccountsPartnerAccounts]) {
                
           String identifier = getContactIdentifier(con.Account.Corporate_Partner__c, con.FirstName, con.LastName, con.BirthDate); 
           identifierVsContact.put(identifier, con);
           identifierVsContact.put(con.Id, con);
      }
      
      //validate if related accounts already exists for target set of related contacts
      for(String relatedContactIdentifier : identifierVsRelatedContact.Keyset()) {
      
         Related_Contact__c tempRelatedContact = identifierVsRelatedContact.get(relatedContactIdentifier);
         
         //if related contact is of corporate partnership type and is not a duplicate one
         if(tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_CORPORATE_PARTNERSHIP_TYPE) {
          system.debug('corporate account');   
               Account tempCorporateAccount;
               
               if(!identifierVsAccount.containsKey(relatedContactIdentifier)) {
              
                //create a new corporate partnership account
                tempCorporateAccount = new Account();
               }
               else {
                
                tempCorporateAccount = identifierVsAccount.get(relatedContactIdentifier);
               }
               
               tempCorporateAccount.setOptions(dmo);
               tempCorporateAccount.Name = tempRelatedContact.Corporation_Name__c;
             //Email
               if(String.isNotBlank(tempRelatedContact.Email__c))
                tempCorporateAccount.Email__c = tempRelatedContact.Email__c;
             
             //Website__c
              if(String.isNotBlank(tempRelatedContact.Website__c))
                tempCorporateAccount.Website = tempRelatedContact.Website__c;
           
               if(String.isNotBlank(tempRelatedContact.ABN__c))
                tempCorporateAccount.ABN__c = tempRelatedContact.ABN__c;
               
               if(String.isNotBlank(tempRelatedContact.ACN__c))
                tempCorporateAccount.ACN__c = tempRelatedContact.ACN__c;
               
               if(String.isNotBlank(tempRelatedContact.Daytime_Phone__c))
                tempCorporateAccount.Phone = tempRelatedContact.Daytime_Phone__c;
               
               if(String.isNotBlank(tempRelatedContact.Registered_Business_Name__c))
                tempCorporateAccount.Registered_Business_Name__c = tempRelatedContact.Registered_Business_Name__c;
               
               if(String.isBlank(tempRelatedContact.Business_International_Address__c)) {
                
                 tempCorporateAccount.BillingCity = tempRelatedContact.Business_Address_City__c;
                 tempCorporateAccount.BillingCountry = tempRelatedContact.Business_Address_Country__c;
                 tempCorporateAccount.BillingPostalCode = tempRelatedContact.Business_Address_Postal_Code__c;
                 tempCorporateAccount.BillingState = tempRelatedContact.Business_Address_State__c;
                 tempCorporateAccount.BillingStreet = tempRelatedContact.Business_Address_Street__c;
               }
               else
                 tempCorporateAccount.BillingStreet = tempRelatedContact.Business_International_Address__c;
                 
               tempCorporateAccount.Corporate_Partner__c = tempRelatedContact.Related_Application__r.AccountId;
               tempCorporateAccount.Associated_Related_Contact__c = tempRelatedContact.Id;
              system.debug(tempCorporateAccount.Associated_Related_Contact__c);
               if(!String.isBlank(tempCorporateAccount.Id))
                accountsToUpdate.add(tempCorporateAccount); 
               else 
                accountsToInsert.add(tempCorporateAccount); 
         }
         
      }
      
      System.debug('Account Insert Result: '+accountsToInsert);
      System.debug('Account Update Result: '+accountsToUpdate);
          
        List<Account> accountsToInsertAndUpsert = new List<Account>();
      accountsToInsertAndUpsert.addAll(accountsToInsert);
      accountsToInsertAndUpsert.addAll(accountsToUpdate);
      
      System.debug('Account Insert and Update Result: '+accountsToInsertAndUpsert);
          
      
      upsert accountsToInsertAndUpsert;
      
     // Database.SaveResult[] srListInsertAccounts = Database.insert(accountsToInsert, dmo);
      //Database.SaveResult[] srListUpdateAccounts = Database.update(accountsToUpdate, dmo);
      
      //populating map of identifier vs inserted account
      for(Account tempAcc : accountsToInsert) {
        
        System.debug('Inserted Account: '+tempAcc.Id);
        
        String insertedAccountIdentifier = getAccountIdentifier(tempAcc.Corporate_Partner__c, tempAcc.ACN__c); 
        identifierVsUpsertedAccountsMap.put(insertedAccountIdentifier, tempAcc.Id);
      }
      
      //populating map of identifier vs updated account
      for(Account tempAcc : accountsToUpdate) {
        
        String updatedAccountIdentifier = getAccountIdentifier(tempAcc.Corporate_Partner__c, tempAcc.ACN__c); 
        identifierVsUpsertedAccountsMap.put(updatedAccountIdentifier, tempAcc.Id);
      }
      
      
      System.debug('Upserted Account Map: '+identifierVsUpsertedAccountsMap);
      System.debug('Diretor vs Partner Map: '+corporateDirectorVsPartnerMap);
      
      //validate if related contacts already exists for target set of related contacts
      for(String relatedContactIdentifier : identifierVsRelatedContact.Keyset()) {
      
         Related_Contact__c tempRelatedContact = identifierVsRelatedContact.get(relatedContactIdentifier);
         
         //if related contact is of individual partnership type and is not a duplicate one
         if(tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE
             || tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
             || (tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_GENERAL_CONTACT
                  && String.isBlank(tempRelatedContact.ACN__c))) {
              system.debug('Entry criteria 1');
              Contact tempContact;
              
              if(!identifierVsContact.containsKey(relatedContactIdentifier)) {
              
                //create a new individual partner contact
                tempContact = new Contact();
              }
              else {
              
                tempContact = identifierVsContact.get(relatedContactIdentifier); 
              }
              
              tempContact.setOptions(dmo);
              
              //if not a director of corporate partner
              if(String.isBlank(tempRelatedContact.Related_Corporate__c))
                tempContact.AccountId = tempRelatedContact.Related_Application__r.AccountId;
              else {
                tempContact.AccountId = identifierVsUpsertedAccountsMap.get(corporateDirectorVsPartnerMap.get(relatedContactIdentifier));
              }
              
              tempContact.Salutation = tempRelatedContact.Title__c;
              tempContact.BirthDate = tempRelatedContact.Date_of_Birth__c;
              tempContact.FirstName = tempRelatedContact.First_Given_Name__c;
              tempContact.LastName = tempRelatedContact.Family_Name__c;
              tempContact.Australian_Driver_Licence_Number__c = tempRelatedContact.Australian_Driver_Licence__c;
              tempContact.State__c = tempRelatedContact.Australian_Driver_Licence_State__c;
              tempContact.Phone = tempRelatedContact.Daytime_Phone__c;
              tempContact.Associated_Related_Contact__c = tempRelatedContact.Id;
              
              if(String.isNotBlank(tempRelatedContact.Email__c))
               tempContact.Email = tempRelatedContact.Email__c;
              
              tempContact.Contact_Type__c = tempRelatedContact.Contact_Type__c;
              tempContact.Other_Given_Name__c = tempRelatedContact.Other_Given_Name__c;
              
              //tempContact.Primary_Contact__c = tempRelatedContact.Primary_Contact__c;
              
              if(tempRelatedContact.Have_been_known_by_other_names__c)
               tempContact.Ever_been_known_by_another_name__c = 'Yes';
              else
               tempContact.Ever_been_known_by_another_name__c = 'No';
               
              tempContact.Other_Name_Details__c = tempRelatedContact.Known_by_Other_Names_Details__c;
              
              if(String.isBlank(tempRelatedContact.Residential_International_Address__c)) {
                
                 tempContact.MailingCity = tempRelatedContact.Residential_Address_City__c;
                 tempContact.MailingCountry = tempRelatedContact.Residential_Address_Country__c;
                 tempContact.MailingPostalCode = tempRelatedContact.Residential_Address_Postcode__c;
                 tempContact.MailingState = tempRelatedContact.Residential_Address_State__c;
                 tempContact.MailingStreet = tempRelatedContact.Residential_Address_Street__c;
              }
              else 
                 tempContact.MailingStreet = tempRelatedContact.Residential_International_Address__c;
              
              if(!String.isBlank(tempContact.Id))
               contactsToUpdate.add(tempContact); 
              else
               contactsToInsert.add(tempContact); 
         }
          
          else if(tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE
             || tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE
             || (tempRelatedContact.Contact_Type__c == GlobalConstants.CONTACT_GENERAL_CONTACT
                  && !String.isBlank(tempRelatedContact.ACN__c))) { 
          system.debug('Entry criteria 2');
             system.debug('Account Update');
               Account tempAccount;
              if(identifierVsAccount.containsKey(relatedContactIdentifier)) {
                tempAccount = identifierVsAccount.get(relatedContactIdentifier);
               }
               
               tempAccount.setOptions(dmo);         
                      
                      
             //Account tempAccount = [SELECT Id,Name, ACN__c FROM Account WHERE Id IN :targetAplicationAccounts limit 1]; 
             //Account tempAccount2 = new Account(Id= tempAccount.Id);
            tempAccount.Associated_Related_Contact__c=tempRelatedContact.Id;
                      //Email__c
             if(String.isNotBlank(tempRelatedContact.Email__c))
                tempAccount.Email__c = tempRelatedContact.Email__c;
             
             //Website__c
              if(String.isNotBlank(tempRelatedContact.Website__c))
                tempAccount.Website = tempRelatedContact.Website__c;
           accountsToUpdate.add(tempAccount); 
                
         }
      }
      
      IF(accountsToUpdate.Size() > 0)
          update accountsToUpdate;
          
      System.debug('Contact Insert Result: '+contactsToInsert);
      System.debug('Contact Update Result: '+contactsToUpdate);
      
      List<Contact> contactsToInsertAndUpsert = new List<Contact>();
      contactsToInsertAndUpsert.addAll(contactsToInsert);
      contactsToInsertAndUpsert.addAll(contactsToUpdate);
      
      System.debug('Contact Insert and Update Result: '+contactsToInsertAndUpsert);
          
      //Database.SaveResult[] srListInsertContacts = Database.insert(contactsToInsert, dmo);
      //Database.SaveResult[] srListUpdateContacts = Database.update(contactsToUpdate, dmo);
      upsert contactsToInsertAndUpsert;
          
      AuthorisationContactCreator authContactCreator = new AuthorisationContactCreator(contactsToInsertAndUpsert,  newAuthorisations.values());
      authContactCreator.create();  

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Associated_Related_Contact__c 
                                                            FROM Contact
                                                            WHERE Id IN :contactsToInsertAndUpsert]);
        system.debug(contactMap);
        AttachmentMover attachMover = new AttachmentMover();
        attachMover.moveAttachmentsFromRelatedContactToContact(contactMap);
          
        Map<Id,Account> accountMap = new Map<Id, Account>([SELECT Id, Associated_Related_Contact__c 
                                                            FROM Account
                                                            WHERE Id IN :targetAplicationAccounts]);
        system.debug(accountMap);
        AttachmentMovertoAccount attachMoveracc = new AttachmentMovertoAccount();
        attachMoveracc.moveAttachmentsFromRelatedContactToAccount(accountMap);
          
       if(accountsToInsertAndUpsert.Size() > 0 )
       {
        map<Id,Account> corporateaccountMap = new map<Id,Account>(accountsToInsertAndUpsert);
        AttachmentMovertoAccount attachMovercorporateacc = new AttachmentMovertoAccount();
        attachMovercorporateacc.moveAttachmentsFromRelatedContactToAccount(corporateaccountMap);  
       }
     }
      
    }
    catch(Exception e) {
      
      System.debug('Exception: '+e);
      System.debug('Exception Line: '+e.getLineNumber());
      ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RelatedContactToAccountContactConversion', 'validateContactAccountCreation', e.getMessage(), e);
    }
    }
    
    /* Method to create de-dup key for Contact matching */
    private static String getContactIdentifier(Id accountId, String fName, String lName, Date dob) {
        
        return (accountId + fName + lName + (dob != null ? dob.format() : '')).toLowerCase();
    }
    
    /* Method to create de-dup key for Account matching */
    private static String getAccountIdentifier(Id accountId, String acn) {
        
        if((!String.isBlank(acn)) && acn.contains(' '))
          acn = acn.replaceAll(' ', '');
          
        return (accountId + acn).toLowerCase();
    }
}