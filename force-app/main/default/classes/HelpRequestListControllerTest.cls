@isTest
public class HelpRequestListControllerTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    
    @isTest
    private static void getAllHelpRequestsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
                
        List<Case> listCases = new List<Case>();
        Id rtIdforHelpRequest = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Help Request').getRecordTypeId();
                
        Test.startTest();
        System.runAs(user) {
            List<Case> caseList = new List<Case>();
            for(Integer i = 0; i < 5; i++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforHelpRequest);
                caseList.add(c);
            }
            
            insert caseList;
            listCases = HelpRequestListController.getAllHelpRequests();
        }
        Test.stopTest();
        
        System.assertEquals(5, listCases.size());
    }
    
    
    
     @isTest
    private static void submitHelpRequestTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        String str;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Case caseRec = new case();
        caseRec.AccountId = accountId;
        caseRec.Subject = 'New Case';
        caseRec.Description = 'Help Request to submit';
        caseRec.Type = 'Feedback';
        
        test.startTest();
        system.runAs(user){                    
            str = HelpRequestListController.submitHelpRequest(caseRec.Subject, caseRec.Description, caseRec.Type);
        }
        test.stopTest();
        Case caseRecdetails = [SELECT Id, CaseNumber, subject, description from Case where AccountId =:accountId];
        system.assertEquals(caseRecdetails.caseNumber + ' - ' + caseRecdetails.subject + ' - ' + caseRecdetails.description, str);
        
    }
    
}