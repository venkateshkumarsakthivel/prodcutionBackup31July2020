public with sharing class ASPManageAccountContacts {
    
    public class BaseException extends Exception {}
    
    //Function to retrive loggedin user account details
    @AuraEnabled
    public static User getLoggedInUserAccount() {
       
        User UserRec;
        try {
            UserRec = GlobalUtility.getLoggedInUser();
            return UserRec;  
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','getLoggedInUserAccount',ex.getMessage(),ex);
            return null;            
        }
    }
    
    //Function to retrive active contacts related to perticular account.
    @AuraEnabled
    public static List<Contact> getContacts() {
        
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            
            Map<Id,Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Account.Name, Contact_Type__c, Primary_Contact__c,
                        FirstName, LastName, LastModifiedDate, Deactivated__c, MailingState,Is_Access_Level_Levy_Administrator__c, 
                        Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c, Of_Interest__c
                        FROM Contact 
                        WHERE AccountId =:user.AccountId 
                        and Deactivated__c = false 
                        and Contact_Type__c != :GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE 
                        ORDER BY LastModifiedDate DESC]);
            
            //reset the of intereset flag to false
            for(Id conId : contactsMap.keySet()){
                contactsMap.get(conId).Of_Interest__c = false;
            }
            Id spaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                    GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            List<Case> openCases = [SELECT Id, 
                                        (SELECT Id, Related_Contact__c FROM Related_Contacts__r WHERE Related_Contact__c IN :contactsMap.keySet())
                                    FROM Case
                                    WHERE IsClosed = false
                                        AND AccountId = :user.AccountId 
                                        AND RecordTypeId = :spaRecordTypeId];
            
            for(Case caseRec : openCases){
                if(caseRec.Related_Contacts__r != null && !caseRec.Related_Contacts__r.isEmpty()){
                    for(Related_Contact__c relCon : caseRec.Related_Contacts__r){
                        //using of interest flag to indicate if there is an open case on contact
                        contactsMap.get(relCon.Related_Contact__c).Of_Interest__c = true;
                    }
                }
            }
            return contactsMap.values();   
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','getContacts',ex.getMessage(),ex);
            return null;            
        } 
    }
    
    //Function to check that is atleast one contact has address of NSW or not    
    @AuraEnabled
    public static Boolean isAtLeastOneContactHasNSWAddress() {
        try {
            User user = GlobalUtility.getLoggedInUser();
            List<Contact> con = [SELECT Id, MailingState 
                                 FROM Contact 
                                 WHERE AccountId =:user.AccountId 
                                 AND Contact_Type__c =: GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE 
                                 AND MailingState =: GlobalConstants.CONTACT_WITH_NSW_ADDRESS
                                 AND Deactivated__c = FALSE];
            if(con.size()>0)
                return true;
            else 
                return false;
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','isAtLeastOneContactHasNSWAddress',ex.getMessage(),ex);
            return null;            
        }
    }
    
    //Function to update contact
    @AuraEnabled
    public static String updateContact(Contact editedContact) {
        try {
            
            Contact existingContact = [SELECT Id, AccountId, Email, Primary_Contact__c,
                                       Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c 
                                       FROM Contact WHERE Id =: editedContact.Id];
            
            // Check if this contact is last Primary Contact on Account
            if(!editedContact.Primary_Contact__c) {
                
                List<Contact> listPrimaryContacts = [Select Id, AccountId, Primary_Contact__c, Deactivated__c FROM Contact 
                                                     WHERE AccountId =: existingContact.AccountId 
                                                     AND Primary_Contact__c = true
                                                     AND Deactivated__c = false];
                
                // Contact to be set as non Primary Contact is the only Primary Contact on Account
                if(listPrimaryContacts.size() == 1) {
                    
                    for(Contact contactRecord : listPrimaryContacts) {
                        if(contactRecord.Id == editedContact.Id) {
                            return 'Only Primary Contact on Account';
                        }
                    }
                }
            }
            
            // Update User Profile
            if( (existingContact.Is_Access_Level_DVD_Administrator__c == false 
                 && existingContact.Is_Access_Level_DVD_Administrator__c != editedContact.Is_Access_Level_DVD_Administrator__c)
               || (existingContact.Is_Access_Level_Account_Administrator__c == false
                   && existingContact.Is_Access_Level_Account_Administrator__c != editedContact.Is_Access_Level_Account_Administrator__c) ) 
            {
                System.debug('ASPManageAccountContacts updateContact User Profile Upgrade');
                
                // User Profile Upgrade
                // Create Case
                User user =  GlobalUtility.getLoggedInUser();
                Case caseRecord = createCaseForUserProfileUpgrade(user.AccountId);
                
                System.debug('ASPManageAccountContacts updateContact caseRecord: ' + caseRecord);
                Case caseCreated = [SELECT Id, CaseNumber from Case WHERE Id =: caseRecord.Id];
                System.debug('ASPManageAccountContacts updateContact Case Number : ' + caseCreated.CaseNumber);
                
                Id contactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_RECORD_TYPE_CONTACTS).getRecordTypeId();
                
                //create related contact record for contact been updated
                Related_Contact__c relatedContact = new Related_Contact__c();
                relatedContact.Contact_Type__c = editedContact.Contact_Type__c;
                relatedContact.First_Given_Name__c = editedContact.FirstName;
                relatedContact.Family_Name__c = editedContact.LastName;
                relatedContact.Email__c = editedContact.Email;
                relatedContact.Daytime_Phone__c = editedContact.Phone;
                relatedContact.Date_of_Birth__c = editedContact.Birthdate;
                relatedContact.Residential_Address_Street__c = editedContact.MailingStreet;
                relatedContact.Residential_Address_City__c = editedContact.MailingCity;
                relatedContact.Residential_Address_State__c = editedContact.MailingState;
                relatedContact.Residential_Address_Postcode__c = editedContact.MailingPostalCode;
                relatedContact.Residential_Address_Country__c = editedContact.MailingCountry;
                relatedContact.Related_Application__c = caseRecord.Id;
                relatedContact.RecordTypeId = contactRecordTypeId;
                relatedContact.Related_Contact__c = editedContact.Id;
                relatedContact.Is_Access_Level_Account_Administrator__c = editedContact.Is_Access_Level_Account_Administrator__c;
                relatedContact.Is_Access_Level_DVD_Administrator__c = editedContact.Is_Access_Level_DVD_Administrator__c;
                relatedContact.Primary_Contact__c = editedContact.Primary_Contact__c;
                relatedContact.Proof_of_Certified_Supporting_Document__c = editedContact.Proof_of_Certified_Supporting_Document__c;
                relatedContact.Proof_of_Nominated_Manager_Declaration__c = editedContact.Proof_of_Nominated_Manager_Declaration__c;
      
                insert relatedContact;
                
                return caseCreated.CaseNumber;
            }
            else if( (existingContact.Is_Access_Level_DVD_Administrator__c == true 
                      && existingContact.Is_Access_Level_DVD_Administrator__c != editedContact.Is_Access_Level_DVD_Administrator__c)
                    || (existingContact.Is_Access_Level_Account_Administrator__c == true
                        && existingContact.Is_Access_Level_Account_Administrator__c != editedContact.Is_Access_Level_Account_Administrator__c) ) 
            {
                System.debug('ASPManageAccountContacts updateContact User Profile Downgrade');
                
                 if(!editedContact.Is_Access_Level_DVD_Administrator__c && !editedContact.Is_Access_Level_Account_Administrator__c) {
                    editedContact.Deactivated__c = true;
                    editedContact.Deactivation_Date__c = Date.today();
                    editedContact.Status__c = 'Inactive'; 
                }
                
                // Update Contact
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                
                Database.update(editedContact, dml);
                
                // If contact email is updated, also update user email
                if(existingContact.Email != editedContact.Email) {
                    ManageAccountUsers.updateUserEmail(editedContact.Id, editedContact.Email);
                }
                
                // User Profile Downgrade
                ManageAccountUsers.updateUser(new List<Id>{editedContact.Id});
                
                return 'Contact updated successfully.';  
            } else {
                
                // Update Contact
                // This will be updating fields other than access level
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                
                Database.update(editedContact, dml);
                
                // If contact email is updated, also update user email
                if(existingContact.Email != editedContact.Email) {
                    ManageAccountUsers.updateUserEmail(editedContact.Id, editedContact.Email);
                }
                
                return 'Contact updated successfully.';
            }
            
            return 'Success'; 
            
        } catch(Exception ex) {
            System.debug('ASPManageAccountContacts updateContact Exception: ' + ex);
            System.debug('ASPManageAccountContacts updateContact Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','updateContact',ex.getMessage(),ex);
            return null;    
        }
    }
     //Function to check whether licence is Taxilicence or both(Taxilicence + BSP/TSP)
  
     @AuraEnabled
    public static boolean getTaxPayerRegistrationRecord(){
    
        List<Tax_Payer_Registration__c> tpr = new List<Tax_Payer_Registration__c>();
        User user = GlobalUtility.getLoggedInUser();
        
        tpr = [SELECT Id FROM Tax_Payer_Registration__c
               WHERE Service_Provider_Name__c = :user.AccountId 
               AND Status__c = :GlobalConstants.STATUS_ACTIVE 
               ORDER BY createdDate DESC Limit 1];
               
        return tpr.size() > 0 ? TRUE : FALSE;
    }
     //
    //Function to deactivate contact
    @AuraEnabled
    public static String deactivateContact(List<Id> idsToDeactivate) {
        boolean levycontactmatch = false;
        boolean hasTPRmatch = false;
        List<Contact> contactsToBeDeactivated = new List<Contact>();
        Case caseRecord = null;
        List<Related_Contact__c> deactivatedRelatedContacts = new List<Related_Contact__c>();
        Map<Id,Contact> levycontactcheck = new Map<Id,Contact>();
        try {   
            
            if(idsToDeactivate.size()> 0) {
                User user =  GlobalUtility.getLoggedInUser();
              
       Set<Id> objContactIdSet = new Set<Id>(idsToDeactivate);
        system.debug(objContactIdSet);
// levy contact check
    List<Tax_Payer_Registration__c> taxpayerrecord = [select Id,Levy_Contact__c from Tax_Payer_Registration__c where Service_Provider_Name__c =: user.AccountId AND status__c='Active' Limit 1];
         system.debug(taxpayerrecord.size());
                
                if(taxpayerrecord.Size() > 0 )
                    hasTPRmatch = TRUE;
                
                for(Tax_Payer_Registration__c taxpayer : taxpayerrecord){
                    if(objContactIdSet.contains(taxpayer.Levy_Contact__c))
                    levycontactmatch = TRUE;
                }            
                system.debug('levycontactmatch '+ levycontactmatch);
                //Get Contact from Contact Id
                for(Contact contactToDeactivate : [Select Id, Primary_Contact__c, AccountId, Deactivated__c, Deactivation_Date__c, Birthdate, FirstName, LastName, Contact_Type__c, 
                                                   MailingCity, MailingState, MailingStreet, MailingPostalCode, MailingCountry, Phone, Email
                                                   From Contact Where Id IN: idsToDeactivate]) {
                                                       
                                  // levycontactcheck.put(contactToDeactivate.AccountId,contactToDeactivate);                   
                                                       // Check if this contact is last Primary Contact on Account
                                                       if(contactToDeactivate.Primary_Contact__c) {
                                                           
                                                           List<Contact> listPrimaryContacts = [Select Id, AccountId, Primary_Contact__c, Deactivated__c FROM Contact 
                                                                                                WHERE AccountId =: contactToDeactivate.AccountId 
                                                                                                AND Primary_Contact__c = true
                                                                                                AND Deactivated__c = false];
                                                           
                                                           // Contact to be deactivated is the only Primary Contact on Account
                                                           if(listPrimaryContacts.size() == 1) {
                                                               return 'Only Primary Contact on Account';
                                                           }
                                                       }
                                                       
                                                       //Create case record for deactivation request if Contact Type is Nominated Director / Manager
                                                       if((contactToDeactivate.Contact_Type__c == GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE || levycontactmatch == TRUE) && hasTPRmatch == TRUE) {
                                                           
                                                           caseRecord = createCaseForDeactivation(user.AccountId);
                                                           System.debug(LoggingLevel.INFO, 'Case record created with details: ' + caseRecord);
                                                           Id contactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_RECORD_TYPE_CONTACTS).getRecordTypeId();
                                                           
                                                           //create related contact record for contact been deactivated
                                                           Related_Contact__c relatedContact = new Related_Contact__c();
                                                           relatedContact.Contact_Type__c = contactToDeactivate.Contact_Type__c;
                                                           relatedContact.First_Given_Name__c = contactToDeactivate.FirstName;
                                                           relatedContact.Family_Name__c = contactToDeactivate.LastName;
                                                           relatedContact.Email__c = contactToDeactivate.Email;
                                                           relatedContact.Daytime_Phone__c = contactToDeactivate.Phone;
                                                           relatedContact.Date_of_Birth__c = contactToDeactivate.Birthdate;
                                                           relatedContact.Residential_Address_Street__c = contactToDeactivate.MailingStreet;
                                                           relatedContact.Residential_Address_City__c = contactToDeactivate.MailingCity;
                                                           relatedContact.Residential_Address_State__c = contactToDeactivate.MailingState;
                                                           relatedContact.Residential_Address_Postcode__c = contactToDeactivate.MailingPostalCode;
                                                           relatedContact.Residential_Address_Country__c = contactToDeactivate.MailingCountry;
                                                           relatedContact.Related_Application__c = caseRecord.Id;
                                                           relatedContact.RecordTypeId = contactRecordTypeId;
                                                           relatedContact.Related_Contact__c = contactToDeactivate.Id;
                                                           
                                                           deactivatedRelatedContacts.add(relatedContact);
                                                       }
                                                       else {
                                                           
                                                           contactToDeactivate.Deactivated__c = true;
                                                           contactToDeactivate.Deactivation_Date__c = Date.today();
                                                           contactToDeactivate.Status__c = 'Inactive';
                                                           contactsToBeDeactivated.add(contactToDeactivate);
                                                       }
                                                   }
            }
            
            if(contactsToBeDeactivated.size() > 0) {
                update contactsToBeDeactivated;
                PortalUserDeactivator.deactivatePortalUser(idsToDeactivate);
            }  
            
            if(deactivatedRelatedContacts.size() > 0) {
                insert deactivatedRelatedContacts;
                
                Case caseCreated = [SELECT Id, CaseNumber from Case WHERE Id =: caseRecord.Id];
                System.debug('ASPManageAccountContacts deactivateContact Case Number : ' + caseCreated.CaseNumber);
                return caseCreated.CaseNumber;
            }
            
            return '';
            
        } catch(Exception ex) {      
            System.debug('ASPManageAccountContacts deactivateContact Exception: ' + ex);
            System.debug('ASPManageAccountContacts deactivateContact Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','deactivateContact',ex.getMessage(),ex);
            return null;
        }
    }
    
    //Function for creating case for user Profile upgrade.
    private static Case createCaseForUserProfileUpgrade(Id actId) {
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Case caseRecord = new Case();
        caseRecord.Status = GlobalConstants.LODGED_CASE_STATUS;
        caseRecord.Description = GlobalConstants.EDIT_CONTACT_CASE_DESCRIPTION + ' by ' + UserInfo.getName();
        caseRecord.RecordTypeId = devRecordTypeId;
        caseRecord.AccountId = actId;
        caseRecord.Subject = GlobalConstants.EDIT_CONTACT_CASE_DESCRIPTION;
        caseRecord.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
        caseRecord.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
        caseRecord.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION;
        caseRecord.Date_Submitted__c = System.now();
        caseRecord.Maintain_Request_Type__c  = GlobalConstants.CASE_MAINTAIN_REQUEST_EDIT_CONTACT;
        caseRecord.Origin = GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        database.insert(caseRecord, dmo);
        return caseRecord;
    }
    
    //Function for creating case for contact deactivation.
    private static Case createCaseForDeactivation(Id actId) {
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Case caseRecord = new Case();
        caseRecord.Status = GlobalConstants.LODGED_CASE_STATUS;
        caseRecord.Description = GlobalConstants.DEACTIVATION_DESCRIPTION + ' submitted by ' + UserInfo.getName();
        caseRecord.RecordTypeId = devRecordTypeId;
        caseRecord.AccountId = actId;
        caseRecord.Subject = GlobalConstants.DEACTIVATION_DESCRIPTION;
        caseRecord.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
        caseRecord.Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE;
        caseRecord.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION;
        caseRecord.Date_Submitted__c = System.now();
        caseRecord.Maintain_Request_Type__c  = GlobalConstants.CASE_MAINTAIN_REQUEST_DEACTIVATE_CONTACT;
        caseRecord.Origin = GlobalConstants.CASE_ORIGIN_INDUSTRY_PORTAL;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Database.SaveResult result = database.insert(caseRecord, dmo);
        System.debug(LoggingLevel.INFO, 'Status: ' + result.isSuccess());
        System.debug(LoggingLevel.INFO, 'Errors: ' + result.getErrors());
        
        return caseRecord;
    }
    
    //Function for retrive data to edit the selected contact.
    @AuraEnabled
    public static Contact getContactForEdit(String recordId) {
        return [SELECT Id, Account.Record_Type_Dev_Name__c,  Account.Name, Contact_Type__c, Role__c, Primary_Contact__c,
                FirstName, LastName, Email, Phone, Birthdate, 
                MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,  
                Australian_Driver_Licence_Number__c, State__c, Ever_been_known_by_another_name__c, Other_Name_Details__c,
                Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c
                FROM Contact WHERE Id =: recordId LIMIT 1];
    }
    
    //Function for Submitting help request.
    @AuraEnabled
    public static String submitHelpRequest(Case caseRecord){
        String caseNumber;
        try {
            User user = GlobalUtility.getLoggedInUser();
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            caseRecord.RecordTypeId = devRecordTypeId;
            caseRecord.AccountId = user.Contact.AccountId;
            caseRecord.ContactId = user.ContactId;
            caseRecord.Status = GlobalConstants.CASE_NEW;
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            caseRecord.setOptions(dmo);
            
            insert caseRecord;
            
            Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
            caseNumber = caseRec.CaseNumber;
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountContacts','submitHelpRequest',ex.getMessage(),ex);
            return null;
        }
        return caseNumber;
    }
    
    //method used for agents to return the account data for specified accountId
    @AuraEnabled
    public static String getAccountDataForAgents(String accId){
        
        if(GlobalUtility.agentHasAccountAccess(accId) == FALSE)
           return GlobalConstants.UNAUTHORISED_ACCESS;
           
        return TaxiAgentDataAccessProvider.getAccountDataForAgents(accId);
    }
    
    //Function to retrive active contacts related to perticular account.
    @AuraEnabled
    public static List<Contact> getContactsForAgents(String requiredAccId) {
       
       if(GlobalUtility.agentHasAccountAccess(requiredAccId) == FALSE)
           return NULL;
           
       return TaxiAgentDataAccessProvider.getContactsDataForAgents(requiredAccId);
    }
    
}