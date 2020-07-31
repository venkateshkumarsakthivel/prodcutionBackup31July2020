public class FileContentWrapper {
    
	@AuraEnabled 
    public  String fileId{get;set;}		//for attachment it is attachment Id and for Files it is Content DocumentID
    @AuraEnabled
    public  String contentDocumentName{get;set;} // File or Attachent Name
    @AuraEnabled
    public  String contentDocumentExtension{get;set;}
    @AuraEnabled
    public  List<Related_Contact__c> contactList{get;set;} //Store list of all related contacts
    @AuraEnabled
    public String contactId {get;set;}		//for storing the id of the Parent related contact
    @AuraEnabled
    public Boolean isContentFile {get;set;}
    @AuraEnabled
    public Boolean isAttachment {get;set;}
    @AuraEnabled
    public Boolean isAlreadyExistOnContacts {get;set;}

    public FileContentWrapper(String linkId, String documentName, String fileExtension,List<Related_Contact__c> contacts, Boolean isContentFile,Boolean isAlreadyExistOnContacts) {
        this.fileId = linkId;
        this.contentDocumentName = documentName;
        this.contactList = contacts;
        this.contentDocumentExtension = fileExtension;
        this.isContentFile = isContentFile;
        this.isAlreadyExistOnContacts = isAlreadyExistOnContacts;
    }
    public FileContentWrapper(String linkId, String documentName, List<Related_Contact__c> contacts,Boolean isAttachment, Boolean isAlreadyExistOnContacts) {
        this.fileId = linkId;
        this.contentDocumentName = documentName;
        this.contactList = contacts;
        this.isAttachment = isAttachment;
        this.isAlreadyExistOnContacts = isAlreadyExistOnContacts;
    }
}