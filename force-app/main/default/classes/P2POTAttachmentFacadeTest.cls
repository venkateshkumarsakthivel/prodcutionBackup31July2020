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
private class P2POTAttachmentFacadeTest {

    private static testMethod void testUploadSuccess() {
    		/* test data creation. */
    		String parent = '5000l000000vGoqAAE';
    		String name = 'P2POTAttachmentFacadeTest_upload.txt';
    		String contents = EncodingUtil.base64Encode(Blob.valueOf('upload is being tested using test case class, these contents will be help in the file named : P2POTAttachmentFacadeTest_upload.txt'));
    		String ctype = 'text/plain';
    		
    		/* actual method invocation. */
    		P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
    		Boolean response = p2POTAttachmentFacade.upload(parent, name, contents, ctype);
    		System.assert(response == true, ' Actual response ' + response);
    }
    
    private static testMethod void testuploadFromTriggerSuccess() {
    		/* test data creation. */
    		String parent = '5000l000000vGoqAAE';
    		String name = 'P2POTAttachmentFacadeTest_upload.txt';
    		String contents = EncodingUtil.base64Encode(Blob.valueOf('upload is being tested using test case class, these contents will be help in the file named : P2POTAttachmentFacadeTest_upload.txt'));
    		String ctype = 'text/plain';
    		
    		/* actual method invocation. */
    		P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
    		Boolean response = p2POTAttachmentFacade.uploadFromTrigger(parent, name, contents, ctype, 'Case');
    		System.assert(response == true, ' Actual response ' + response);
    }
    
    private static testMethod void testBrowseSuccess() {
    		/* test data creation. */
    		String parent = '5000l000000vGoqAAE';
    		
    		/* actual method invocation. */
    		P2POTAttachmentFacade p2POTAttachmentFacade = new P2POTAttachmentFacade();
    		List<OTNode> openTextDocuments = p2POTAttachmentFacade.browse(parent);
    		System.assert(openTextDocuments.size() == 0, 'Expecting 6 assuming upload test is already done and OT folder (workspace) is being reset');        
    }
}