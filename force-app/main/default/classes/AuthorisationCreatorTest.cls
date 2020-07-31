@isTest
public class AuthorisationCreatorTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
         Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        
    }
    
    
    @isTest
    public static void AuthorisationContactCreatorTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;                                                
        
        List<Case> caseList = new List<Case>();
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'New', Authorisation__c = authRec.Id);
        caseList.add(c);
                
        test.startTest();
        System.runAs(user) {
            AuthorisationCreator auth = new AuthorisationCreator(caseList);
            auth.create();            
        }
        test.stopTest();        
        
        Authorisation__c retrieveAuth = [Select Authorisation_Type__c from Authorisation__c where Service_Provider__c =: accountId];
        system.assert(retrieveAuth != null);
    }
}