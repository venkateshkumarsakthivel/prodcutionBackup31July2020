@isTest
public class FileUploadControllerTest {
    
    @testSetup 
    static void testSetup(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'FileUploadControllerTest','testSetup',ex.getMessage(),ex);
        }  
    }
    
    @isTest
    private static void attachpositiveTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            
            Id p = GlobalUtility.getASPProfile().id;
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            string str;
            test.startTest();
            System.runAs(user){
                List<Case>  caseList = new List<Case>();
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New');
                caseList.add(c);
                insert caseList;
                
                str =  FileUploadController.attach(c.id, 'test', 'Sample data', '.pdf');
                
                List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE parent.id =:caseList[0].id];
                system.assertEquals('SUCCESS',str);
            }
            test.stopTest();
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'FileUploadControllerTest','testSeattachpositiveTesttup',ex.getMessage(),ex);
        } 
        
    }
}