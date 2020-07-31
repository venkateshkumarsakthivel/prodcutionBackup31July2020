@isTest
public class AddContactControllerTest {
    @testSetup 
    static void SupportRequestControllerUtil(){
        try{
            Id ownerid = GlobalUtility.getOwnerId();
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'SupportRequestControllerTest','ASPApplicationListControllerTest',ex.getMessage(),ex);
        }   
    }
    
    
    @isTest
    public static void submitSupportRequestTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id sapRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Id p = GlobalUtility.getASPProfile().id;
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            test.startTest();
            system.runAs(user){
                
                Case caseRec = new case();
                caseRec.Subject = 'Case Subject';
                caseRec.RecordTypeId = sapRecordTypeId;
                caseRec.ContactId = conId;
                caseRec.AccountId = accountId;
                
                Related_Contact__c rc = new Related_Contact__c();
                rc.Name = 'Sample name 1';
                rc.Title__c = 'Mr.';
                rc.Family_Name__c = 'sample';
                rc.First_Given_Name__c = 'name';
                
                //------addded attachment 
                Attachment attach=new Attachment(); 
                attach.Name='Test Attachment'; 
                Blob bodyBlob=Blob.valueOf('Test Attachment Body'); 
                attach.body=bodyBlob; 
                attach.ParentId=conId;
                attach.Description ='unit testing';
                
                insert attach;        
                system.debug('attachments is' + attach);
                String str = AddContactController.submitSupportRequest(caseRec,rc,'TEST');
                system.debug('String '+ str);
            }
            
            test.stopTest();
            List<Case> cases=[SELECT Id FROM Case LIMIT 1];
            system.assertEquals(1, cases.size());
            
            
        }
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'SupportRequestControllerTest','submitSupportRequestTest',ex.getMessage(),ex);
        }
    }
}