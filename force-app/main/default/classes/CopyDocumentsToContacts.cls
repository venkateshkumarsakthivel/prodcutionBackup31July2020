/**
* @name CopyDocumentsToContacts
* @usage This will used as Controller for MoveDocumentsToContacts.cmp
*
* @author Arxxus P2P developer team @ShubhamAthalye
*/

public with sharing class CopyDocumentsToContacts {

    static{
        GlobalUtility.ALLOW_FILE_DELETE = true;
    }
    
    private class CaseStatusWrapper {
        private Boolean isCaseLodged;
        private Boolean isAdditionalInfoAvailable;
        
        public CaseStatusWrapper(Boolean caseLodged, Boolean additionalInfoAvailable){
            this.isCaseLodged = caseLodged;
            this.isAdditionalInfoAvailable = additionalInfoAvailable;
        }
    }
    
    //send true only if case status is not Draft and New
    @AuraEnabled
    public static String checkCaseStatus(String caseId) {
        Case c = [SELECT Id, Status, (SELECT Id FROM Related_Contacts__r) FROM Case WHERE Id = :caseId];
        Boolean caseStatus = true;
        Boolean additionalInfoAvailable = false;
        
        if(c.Status == 'Draft' || c.Status == 'New')
            caseStatus = false;
        if(c.Related_Contacts__r != null && !c.Related_Contacts__r.isEmpty())
            additionalInfoAvailable = true;
        CaseStatusWrapper wrapper = new CaseStatusWrapper(caseStatus, additionalInfoAvailable);
        return JSON.serialize(wrapper);
    }
    
    //this will create a attachment wrapper which contains basic information about attachment or content file
    //also it will maintain the list of related contacts which doesnot contain the Same Attachment or Content File
    @AuraEnabled
    public static List<FileContentWrapper> getAttachmentsWrapper(String caseId) {
        List<FileContentWrapper> contentWrapperList = new List<FileContentWrapper>();
        
        //all related contacts on the case
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        relatedContactList = [SELECT Id, Name FROM Related_Contact__c 
                              WHERE Related_Application__c =: caseId]; 
                              //AND (ACN__c = NULL OR ACN__c = '')];
        
        Map<String, Related_Contact__c> idVsRelatedContacts = new Map<String, Related_Contact__c>(); 
        for(Related_Contact__c relatedContact : relatedContactList) {
            idVsRelatedContacts.put(relatedContact.Id, relatedContact);
        }
           
        //this will create a map with document title ad a key vs list of related contact as values
        //so that we can analyze related contacts which already contains the document
        Map<String, List<Related_Contact__c>> titleVsRelatedContacts = new Map<String, List<Related_Contact__c>>(); 
        
         //to find the link for content documents attached on case
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink link : [SELECT ContentDocumentId 
                                       FROM ContentDocumentLink 
                                       WHERE LinkedEntityId =: caseId 
                                          OR LinkedEntityId IN :idVsRelatedContacts.keySet()]) {
                                           
            contentDocumentIds.add(link.ContentDocumentId);
        }
        
        //to find the Content Versions attached on case
        List<ContentVersion> contentVersionsOnCase = new List<ContentVersion>();
        for(ContentVersion cv : [Select Id ,Title,fileExtension,FirstPublishLocationId 
                                 from ContentVersion 
                                 Where ContentDocumentId IN : contentDocumentIds]) {
           
            if(idVsRelatedContacts.containsKey(cv.FirstPublishLocationId)) {
                
               Related_Contact__c relatedContact = idVsRelatedContacts.get(cv.FirstPublishLocationId);
               if(titleVsRelatedContacts.containsKey(cv.Title)) {
                   titleVsRelatedContacts.get(cv.Title).add(relatedContact);
               } else {
                   titleVsRelatedContacts.put(cv.Title, new List<Related_Contact__c>{relatedContact} );
               }
            } else {
                contentVersionsOnCase.add(cv);
            }
        }
       
        //TO find Incoming Emails on Cae
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage where ParentId = :caseId AND Incoming = true];
        Set<Id> emailIds = new Set<Id>();
        
        for(EmailMessage email : emails) {
            emailIds.add(email.Id);
        }
        
        //Query Attachments on case, Incoming emails and related contacts on case
        List<Attachment> attachmentsOnCase = new List<Attachment>();
        for(Attachment attachment: [SELECT Id,Name, ParentId
                                    FROM Attachment 
                                    WHERE ParentId IN : idVsRelatedContacts.keySet()
                                    OR ParentId IN : emailIds
                                    OR ParentId = :caseId]) {
          
         String attachmentName = attachment.name;
         if(!attachmentName.contains('SUM_CaseSummary_')) {
            if(idVsRelatedContacts.containsKey(attachment.ParentId)) {    
                Related_Contact__c relatedContact = idVsRelatedContacts.get(attachment.ParentId);
                if(titleVsRelatedContacts.containsKey(attachment.Name)) {
                    titleVsRelatedContacts.get(attachment.Name).add(relatedContact);
                 } else {
                      titleVsRelatedContacts.put(attachment.Name, new List<Related_Contact__c>{relatedContact} );
                 }
            } else {
                attachmentsOnCase.add(attachment);
            }
         }
        }
         
        System.debug('consist list >>' +titleVsRelatedContacts );
        
        //to find the Content Documents attached on case
        for(ContentVersion cv : contentVersionsOnCase) {
            
            Map<String, Related_Contact__c> cloneMap = idVsRelatedContacts.clone();
            if(titleVsRelatedContacts.get(cv.Title) != null) {                                  
                 for(Related_Contact__c rc1 : titleVsRelatedContacts.get(cv.Title)) {
                     cloneMap.remove(rc1.Id);
                 }
            }
            Boolean isAlreadyExistOnContacts = cloneMap.values().size() > 0 ? false : true;
            contentWrapperList.add(new FileContentWrapper(cv.Id, cv.Title, cv.fileExtension,cloneMap.values(),true,isAlreadyExistOnContacts)); 
        }
        
        //to find the attachments attached on the case
        for(Attachment attachment: attachmentsOnCase) {
            
            Map<String, Related_Contact__c> cloneMap = idVsRelatedContacts.clone();
            if(titleVsRelatedContacts.get(attachment.Name) != null) {
                 for(Related_Contact__c rc1 : titleVsRelatedContacts.get(attachment.Name)) {
                     cloneMap.remove(rc1.Id);
                 }
            }
            Boolean isAlreadyExistOnContacts = cloneMap.values().size() > 0 ? false : true;
            contentWrapperList.add(new FileContentWrapper(attachment.Id, attachment.Name,cloneMap.values(),true,isAlreadyExistOnContacts)); 
        } 
        
        return contentWrapperList;
    }
     
    //It will copy documents from case to related contacts
    @AuraEnabled
    public static String uploadDocumentsToContacts(String documentWrappersString) {
       
        List<FileContentWrapper> documentWrapperList = (List<FileContentWrapper>)JSON.deserialize(documentWrappersString, List<FileContentWrapper>.class);
        
        //map to store file id and the target related contact on which the file to be stored
        Map<String,String> fileIdVcRelatedConId = new Map<String,String>();
        
        for(FileContentWrapper fcw : documentWrapperList) {
            if(fcw.contactId != 'None') {
                fileIdVcRelatedConId.put(fcw.fileId, fcw.contactId);
            }
        }
        
        //list of content files which needs to copy on related contact
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        for(ContentVersion cv : [SELECT Id, VersionData, Title, FileType, PathOnClient, FirstPublishLocationId,ContentDocumentId 
                                 FROM ContentVersion
                                 WHERE Id IN :fileIdVcRelatedConId.keySet()
                                 AND IsLatest = true]) {
                 
                                     System.debug('path on client'+ cv.PathOnClient );
                 ContentVersion newcontentV = new ContentVersion();
                 newcontentV.Title  = cv.Title;
                 newcontentV.PathOnClient  = cv.PathOnClient;
                 newcontentV.VersionData = cv.VersionData;
                 newcontentV.FirstPublishLocationId  = fileIdVcRelatedConId.get(cv.Id);
                 contentVersionsToInsert.add(newcontentV);
        }
        
        //list of attachments which needs to copy on related contact
        List<Attachment> attachmentstoinsert = new List<Attachment>();
        for(Attachment attachment : [Select Id, Name, CreatedDate, Body, Description, ParentId 
                                     FROM Attachment 
                                     WHERE Id IN :fileIdVcRelatedConId.keySet()]) {
                    
                Attachment a = attachment.clone(false,true,false,false);
                a.ParentId = fileIdVcRelatedConId.get(attachment.Id);
                attachmentstoinsert.add(a);
       }
        
        Database.insert(contentVersionsToInsert, false);
        
        Database.insert(attachmentstoinsert, false);
        
        return 'saved';
    }
}