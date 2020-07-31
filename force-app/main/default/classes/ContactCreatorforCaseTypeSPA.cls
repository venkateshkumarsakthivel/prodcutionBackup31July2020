/*
- This class is used for creating user from ManageAccount page in Community.
- This class is written in without sharing because when 'P2P Commission Staff' approves case of type 'Service Provider Administration', 
it dose not have permission to create user i.e. manage users permission on his/her profile.
- To Enable user creation, we need to write this class in without sharing.
- Invoked by :- CaseTriggerHandler class.
*/
public without sharing class ContactCreatorforCaseTypeSPA {
    
    //Constructor method to find eligible cases.
    public ContactCreatorforCaseTypeSPA(List<Case> newApplications) {
        try {
            
            List<Case> eligibleCases = new List<Case>();
            for(Case newCase : newApplications){
                if(isEligible(newCase)){
                    eligibleCases.add(newCase);
                }
            }
            if(!eligibleCases.isEmpty())
                createContact(eligibleCases);
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPA','ContactCreatorforCaseTypeSPA',ex.getMessage(),ex);
        }   
    }
    
    //Helper method to find case is eligible or not.
    public boolean isEligible(case caseRecord) {
        try {
            boolean eligible = false;
            if(caseRecord.Status == GlobalConstants.CLOSED_CASE_STATUS
               && caseRecord.Sub_Status__c == GlobalConstants.CASE_APPROVED
               && caseRecord.Maintain_Request_Type__c == GlobalConstants.ADD_CONTACT_CASE_SUB_STATUS
               && caseRecord.Type ==GlobalConstants.CASE_SERVICE_PROVIDER_TYPE
               && caseRecord.Sub_Type__c ==GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION
               && caseRecord.Record_Type_Dev_Name__c ==GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME) {
                   eligible = true;
               }
            return eligible; 
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPA','isEligible',ex.getMessage(),ex);
            return null;
        }  
    }
    
    //Method to create contact. It also creates a list of Contact Ids whose user need's to be created.
    public void createContact(List<Case> caseList) {
        
        try {
            
            List<Contact> contactsToBeCreated = new List<Contact>();
            List<Id> usersToBeCreated = new List<Id>();
            Map<String, Related_Contact__c> caseIdVsRelatedContact = new Map<String, Related_Contact__c>();
            
            List<Related_Contact__c> relatedContactFromCaseList = [SELECT Id, Contact_Type__c, Role__c, Family_Name__c, First_Given_Name__c, Date_of_Birth__c,
                                                                   Daytime_Phone__c, Email__c, Related_Application__c, 
                                                                   Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c, Residential_Address_Postcode__c, Residential_Address_Country__c, 
                                                                   Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c, 
                                                                   Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, 
                                                                   Proof_Of_Endorsement_By_Director_Company__c, Proof_Of_Criminal_History_Check__c,
                                                                   Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                                   Have_been_known_by_other_names__c, Known_by_Other_Names_Details__c,
                                                                   Proof_of_Certified_Supporting_Document__c, Proof_of_Nominated_Manager_Declaration__c
                                                                   FROM Related_Contact__c WHERE Related_Application__c IN :caseList];
            
            for(Related_Contact__c tempRelatedContact : relatedContactFromCaseList)
                caseIdVsRelatedContact.put(tempRelatedContact.Related_Application__c, tempRelatedContact);
            
            for(Case caseRecord : caseList) {
                
                if(caseIdVsRelatedContact.containsKey(caseRecord.Id)) {
                    
                    Contact newContact = new Contact();
                    
                    Related_Contact__c relatedContactFromCase = caseIdVsRelatedContact.get(caseRecord.Id);
                    
                    newContact.AccountId = caseRecord.AccountId; 
                    newContact.Contact_Type__c = relatedContactFromCase.Contact_Type__c;
                    newContact.Role__c = relatedContactFromCase.Role__c;
                    newContact.LastName = relatedContactFromCase.Family_Name__c;
                    newContact.FirstName = relatedContactFromCase.First_Given_Name__c;
                    newContact.Birthdate = relatedContactFromCase.Date_of_Birth__c;
                    newContact.Phone = relatedContactFromCase.Daytime_Phone__c;
                    newContact.Email = relatedContactFromCase.Email__c;
                    newContact.MailingStreet = relatedContactFromCase.Residential_Address_Street__c;
                    newContact.MailingCity = relatedContactFromCase.Residential_Address_City__c;
                    newContact.MailingState = relatedContactFromCase.Residential_Address_State__c;
                    newContact.MailingPostalCode = relatedContactFromCase.Residential_Address_Postcode__c;
                    newContact.MailingCountry = relatedContactFromCase.Residential_Address_Country__c;
                    newContact.Proof_Of_Identity_Documents__c = relatedContactFromCase.Proof_Of_Identity_Documents__c;
                    newContact.Proof_Of_National_Police_Check__c = relatedContactFromCase.Proof_Of_National_Police_Check__c;
                    newContact.Proof_Of_Endorsement_By_Director_Company__c = relatedContactFromCase.Proof_Of_Endorsement_By_Director_Company__c;
                    newContact.Proof_Of_Criminal_History_Check__c = relatedContactFromCase.Proof_Of_Criminal_History_Check__c;
                    newContact.Is_Access_Level_DVD_Administrator__c = relatedContactFromCase.Is_Access_Level_DVD_Administrator__c;
                    newContact.Is_Access_Level_Account_Administrator__c = relatedContactFromCase.Is_Access_Level_Account_Administrator__c;
                    newContact.Australian_Driver_Licence_Number__c = relatedContactFromCase.Australian_Driver_Licence__c;
                    newContact.State__c = relatedContactFromCase.Australian_Driver_Licence_State__c;
                    newContact.Ever_been_known_by_another_name__c = relatedContactFromCase.Have_been_known_by_other_names__c == true ? 'Yes' : 'No';
                    newContact.Other_Name_Details__c = relatedContactFromCase.Known_by_Other_Names_Details__c;
                    newContact.Proof_of_Certified_Supporting_Document__c = relatedContactFromCase.Proof_of_Certified_Supporting_Document__c;
                    newContact.Proof_of_Nominated_Manager_Declaration__c = relatedContactFromCase.Proof_of_Nominated_Manager_Declaration__c;
                    
                    System.debug('Create Contact : ' + newContact);
                    contactsToBeCreated.add(newContact); 
                }
                
            }
            if(!contactsToBeCreated.isEmpty()) {
                
                insert contactsToBeCreated;
                
                for(Contact con : contactsToBeCreated){
                    usersToBeCreated.add(con.Id);
                }
                if(!UsersToBeCreated.isEmpty()) {
                    CreateCommunityUser(usersToBeCreated);
                }
            }
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPA','createContact',ex.getMessage(),ex);
        }   
    }
    
    //Future method to create users of given contacts.
    @future
    public static void CreateCommunityUser(List<Id> contactIds) {
        try {
            
            List<User> usersToBeCreated = new List<User>();
            
            Id accountManagerUserProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME LIMIT 1].Id;
            Id dvdUserProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.MSC_PROFILE_NAME LIMIT 1].Id;
            Id fullAccessUserProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.ASP_PROFILE_NAME LIMIT 1].Id;
            
            for(Contact contact : [SELECT Id, AccountId, FirstName, LastName, Email, Access_Level__c, Contact_Number__c, 
                                   Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c
                                   FROM Contact WHERE Id IN : contactIds])
            {
                
                // Create User only if portal access is required
                if(contact.Is_Access_Level_DVD_Administrator__c || contact.Is_Access_Level_Account_Administrator__c)  
                {
                    
                    User newUser = new User();
                    
                    newUser.ContactId = contact.Id;
                    newUser.FirstName = contact.FirstName;
                    newUser.LastName = contact.LastName;
                    newUser.Email = contact.Email;
                    newUser.Username = GlobalUtility.generateUserName(contact);
                    newUser.CommunityNickname = contact.FirstName + '_' + contact.LastName;
                    String alias = contact.LastName + '_' + contact.FirstName;
                    newUser.Alias = alias.substring(0, 7);
                    newUser.TimeZoneSidKey = 'Australia/Sydney';
                    newUser.LocaleSidKey = 'en_AU';
                    newUser.EmailEncodingKey = 'ISO-8859-1';
                    newUser.LanguageLocaleKey ='en_US';
                    
                    if(contact.Is_Access_Level_DVD_Administrator__c && contact.Is_Access_Level_Account_Administrator__c) {
                        newUser.ProfileId = fullAccessUserProfileId;                
                    } else if(contact.Is_Access_Level_DVD_Administrator__c) {
                        newUser.ProfileId = dvdUserProfileId;    
                    } else if(contact.Is_Access_Level_Account_Administrator__c) {
                        newUser.ProfileId = accountManagerUserProfileId;    
                    }
                    
                    System.debug('Create User : ' + newUser);
                    usersToBeCreated.add(newUser);
                }
            }
            
            insert usersToBeCreated;
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPA','CreateCommunityUser',ex.getMessage(),ex);
        }   
    }
}