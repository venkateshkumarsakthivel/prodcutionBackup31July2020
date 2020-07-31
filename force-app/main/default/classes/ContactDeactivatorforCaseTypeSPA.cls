/*
- This class is used for deactivating user from ManageAccount page in Community.
- This class is written in without sharing because when 'P2P Commission Staff' approves case of type 'Service Provider Administration', 
it dose not have permission to deactivate user i.e. manage users permission on his/her profile.
- To Enable user deactivation, we need to write this class in without sharing.
- Invoked by :- CaseTriggerHandler class.
*/
public class ContactDeactivatorforCaseTypeSPA {
    
    //Constructor method to find eligible cases.
    public ContactDeactivatorforCaseTypeSPA(List<Case> newApplications) {
        try {
            
            List<Case> eligibleCases = new List<Case>();
            for(Case newCase : newApplications){
                if(isEligible(newCase)){
                    eligibleCases.add(newCase);
                }
            }
            if(!eligibleCases.isEmpty())
                deactivateContact(eligibleCases);
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactDeactivatorforCaseTypeSPA','ContactDeactivatorforCaseTypeSPA',ex.getMessage(),ex);
        }   
    }
    
    //Helper method to find case is eligible or not.
    public boolean isEligible(Case caseRecord) {
        try {
            boolean eligible = false;
            if(caseRecord.Status == GlobalConstants.CLOSED_CASE_STATUS
               && caseRecord.Sub_Status__c == GlobalConstants.CASE_APPROVED
               && caseRecord.Maintain_Request_Type__c == GlobalConstants.CASE_MAINTAIN_REQUEST_DEACTIVATE_CONTACT
               && caseRecord.Type == GlobalConstants.CASE_SERVICE_PROVIDER_TYPE
               && caseRecord.Sub_Type__c ==GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION
               && caseRecord.Record_Type_Dev_Name__c == GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_DEV_NAME) {
                   eligible = true;
               }
            return eligible; 
        } catch(Exception ex) {
            System.debug('ContactDeactivatorforCaseTypeSPA isEligible Exception: ' + ex);
            System.debug('ContactDeactivatorforCaseTypeSPA isEligible Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactDeactivatorforCaseTypeSPA','isEligible',ex.getMessage(),ex);
            return null;
        }  
    }
    
    //Method to deactivate contact.
    public void deactivateContact(List<Case> caseList) {
        
        try {
            
            List<Contact> contactsToBeDeactivated = new List<Contact>();
            List<Id> usersToBeDeactivated = new List<Id>();
            
            Map<String, Related_Contact__c> caseIdVsRelatedContact = new Map<String, Related_Contact__c>();
            
            List<Related_Contact__c> relatedContactFromCaseList = [SELECT Id, Contact_Type__c, Role__c, First_Given_Name__c, Family_Name__c, Email__c, Daytime_Phone__c, Date_of_Birth__c,
                                                                   Residential_Address_Street__c, Residential_Address_City__c, Residential_Address_State__c, Residential_Address_Postcode__c, Residential_Address_Country__c, 
                                                                   Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c, 
                                                                   Related_Application__c, Related_Contact__c
                                                                   FROM Related_Contact__c WHERE Related_Application__c IN :caseList];
            
            for(Related_Contact__c tempRelatedContact : relatedContactFromCaseList)
                caseIdVsRelatedContact.put(tempRelatedContact.Related_Application__c, tempRelatedContact);
            
            for(Case caseRecord : caseList) {
                
                if(caseIdVsRelatedContact.containsKey(caseRecord.Id)) {
                    
                    Related_Contact__c relatedContactFromCase = caseIdVsRelatedContact.get(caseRecord.Id);
                    
                    Contact contactToDeactivate = new Contact();	
                    contactToDeactivate.Id = relatedContactFromCase.Related_Contact__c;
                    contactToDeactivate.Deactivated__c = true;
                    contactToDeactivate.Deactivation_Date__c = Date.today();
                    contactToDeactivate.Status__c = 'Inactive';
                    
                    System.debug('Deactivate Contact : ' + contactToDeactivate);
                    
                    contactsToBeDeactivated.add(contactToDeactivate); 
                }
                
            }
            if(!contactsToBeDeactivated.isEmpty()) {
                
                // Note - When we update contact record as inactive, community user is also set to inactive by other existing process.
                update contactsToBeDeactivated;
            }
            
        } catch(Exception ex) {
            System.debug('ContactDeactivatorforCaseTypeSPA deactivateContact Exception: ' + ex);
            System.debug('ContactDeactivatorforCaseTypeSPA deactivateContact Exception: ' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactDeactivatorforCaseTypeSPA','deactivateContact',ex.getMessage(),ex);
        }   
    }
}