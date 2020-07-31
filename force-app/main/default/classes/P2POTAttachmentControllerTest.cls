/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class P2POTAttachmentControllerTest { 
    @testSetup
    private static void initialize() {
        try {
       Id ownerid = GlobalUtility.getOwnerId();
            Account account = new Account(Name = 'Account For Order',OwnerId=ownerid);
            insert account;
            
            Contact contact = new Contact(LastName ='paymentStatusControllerTestLastName',AccountId = account.Id, Email='paymentStatusControllerTestUser@testing.don');
            insert contact;
            
            Id profileId = [select Id from profile where name='Authorised Service Provider'].Id;
            User user = new User(alias = 'PSTEST', email='paymentStatusControllerTestUser@testing.don',
                                 emailencodingkey='UTF-8', lastname='paymentStatusControllerTestUserLastName', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileId, country='India', IsActive =true,
                                 contactId = contact.Id,
                                 timezonesidkey='America/Los_Angeles', username='tpaymentStatusControllerTestUser@testing.don');
            
            insert user;
            
            Case newASPCase = new Case(Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                       Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                       Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = account.Id);
            
            insert newASPCase;
            
        } catch(Exception cexception) {
            System.debug(cexception.getMessage());
        }
        
    }
    
    private static testMethod void testUploadSuccess() {
        /* test data creation. */
        String parent = '5000l000000vGoqAAE';
        String name = 'P2POTAttachmentFacadeTest_upload.txt';
        String contents = EncodingUtil.base64Encode(Blob.valueOf('upload is being tested using test case class, these contents will be help in the file named : P2POTAttachmentFacadeTest_upload.txt'));
        String ctype = 'text/plain';
        
        /* actual method invocation. */
        Boolean response = P2POTAttachmentController.upload(parent, name, contents, ctype);
        System.assert(response == true, ' Actual response ' + response);
    }
    
    private static testMethod void testRBrowseSuccess() {
        /* test data creation. */
        String parent = '5000l000000vGoqAAE';
        
        /* actual method invocation. */
        String openTextDocuments = P2POTAttachmentController.rbrowse(parent);
        List<OTNode> files = (List<OTNode>) JSON.deserialize(openTextDocuments, List<OTNode>.class);
        System.assert(files.size() == 0, 'Expecting 0 assuming upload test is already done and OT folder (workspace) is being reset');        
    }
    
    private static testMethod void testBrowseSuccess() {
        /* test data creation. */
        String parent = '5000l000000vGoqAAE';
        
        /* actual method invocation. */
        User user = [SELECT Id, username, lastname, isActive FROM User WHERE email = 'paymentStatusControllerTestUser@testing.don' LIMIT 1];
        system.debug('User : ' + user);
        System.runAs(user)  {
            String openTextDocuments = P2POTAttachmentController.browse(parent);
            List<OTNode> files = (List<OTNode>) JSON.deserialize(openTextDocuments, List<OTNode>.class);
            System.assert(files.size() == 0, 'Expecting 0 assuming upload test is already done and OT folder (workspace) is being reset');           
        }
    }
    
    private static testMethod void testForUserType(){
        System.Test.startTest();
        String userType = P2POTAttachmentController.getUserType();
        System.Test.stopTest();
        System.assert(userType == UserInfo.getUserType());
    }
    
    private static testMethod void testForAttachmentCount(){
        System.Test.startTest();
        Integer attachCount = P2POTAttachmentController.getMaxAttachmentCount('');
        System.Test.stopTest();
        
        System.assertEquals(0, attachCount);
    }
    
    private static testMethod void testUploadFromPage(){
        
        Case tempCase = [SELECT Id FROM Case];
        
        Test.startTest();
        PageReference pageRef = Page.P2POTAttachmentPage;
        Test.setCurrentPageReference(pageRef); 
        pageRef.getParameters().put('section', 'Test Section');
        pageRef.getParameters().put('category', 'Test Category');
        pageRef.getParameters().put('type', 'Test Type');
        pageRef.getParameters().put('identifier', 'Test Identifier');
        pageRef.getParameters().put('parent', tempCase.Id);

        P2POTAttachmentController attCon = new P2POTAttachmentController();
        attCon.getAttachment();
        attCon.attachment.Name = 'TestFile.pdf';
        attCon.uploadFromPage();
        attCon.attachment.Body = Blob.valueOf('Test Content');
        attCon.uploadFromPage();
        attCon.getShow();
        attCon.getSuccess();
        attCon.getMessage();
        

        // Negative .exe testing
        P2POTAttachmentController attConValidateExe = new P2POTAttachmentController();
        attConValidateExe.getAttachment();
        attConValidateExe.attachment.Name = 'TestFile.EXE';
        attConValidateExe.uploadFromPage();
        attConValidateExe.attachment.Body = Blob.valueOf('Test Content');
        attConValidateExe.uploadFromPage();
        attConValidateExe.getShow();
        attConValidateExe.getSuccess();
        attConValidateExe.getMessage();

        // Empty attachment uplaod testing
        P2POTAttachmentController attConEmptyAttachment = new P2POTAttachmentController();
        attConEmptyAttachment.getAttachment();
        attConEmptyAttachment.attachment.Name = Null;
        attConEmptyAttachment.uploadFromPage();
        attConEmptyAttachment.attachment.Body = Null;
        attConEmptyAttachment.uploadFromPage();
        attConEmptyAttachment.getShow();
        attConEmptyAttachment.getSuccess();
        attConEmptyAttachment.getMessage();

        // Validate delete attachment

        /*P2POTAttachmentController attConDel = new P2POTAttachmentController();
        attConDel.getAttachment();
        attConDel.attachment.Name = 'TestFile.pdf';
        attConDel.uploadFromPage();
        attConDel.attachment.Body = Blob.valueOf('Test Content test attachment');
        attConDel.uploadFromPage();
        attConDel.getShow();
        attConDel.getSuccess();
        attConDel.getMessage();
        
        P2POTAttachmentController.deleteAttachments (attConDel.attachment.ID);*/

        Test.stopTest();
        System.assertNotEquals(NULL, attCon.attachId);
        System.assertEquals(NULL, attConValidateExe.attachId);
        System.assertEquals(NULL, attConEmptyAttachment.attachId);
      
    }
}