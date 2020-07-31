@isTest
public class ASPManageAccountPartnersControllerTest {
    @testSetup 
    static void setup(){
        Id rtIdforIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Partnership').getRecordTypeId();
        Id rtIdforCompany = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
         Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc',RecordTypeId = rtIdforIndividual, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Account ac2 = new Account(name ='testAcc2',RecordTypeId = rtIdforCompany, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac2;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac2.Id, Email='test2@contest.com');
        insert con2; 
    }
    
    @isTest
    private static void getLoggedInUserAccountTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String accName;
        Test.startTest();
        System.runAs(user) {
            accName = ASPManageAccountPartnersController.getLoggedInUserAccount();
        }
        Test.stopTest();
        System.assert(accName != null);
        
    }
    
    
    @isTest
    private static void getAccountPartnersTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Contact con = new Contact(LastName='indv part', Email='test@dev.com', Contact_Type__c = GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE, AccountId = accountId);
        Account acc = new Account(Name = 'corp part', Corporate_Partner__c = accountId);
        
        insert acc;
        insert con;
        test.startTest();
        system.runAs(user){
            String str = ASPManageAccountPartnersController.getAccountPartners();
            system.assert(str.length() > 0);
        }
        test.stopTest();
    }
}