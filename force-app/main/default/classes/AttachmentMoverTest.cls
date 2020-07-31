@isTest
public class AttachmentMoverTest {
    @testSetup 
    private static void setupTestData() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Authorisation__c Related to company account */
        
        Tax_Payer_Registration__c taxpayerRegistrationRecord = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                             Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS,
                                                                                             BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                             Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                             Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                             Levy_Notification_Address_Street__c = 'castle');
        insert taxpayerRegistrationRecord;
   }
    
    
    @isTest
    public static void  moveAttachmentsFromRelatedContactToContactTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Contact con = [select id ,Associated_Related_Contact__c from contact where AccountId =:accountId LIMIT 1];
       
        Case newASPCase = new Case(Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = accountId);
        insert newASPCase;
        //System.debug('updated contact is'+ con);
        
        Related_Contact__c relatedContact = new Related_Contact__c();
        relatedContact.First_Given_Name__c = 'Name 1';
        relatedContact.Other_Given_Name__c = 'Other Given Name 1';
        relatedContact.Australian_Driver_Licence__c = 'BSBBSB1';
        relatedContact.Related_Application__c = newASPCase.Id;
        
        insert relatedContact ;
        
        con.Associated_Related_Contact__c = relatedContact.Id;
        //System.debug('updated con is'+ con);
        update con;
        Attachment testAtt = new Attachment();
        testAtt.ParentId = relatedContact.Id;
        testAtt.Body = Blob.valueOf('Unit Test Attachment Body');
        testAtt.Name = 'Unit Test Attachment';
        insert testAtt;
        
        Blob bodyBlobContent1 = Blob.valueOf('Unit Test ContentVersion Body ');
        ContentVersion contentVersion= new ContentVersion(Title='Header_Picture', 
                                                        PathOnClient ='/Header_Picture1.jpg',
                                                        VersionData = bodyBlobContent1, 
                                                        IsMajorVersion = true);           
        
        insert contentVersion;
        //system.debug('content version inserted'+  contentVersion);
        Id documentId = [SELECT Id FROM ContentDocument].Id;
        ContentDocumentLink contentLink = new ContentDocumentLink();
        
        contentLink.LinkedEntityId = relatedContact.Id;
        contentLink.contentdocumentid = documentId ;
        contentLink.ShareType = 'V';
        insert contentLink;
         
        
        Map<Id, Contact> mapIdVsContact =  new Map<Id, Contact>();
        mapIdVsContact.put(con.Id, con);
        
        AttachmentMover attachmentMover =  new AttachmentMover();
        attachmentMover.moveAttachmentsFromRelatedContactToContact(mapIdVsContact);
    }
    
}