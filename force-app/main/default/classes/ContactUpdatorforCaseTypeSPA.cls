/*
- This class is used for updating user from ManageAccount page in Community.
- This class is written in without sharing because when 'P2P Commission Staff' approves case of type 'Service Provider Administration', 
it dose not have permission to deactivate user i.e. manage users permission on his/her profile.
- To Enable user deactivation, we need to write this class in without sharing.
- Invoked by :- CaseTriggerHandler class.
*/
public class ContactUpdatorforCaseTypeSPA {
    
    //Constructor method to find eligible cases.
    public ContactUpdatorforCaseTypeSPA(List<Case> newApplications) {
        try {
            
            List<Case> eligibleCases = new List<Case>();
            for(Case newCase : newApplications){
                if(isEligible(newCase)){
                    eligibleCases.add(newCase);
                }
            }
            if(!eligibleCases.isEmpty())
                updateContact(eligibleCases);
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactUpdatorforCaseTypeSPA','ContactUpdatorforCaseTypeSPA',ex.getMessage(),ex);
        }   
    }
    
    //Helper method to find case is eligible or not.
    public boolean isEligible(Case caseRecord) {
        try {
            boolean eligible = false;
            if(caseRecord.Status == GlobalConstants.CLOSED_CASE_STATUS
               && caseRecord.Sub_Status__c == GlobalConstants.CASE_APPROVED
               && caseRecord.Maintain_Request_Type__c == GlobalConstants.CASE_MAINTAIN_REQUEST_EDIT_CONTACT
               && caseRecord.Type == GlobalConstants.CASE_SERVICE_PROVIDER_TYPE
               && caseRecord.Sub_Type__c ==GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION
               && caseRecord.Record_Type_Dev_Name__c == GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME) {
                   eligible = true;
               }
            return eligible; 
        } catch(Exception ex) {
            System.debug('ContactUpdatorforCaseTypeSPA isEligible Exception: ' + ex);
            System.debug('ContactUpdatorforCaseTypeSPA isEligible Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactUpdatorforCaseTypeSPA','isEligible',ex.getMessage(),ex);
            return null;
        }  
    }
    
    //Method to update contact.It also creates a list of Contact Ids whose user need's to be updated.
    public void updateContact(List<Case> caseList) {
        
        try {
            
            List<Contact> contactsToBeUpdated = new List<Contact>();
            Map<String, Related_Contact__c> caseIdVsRelatedContact = new Map<String, Related_Contact__c>();
            
            List<Related_Contact__c> relatedContactFromCaseList = [SELECT Id, Related_Contact__c, Contact_Type__c, Role__c, Family_Name__c, First_Given_Name__c, Date_of_Birth__c,
                                                                   Daytime_Phone__c, Email__c, Related_Application__c, Primary_Contact__c,
                                                                   Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c, Residential_Address_Postcode__c, Residential_Address_Country__c, 
                                                                   Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c, 
                                                                   Proof_Of_Identity_Documents__c, Proof_Of_National_Police_Check__c, 
                                                                   Proof_Of_Endorsement_By_Director_Company__c, Proof_Of_Criminal_History_Check__c,
                                                                   Have_been_known_by_other_names__c, Known_by_Other_Names_Details__c,
                                                                   Proof_of_Certified_Supporting_Document__c, Proof_of_Nominated_Manager_Declaration__c
                                                                   FROM Related_Contact__c WHERE Related_Application__c IN :caseList];
            
            for(Related_Contact__c tempRelatedContact : relatedContactFromCaseList)
                caseIdVsRelatedContact.put(tempRelatedContact.Related_Application__c, tempRelatedContact);
            
            for(Case caseRecord : caseList) {
                
                if(caseIdVsRelatedContact.containsKey(caseRecord.Id)) {
                    
                    Contact contactRecord = new Contact();
                    
                    Related_Contact__c relatedContactFromCase = caseIdVsRelatedContact.get(caseRecord.Id);
                    
                    contactRecord.Id = relatedContactFromCase.Related_Contact__c; 
                    contactRecord.MailingStreet = relatedContactFromCase.Residential_Address_Street__c;
                    contactRecord.MailingCity = relatedContactFromCase.Residential_Address_City__c;
                    contactRecord.MailingState = relatedContactFromCase.Residential_Address_State__c;
                    contactRecord.MailingPostalCode = relatedContactFromCase.Residential_Address_Postcode__c;
                    contactRecord.MailingCountry = relatedContactFromCase.Residential_Address_Country__c;
                    contactRecord.Phone = relatedContactFromCase.Daytime_Phone__c;
                    contactRecord.Email = relatedContactFromCase.Email__c;
                    contactRecord.Is_Access_Level_DVD_Administrator__c = relatedContactFromCase.Is_Access_Level_DVD_Administrator__c;
                    contactRecord.Is_Access_Level_Account_Administrator__c = relatedContactFromCase.Is_Access_Level_Account_Administrator__c;
                    contactRecord.Primary_Contact__c = relatedContactFromCase.Primary_Contact__c;
					contactRecord.Ever_been_known_by_another_name__c = relatedContactFromCase.Have_been_known_by_other_names__c == true ? 'Yes' : 'No';
					contactRecord.Other_Name_Details__c = relatedContactFromCase.Known_by_Other_Names_Details__c;
                    contactRecord.Proof_of_Certified_Supporting_Document__c = relatedContactFromCase.Proof_of_Certified_Supporting_Document__c;
        			contactRecord.Proof_of_Nominated_Manager_Declaration__c = relatedContactFromCase.Proof_of_Nominated_Manager_Declaration__c;
                    
                    System.debug('Update Contact : ' + contactRecord);
                    contactsToBeUpdated.add(contactRecord); 
                }
                
            }
            if(!contactsToBeUpdated.isEmpty()) {
                
                // Note - When we update contact record as, community user is also updated by other existing process.

                update contactsToBeUpdated;
            }
            
        } catch(Exception ex) {
            System.debug('ContactUpdatorforCaseTypeSPA updateContact Exception: ' + ex);
            System.debug('ContactUpdatorforCaseTypeSPA updateContact Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactUpdatorforCaseTypeSPA','updateContact',ex.getMessage(),ex);
        }   
    }
}