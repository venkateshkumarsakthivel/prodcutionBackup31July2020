/**
*  Description: Test class for CopyDocumentsToContacts classe
*/
@isTest
public class CopyDocumentsToContactsTest {

    // create one case under which 2 related contacts , 2 content docs and 2 attachments
    @testSetup  
    static void TestSetup() {
        
        //This is to create Content files
        List<ContentVersion> versionsForTest = new List<ContentVersion>();
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Taxi Individual Application').getRecordTypeId();
       
        Case c = new Case(Family_name__c = 'Family Name 1',Service_Type__c = 'Taxi',Status = GlobalConstants.LODGED_CASE_STATUS, 
                          Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED,Type = GlobalConstants.TAXI_INDIVIDUAL_APPLICATION, 
                          recordtypeId = RecordTypeIdCase);
        insert c;
        
        for(Integer ctr=0; ctr<2; ctr++) {     
            Blob bodyBlobContent1 = Blob.valueOf('Unit Test ContentVersion Body '+ctr);
            versionsForTest.add(new ContentVersion(Title='Header_Picture'+ctr, 
                                                   PathOnClient ='/Header_Picture1.jpg',
                                                   VersionData = bodyBlobContent1, 
                                                   origin = 'H'));    
        }
        insert versionsForTest;
        
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        List<Attachment> attachments = new List<Attachment>();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<Related_Contact__c> relatedContacts = new List<Related_Contact__c>();
        
        //creating one attachment and one file under each email message
        Integer index = 0;
        for(ContentDocument cd : documents) {
            
            //Creating one Attachment
            Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment' + index;
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=c.id;
            attachments.add(attach);
            
            //Creating one Content file
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = c.id;
            contentlink.contentdocumentid =cd.Id;
            contentlink.ShareType = 'V';
            links.add(contentlink);
            
            //related contacts under case
            Related_Contact__c rc = new Related_Contact__c();
            rc.First_Given_Name__c = 'RC'+ index;
            rc.Other_Given_Name__c = 'other' + index;
            rc.Related_Application__c = c.Id;
            rc.Australian_Driver_Licence__c = 'BSBBSB'+index++;
            relatedContacts.add(rc);
        }
        
        insert links;
        insert attachments;
        insert relatedContacts;
    }

    @istest 
    public static void getAttachmentsWrapperTest(){
      
        Case c = [SELECT Id FROM Case LIMIT 1];
        List<Related_Contact__c> relatedContacts = [SELECT Id FROM Related_Contact__c];
        
        //this will attach one content doc on one related contact 
       ContentVersion cv = [SELECT Id, VersionData, Title, FileType, PathOnClient, FirstPublishLocationId,ContentDocumentId 
                           FROM ContentVersion LIMIT 1];
                 
        ContentVersion newcontentV = new ContentVersion();
        newcontentV.Title  = cv.Title;
        newcontentV.PathOnClient  = cv.PathOnClient;
        newcontentV.VersionData = cv.VersionData;
        newcontentV.FirstPublishLocationId  = relatedContacts[0].Id;
        insert newcontentV;
        
        //this will attach one attachment on one related contact
        Attachment attachment = [Select Id, Name, CreatedDate, Body, Description, ParentId 
                                 FROM Attachment LIMIT 1];
                    
        Attachment a = attachment.clone(false,true,false,false);
        a.ParentId = relatedContacts[1].Id;
        insert a;
        
        CopyDocumentsToContacts.checkCaseStatus(c.Id);
        List<FileContentWrapper> wrapperList = CopyDocumentsToContacts.getAttachmentsWrapper(c.Id);
        System.debug('Wrapper size >>'+ wrapperList);
        CopyDocumentsToContacts.uploadDocumentsToContacts(JSON.serialize(wrapperList)); 
        System.assertEquals(wrapperList.size(), 4);
        
        
        
    }     
    
}