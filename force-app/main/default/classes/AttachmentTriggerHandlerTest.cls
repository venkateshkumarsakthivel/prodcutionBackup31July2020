@isTest
public class AttachmentTriggerHandlerTest {
    
    //method to setup success and error scenario users
    @testSetup
    private static void initialize() {
        
        Profile successUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'P2P Operations Level 3'];
        Profile failureUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'P2P Operations Level 2'];
        
        User successUser = new User(alias = 'test123', email='test123@noemail.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = successUserProfile.Id, country='United States', IsActive =true,
                                    timezonesidkey='America/Los_Angeles', username='tester12@noemail.com');
        
        insert successUser;
        
        User failureUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = failureUserProfile.Id, country='United States', IsActive =true,
                                    timezonesidkey='America/Los_Angeles', username='tester4@noemail.com');
        
        insert failureUser;
    }
    
    //method to test success in deletion of attachments by a valid profile
    static testMethod void deletionSuccess() {
        
        User successUser = [SELECt Id, ProfileId FROM User WHERE Username = 'tester12@noemail.com'];
        
        System.runAs(successUser) {  
            
            Account tempAcc = new Account(Name = 'Test Success Account');
            insert tempAcc;
            
            Attachment tempAtt = new Attachment();
            tempAtt.ParentId = tempAcc.Id;
            tempAtt.Body = Blob.valueOf('Unit Test Attachment Body');
            tempAtt.Name = 'Unit Test Attachment';
            insert tempAtt;
            
            Test.startTest();
            Database.DeleteResult result = Database.delete(tempAtt, false);
            Test.stopTest();
            
            System.assertEquals(true, result.isSuccess());
        }
    }
    
    //method to test failure in deletion of attachments by a invalid profile
    static testMethod void deletionFailure() {
        
        User failureUser = [SELECt Id, ProfileId FROM User WHERE Username = 'tester4@noemail.com'];
        
        System.runAs(failureUser) {  
            
            Account tempAcc = new Account(Name = 'Test Success Account');
            insert tempAcc;
            
            Attachment tempAtt = new Attachment();
            tempAtt.ParentId = tempAcc.Id;
            tempAtt.Body = Blob.valueOf('Unit Test Attachment Body');
            tempAtt.Name = 'Unit Test Attachment';
            insert tempAtt;
            
            Test.startTest();
            Database.DeleteResult result = Database.delete(tempAtt, false);
            Test.stopTest();
            
            System.assertEquals(false, result.isSuccess());
            System.assertEquals('You do not have permission to delete attachments. Please contact System Administrator for more information.', result.getErrors()[0].getMessage());
        }
    }
}