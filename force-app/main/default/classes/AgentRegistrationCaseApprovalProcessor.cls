/*
* Helper class to detect if agent registration case 
* is approved or rejected and then accordingly create agent
* account and contact which inturn triggers agent user creation
*/
public without sharing class AgentRegistrationCaseApprovalProcessor {
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    public AgentRegistrationCaseApprovalProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
    } 
    
    public void processApprovedAgentRegistrationCases() {    
        
        try {
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.optAllorNone = FALSE;
            dmo.DuplicateRuleHeader.allowSave = true;
            dmo.DuplicateRuleHeader.runAsCurrentUser = false;
            
            Set<String> approvedAgentRegistrationCaseIds = new Set<String>();
            
            Map<String, List<Related_Contact__c>> agentRegistrationCaseVsRelatedContact = new Map<String, List<Related_Contact__c>>();
            Map<String, Account> agentRegistrationCaseVsInsertedAccount = new Map<String, Account>();
            
            List<Contact> contactsToInsert = new List<Contact>();
            
            for(Case tempCase : newCases.values()) {
                
                if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE_DEV_NAME
                   && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                   && tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS
                   && tempCase.Sub_Status__c != oldCases.get(tempCase.Id).Sub_Status__c
                   && tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_AGENT_REGISTRATION) {
                       
                       approvedAgentRegistrationCaseIds.add(tempCase.Id);
                   }
            }
            
            System.debug('Agent Registration Cases: '+approvedAgentRegistrationCaseIds.size());
            
            if(approvedAgentRegistrationCaseIds.isEmpty())
                return;
            
            for(Related_Contact__c tempRelatedContact : [SELECT Name, Title__c, First_Given_Name__c, Family_Name__c, Other_Given_Name__c,
                                                         Date_of_Birth__c, Australian_Driver_Licence__c, Australian_Driver_Licence_State__c,
                                                         Daytime_Phone_Number__c, Business_Address_City__c, Business_Address_Country__c,
                                                         Business_Address_Postal_Code__c, Business_Address_State__c, Business_Address_Street__c,
                                                         Residential_Address_City__c, Residential_Address_Country__c, Residential_Address_Postcode__c,
                                                         Residential_Address_State__c, Residential_Address_Street__c, Email__c, Related_Application__c,
                                                         Contact_Type__c, Corporation_Name__c, ACN__c, Daytime_Phone__c,Registered_Business_Name__c,
                                                         Notice_Address_City__c,Notice_Address_Country__c,Notice_Address_Postal_Code__c,Notice_Address_State__c,Notice_Address_Street__c
                                                         FROM Related_Contact__c
                                                         WHERE Related_Application__c IN :approvedAgentRegistrationCaseIds
                                                         ORDER BY ACN__c DESC NULLS LAST
                                                        ]) {
                                                            
                                                            List<Related_Contact__c> tempExistingRelatedContacts = new List<Related_Contact__c>();
                                                            if(agentRegistrationCaseVsRelatedContact.containsKey(tempRelatedContact.Related_Application__c))
                                                                tempExistingRelatedContacts = agentRegistrationCaseVsRelatedContact.get(tempRelatedContact.Related_Application__c); 
                                                            
                                                            tempExistingRelatedContacts.add(tempRelatedContact);
                                                            agentRegistrationCaseVsRelatedContact.put(tempRelatedContact.Related_Application__c, tempExistingRelatedContacts);    
                                                            
                                                        }
            
            for(String tempRegistrationCaseId : agentRegistrationCaseVsRelatedContact.KeySet()) {
                
                for(Related_Contact__c tempRelatedContact : agentRegistrationCaseVsRelatedContact.get(tempRegistrationCaseId)) {
                    
                    Account tempAcc = new Account();
                    
                    //identify if related contact record is storing account's information
                    if(String.isNotBlank(tempRelatedContact.ACN__c))
                        tempAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
                    else
                        tempAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL).getRecordTypeId();
                    
                    tempAcc.Name = tempRelatedContact.Name;
                    tempAcc.ACN__c = tempRelatedContact.ACN__c;
                    tempAcc.Phone = tempRelatedContact.Daytime_Phone__c;
                    tempAcc.Notice_Email__c = tempRelatedContact.Email__c;
                    tempAcc.Notice_Address_City__c = tempRelatedContact.Notice_Address_City__c;
                    tempAcc.Notice_Address_Country__c = tempRelatedContact.Notice_Address_Country__c;
                    tempAcc.Notice_Address_Postal_Code__c = tempRelatedContact.Notice_Address_Postal_Code__c;
                    tempAcc.Notice_Address_State__c = tempRelatedContact.Notice_Address_State__c;
                    tempAcc.Notice_Address_Street__c = tempRelatedContact.Notice_Address_Street__c;
                    tempAcc.Email__c = tempRelatedContact.Email__c;
                    tempAcc.Registered_Business_Name__c = tempRelatedContact.Registered_Business_Name__c;
                    
                    agentRegistrationCaseVsInsertedAccount.put(tempRelatedContact.Related_Application__c, tempAcc);
                    
                    break;
                }
            }
            
            System.debug('Accounts To Insert: '+agentRegistrationCaseVsInsertedAccount.values());
            Database.SaveResult[] srListInsertAccounts = Database.insert(agentRegistrationCaseVsInsertedAccount.values(), dmo);
            System.debug('Accounts To Insert Result: '+srListInsertAccounts);
            
            for(String tempRegistrationCaseId : agentRegistrationCaseVsRelatedContact.KeySet()) {
                
                for(Related_Contact__c tempRelatedContact : agentRegistrationCaseVsRelatedContact.get(tempRegistrationCaseId)) {
                    
                    Contact tempContact = new Contact();
                    
                    //identify if related contact record is not storing account's information
                    if(String.isBlank(tempRelatedContact.ACN__c)) {
                        
                        tempContact.AccountId = agentRegistrationCaseVsInsertedAccount.get(tempRelatedContact.Related_Application__c).Id;
                        tempContact.Salutation = tempRelatedContact.Title__c;
                        tempContact.BirthDate = tempRelatedContact.Date_of_Birth__c;
                        tempContact.FirstName = tempRelatedContact.First_Given_Name__c;
                        tempContact.LastName = tempRelatedContact.Family_Name__c;
                        tempContact.Australian_Driver_Licence_Number__c = tempRelatedContact.Australian_Driver_Licence__c;
                        tempContact.State__c = tempRelatedContact.Australian_Driver_Licence_State__c;
                        tempContact.Phone = tempRelatedContact.Daytime_Phone__c;
                        tempContact.Email = tempRelatedContact.Email__c;
                        tempContact.Contact_Type__c = tempRelatedContact.Contact_Type__c;
                        tempContact.Other_Given_Name__c = tempRelatedContact.Other_Given_Name__c;
                        tempContact.Primary_Contact__c = TRUE;
                        
                        tempContact.MailingCity = tempRelatedContact.Business_Address_City__c;
                        tempContact.MailingCountry = tempRelatedContact.Business_Address_Country__c;
                        tempContact.MailingPostalCode = tempRelatedContact.Business_Address_Postal_Code__c;
                        tempContact.MailingState = tempRelatedContact.Business_Address_State__c;
                        tempContact.MailingStreet = tempRelatedContact.Business_Address_Street__c;
                        
                        tempContact.OtherCity = tempRelatedContact.Residential_Address_City__c;
                        tempContact.OtherCountry = tempRelatedContact.Residential_Address_Country__c;
                        tempContact.OtherPostalCode = tempRelatedContact.Residential_Address_Postcode__c;
                        tempContact.OtherState = tempRelatedContact.Residential_Address_State__c;
                        tempContact.OtherStreet = tempRelatedContact.Residential_Address_Street__c;
                        tempContact.Is_Access_Level_Taxi_Agent__c = TRUE;
                        
                        contactsToInsert.add(tempContact); 
                    } 
                }
            }
            
            System.debug('Contacts To Insert: '+contactsToInsert);
            Database.SaveResult[] srListInsertContacts = Database.insert(contactsToInsert, dmo);
            System.debug('Contacts To Insert Result: '+srListInsertContacts);
        } 
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AgentRegistrationCaseApprovalProcessor','processApprovedAgentRegistrationCases',ex.getMessage(),ex);                        
        }
    }    
    
}