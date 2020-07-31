//Class for creating contact.
public without sharing class AddContactController {
    public class HelpRequestException extends Exception{}
    
    //Add new contact from Portal -
    //1 - Create case of Type - Service Provider and Sub Type - Maintain Authorisation
    //2 - Create Related Contact
    @AuraEnabled
    public static String submitSupportRequest(Case caseRecord, Related_Contact__c newContact,String attacmentPrefix) {
        
        String caseNumber;
        
        try {
            User user = GlobalUtility.getLoggedInUser();
            
            Id sapRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            caseRecord.RecordTypeId = sapRecordTypeId;
            caseRecord.AccountId = user.Contact.AccountId;
            caseRecord.Description = GlobalConstants.ADD_CONTACT_REQUEST + ' submitted by ' + UserInfo.getName();
            
            //set dml options to trigger case assignment
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            caseRecord.setOptions(dmo);
            
            insert caseRecord; 
            
            List<Attachment> attachmentsToDelete = updateParentIdOnAttachment(user.ContactId ,attacmentPrefix);
            List<Attachment> attachmentstoinsert = new List<Attachment>();
            if(attachmentsToDelete != null && attachmentsToDelete.size() > 0){
                for(Attachment attachment : attachmentsToDelete){
                    Attachment attachmentToinsert = attachment.clone(false,true,false,false);
                    attachmentToinsert.ParentId = caseRecord.Id;
                    attachmentToinsert.Name = attachment.Name.remove(attacmentPrefix+'-');
                    attachmentstoinsert.add(attachmentToinsert);
                    
                }
                
                insert attachmentstoinsert;
                GlobalUtility.ALLOW_FILE_DELETE = true;
                delete  attachmentsToDelete;
            }
            
            Id contactsRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.RELATED_CONTACT_RECORD_TYPE_CONTACTS).getRecordTypeId();
            
            newContact.RecordTypeId = contactsRecordTypeId;
            newContact.Related_Application__c = caseRecord.Id;
            insert newContact;
            
            Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
            caseNumber = caseRec.CaseNumber;
            
            return caseNumber;
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AddContactController','submitSupportRequest',ex.getMessage(),ex);
            return null; 
        } 
    }
    
    //This function is to return account attachment to update parent id with case
    private static List<Attachment> updateParentIdOnAttachment(Id contactId,String attacmentPrefix){
        String attacmentPrefixForLike = attacmentPrefix+'%';
        List<Attachment>contactAttachments = [Select Id,Name,CreatedDate,Body,Description from Attachment where parentId = :contactId  and name LIKE :attacmentPrefixForLike order by createdDate desc ];
        //accountAttachments[0].name = accountAttachments[0].name.remove(attacmentPrefix+'-');
        return contactAttachments;
    }
}