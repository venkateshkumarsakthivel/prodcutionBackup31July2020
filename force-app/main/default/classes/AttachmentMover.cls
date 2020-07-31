/*
* This class is responsible to - Move attachments from One object record to another
*/  
public without Sharing class AttachmentMover {
    
    static{
        GlobalUtility.ALLOW_FILE_DELETE = true;
    }
    //Move attachments from Related Contact to Contact when Contact gets inserted
    public void moveAttachmentsFromRelatedContactToContact(Map<Id, Contact> newContacts) {
        
        try {
            Map<Id, Id> mapExistingParentIdVSNewParentId = new Map<Id, Id>();
            
            for(Contact contactRec : newContacts.values()) {
                
                System.debug('moveAttachmentsFromRelatedContactToContact FROM ' + contactRec.Associated_Related_Contact__c);
                System.debug('moveAttachmentsFromRelatedContactToContact TO' + contactRec);
                
                if(contactRec.Associated_Related_Contact__c != null) {
                    
                    mapExistingParentIdVSNewParentId.put(contactRec.Associated_Related_Contact__c, contactRec.Id);
                }
            }
            
            this.moveAttachmentsAndContentDocuments(mapExistingParentIdVSNewParentId);
            
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AttachmentMover', 'moveAttachmentsFromRelatedContactToContact', ex.getMessage(), ex);
        }
    }   
    
    private void moveAttachmentsAndContentDocuments(Map<Id, Id> mapExistingParentIdVSNewParentId) {
        
        try {
            // Get Attachments form existing parent object
            List<Attachment> existingAttachments = [Select Id, Name, CreatedDate, Body, Description, ParentId 
                                                    FROM Attachment 
                                                    WHERE ParentId IN :mapExistingParentIdVSNewParentId.keySet()];
            
            Map<String, List<Attachment>> mapExistingParentIdVsAttachments = new Map<String, List<Attachment>>();
            
            for(Attachment attachment : existingAttachments) {
                
                List<Attachment> existingAttachmentsForParentId = mapExistingParentIdVsAttachments.get(attachment.ParentId);
                
                if(existingAttachmentsForParentId == null) {
                    existingAttachmentsForParentId = new List<Attachment>();
                }
                
                existingAttachmentsForParentId.add(attachment);
                mapExistingParentIdVsAttachments.put(attachment.ParentId, existingAttachmentsForParentId);
            }
            
            // Copy all Attachments to new parent object
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            
            if(mapExistingParentIdVsAttachments != null && mapExistingParentIdVsAttachments.size() > 0) {
                
                for(String parentId : mapExistingParentIdVsAttachments.keySet()) {
                    
                    List<Attachment> existingAttachmentsForParentId = mapExistingParentIdVsAttachments.get(parentId);
                    
                    for(Attachment attachment : existingAttachmentsForParentId) {
                        Attachment attachmentToinsert = attachment.clone(false,true,false,false);
                        attachmentToinsert.ParentId = mapExistingParentIdVSNewParentId.get(parentId);
                        attachmentstoinsert.add(attachmentToinsert);
                    }
                }
                
                if(attachmentsToInsert.size() > 0)
                    Database.insert(attachmentsToInsert, false);
                
                //Delete attachments from Related Contact
                if(existingAttachments.size() > 0)
                    Database.delete(existingAttachments, false);
            }
            
            // Get Content files from Related Contact
            /*Set<Id> setOfParentIds = mapExistingParentIdVSNewParentId.keySet();
            List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId 
            From ContentDocumentLink 
            WHERE LinkedEntityId IN : setOfParentIds];*/
            
            // Fix for exception - 
            /**
            * System.QueryException: Implementation restriction: ContentDocumentLink requires a filter by a single Id 
            * on ContentDocumentId or LinkedEntityId using the equals operator or multiple Id's using the IN operator.: 
            * Class.AttachmentMover.moveAttachmentsAndContentDocuments
            */
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            
            for(Id existingParentId : mapExistingParentIdVSNewParentId.keySet()) {
                
                List<ContentDocumentLink> contentDocumentLinksForParentId = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                                                             From ContentDocumentLink 
                                                                             WHERE LinkedEntityId = : existingParentId];
                
                if(contentDocumentLinksForParentId != null && contentDocumentLinksForParentId.size() > 0)
                    contentDocumentLinks.addAll(contentDocumentLinksForParentId);
            }
            
            if(contentDocumentLinks.size() > 0) {
                Set<Id> setDocumentIds = new set<Id>();
                for(ContentDocumentLink documentLink: contentDocumentLinks){
                    setDocumentIds.add(documentLink.ContentDocumentId);
                }
                
                // ContentVersion object contains the all file related required data
                List<ContentVersion> existingContentVersions = [SELECT Id, VersionData, Title, FileType, PathOnClient, FirstPublishLocationId,
                                                                ContentDocumentId 
                                                                FROM ContentVersion
                                                                WHERE ContentDocumentId IN :setDocumentIds AND IsLatest = true];  
                
                Map<String, List<ContentVersion>> mapExistingParentIdVsDocuments = new Map<String, List<ContentVersion>>();
                
                for(ContentVersion contentVersion : existingContentVersions) {
                    
                    List<ContentVersion> existingContentVersionsForParentId = mapExistingParentIdVsDocuments.get(contentVersion.FirstPublishLocationId);
                    
                    if(existingContentVersionsForParentId == null) {
                        existingContentVersionsForParentId = new List<ContentVersion>();
                    }
                    
                    existingContentVersionsForParentId.add(contentVersion);
                    mapExistingParentIdVsDocuments.put(contentVersion.FirstPublishLocationId, existingContentVersionsForParentId);
                }
                
                // Copy all Documents to Contact
                List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
                
                if(mapExistingParentIdVsDocuments != null && mapExistingParentIdVsDocuments.size() > 0) {
                    
                    for(String parentId: mapExistingParentIdVsDocuments.keySet()) {
                        
                        List<ContentVersion> existingContentVersionsForParentId = mapExistingParentIdVsDocuments.get(parentId);
                        
                        for(ContentVersion contentV : existingContentVersionsForParentId) {
                            ContentVersion newcontentV = new ContentVersion();
                            newcontentV.Title  = contentV.Title;
                            newcontentV.PathOnClient  = contentV.PathOnClient;
                            newcontentV.VersionData = contentV.VersionData;
                            newcontentV.FirstPublishLocationId  = mapExistingParentIdVSNewParentId.get(parentId);
                            contentVersionsToInsert.add(newcontentV);
                        }
                    }
                    
                    if(contentVersionsToInsert.size() > 0)
                        Database.insert(contentVersionsToInsert, false);
                    
                    //Delete attachments from Related Contact
                    if(contentDocumentLinks.size() > 0)
                        Database.delete(contentDocumentLinks, false);
                }
            }
            
        } catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'AttachmentMover', 'moveAttachmentsAndContentDocuments', ex.getMessage(), ex);
        }
    }
}