global without sharing class P2POTAttachmentController {
    
    public transient Attachment attachment;
    public String attachId {get; set;}
    public String show = 'hide';
    public String message = '';
    public String success = '';
    public String parent {set; get;}
    public String identifier {set; get;}
    public Attachment getAttachment()  {
        this.attachment = new Attachment();
        return this.attachment;
    }
    
    public String getShow() { return this.show; }
    public String getSuccess() { return this.success; }
    public String getMessage() { return this.message; }
    
    public void uploadFromPage()  {
        P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
        
        String section = (String) ApexPages.currentPage().getParameters().get('section');
        String category = (String) ApexPages.currentPage().getParameters().get('category');
        String ctype = (String) ApexPages.currentPage().getParameters().get('type');
        identifier = (String) ApexPages.currentPage().getParameters().get('identifier');
        String extension = '';
        String fileName = section + '_' + category + '_' + ctype + '_' + String.valueOf(DateTime.now().getTime());
        
        if(ApexPages.currentPage().getParameters().get('parent') != null) {
            parent = ApexPages.currentPage().getParameters().get('parent');
        }
        
        Boolean result = isFileExist(parent, category + '-' + this.attachment.Name);
        if(result){
            this.show = 'show';
            this.success = 'error';
            this.message = 'File with name \"' + this.attachment.Name + '\" already exists on the application';
            return;
        }
        
        System.debug('this.attachment : ' + this.attachment);

        if(null != this.attachment.Name && !String.isBlank(parent))  {
            System.debug('check .exe : ' + this.attachment.Name.endsWithIgnoreCase('.exe'));
            
            // Added on 10 July : Venkat : P2PSUPPORT-250
                if(!this.attachment.Name.endsWithIgnoreCase('.exe')) {
                List<String> splits = this.attachment.Name.split('\\.');

                /** changing logic to name a attachment to fix bug #P2P-2510
                if(splits.size() > 1)  {
                    extension = splits.get(splits.size() - 1);
                }
                this.attachment.Name = fileName; 
                this.attachment.Name = this.attachment.Name.subString(0, 21) + '.' + extension;
                */
                this.attachment.Name = category + '-' + this.attachment.Name;
                this.attachment.Description = 'Confidential';
                parent = (Id) ApexPages.currentPage().getParameters().get('parent');
                this.attachment.ParentId = parent;
                    try {
                        /** commenting two lines to deactivate OT upload
                            Boolean response = p2POTAttachmentFacade.upload(parent, this.attachment.Name, EncodingUtil.base64Encode(this.attachment.Body), this.attachment.ContentType);
                            if(true == response) { this.sshow = 'show'; this.eshow = 'hide'; } else { this.sshow = 'hide'; this.eshow = 'show'; }            
                        */
                        /* below lines will insert attachment against parent passed as parameter. */
                        System.debug(LoggingLevel.Error, 'User : ' + UserInfo.getUserName() + ' id: ' + UserInfo.getUserId());
                        insert this.attachment;
                        attachId = this.attachment.Id;
                        
                        this.success = 'success';
                        this.message = 'File ' + ( null == this.attachment.Name ? '' : this.attachment.Name ) + ' uploaded successfully';
                        this.show = 'show'; 
                    } catch(Exception commonException)  {
                        System.debug('Error : ' + commonException.getMessage());
                        this.success = 'error';
                        this.message = 'File Exception' + ( null == this.attachment.Name ? '' : this.attachment.Name ) + ' upload failed';
                        this.show = 'show';
                    }   
                }else{
                        this.show = 'show';
                        this.success = 'error';
                        this.message = 'File Error' + ( null == this.attachment.Name ? '' : this.attachment.Name ) + ' upload failed - invalid file type. Please try a different format.';

                }
            }else {
            this.show = 'show';
            this.success = 'error';
            this.message = 'File Error' + ( null == this.attachment.Name ? '' : this.attachment.Name ) + ' upload failed';
        }
    }
    
    
    @AuraEnabled
    public static String getUserType() {
        User loggedInUser = GlobalUtility.getLoggedInUser();
        return loggedInUser.UserType;        
    }
    
    @AuraEnabled
    public static Boolean  upload(String parent, String name, String contents, String ctype)  {
            System.debug('P2POTAttachmentController.upload ' + parent + ' for Case ' + name + ' is file.');
            P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
            Boolean response = p2POTAttachmentFacade.upload(parent, name, contents, ctype);
            return response;
    }
    
    @AuraEnabled
    public static String rbrowse(String parent)  {
            P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
            List<OTNode> openTextDocuments = p2POTAttachmentFacade.rbrowse(parent);
            return JSON.serialize(openTextDocuments);
    }
    
    /*
    @AuraEnabled
    public static String browse(String parent)  {
            P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
            List<OTNode> openTextDocuments = p2POTAttachmentFacade.browse(parent);
            return JSON.serialize(openTextDocuments);
    }*/
    
    @AuraEnabled
    public static String browse(String parent)  {
        List<OTNode> openTextDocuments = getListofAttachments(parent);
        return JSON.serialize(openTextDocuments);
    }
    
    /**
     * This method will be used to list documents from loacal salesforce Attachment Object from community pages.
     */
    private static List<OTNode> getListofAttachments(String identifier)  {
        List<OTNode> fileNodes = new List<OTNode>();
        fileNodes = attachments(identifier);
        return fileNodes;
    }
    
    private static List<OTNode> attachments(String identifier)  {
        
        System.debug('Who am I : ' + UserInfo.getUserName() + ' : ' + UserInfo.getUserId());
        
        User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<Attachment> attachments = new List<Attachment>();
        
        List<Related_Contact__c> relatedContacts = [SELECT Id FROM Related_Contact__c WHERE Related_Application__c = :identifier];
        System.debug('Related contacts' + relatedContacts);
        SET<String> relatedContactIds = new SET<String>();
        for(Related_Contact__c relatedContact : relatedContacts) {
            relatedContactIds.add(relatedContact.Id);
        }
        
        System.debug('Related contacts IDs' + relatedContactIds);
        attachments = [SELECT Id, Name, ContentType, BodyLength, OwnerId, ParentId FROM Attachment WHERE (ParentId = :identifier OR ParentId IN :relatedContactIds)];
        
        System.debug(identifier+ 'in the facade browse' + attachments);
        List<OTNode> files = new List<OTNode>();
        
        for(Attachment attachment : attachments)  {
            
            files.add(new OTNode(attachment.Name, 0, false, attachment.ContentType, attachment.BodyLength, attachment.Id));
        }
        
        return files;
    }
    
    @AuraEnabled
    public static Integer getMaxAttachmentCount(String parentId){
        List<Attachment> attachments = [SELECT id FROM Attachment WHERE ParentId = :parentId];
        return attachments.size();
    }
    
    @AuraEnabled
    public static void deleteAttachments(String attachmentId)  {
        Attachment attachmentToBeDeleted = [SELECT Id FROM Attachment WHERE Id= : attachmentId];
        Database.delete(attachmentToBeDeleted, false);
    }
    
    @AuraEnabled
    public static Boolean isCaseLodged(String caseId) {
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Id = :caseId AND Status IN ('Draft', 'New')];
        
        return cases.isEmpty();
    }
    
    private Boolean isFileExist(String parentId, String fileName){
        List<Attachment> attachments = [SELECT id FROM Attachment WHERE ParentId = :parentId and Name = :fileName];
        return !attachments.isEmpty();
    }
}