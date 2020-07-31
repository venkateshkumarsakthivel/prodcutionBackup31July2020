@isTest
public class GrantedASPAuthorisationsTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000') ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        
    }
    @isTest
    private static void getGrantedASPAuthorisations(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        List<Authorisation__c> newAuths = new List<Authorisation__c>();
        Authorisation__c authRec1 = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        Authorisation__c authRec2 = new Authorisation__c(Authorisation_Type__c = 'TSP', Status__c = 'Granted Unconditionally', Service_Provider__c = accountId);
        Authorisation__c authRec3 = new Authorisation__c(Authorisation_Type__c = 'TSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        
        Case tempCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'New');
        insert tempCase;
        
        newAuths.add(authRec1);
        newAuths.add(authRec2);
        newAuths.add(authRec3);
        insert newAuths;
        
        test.startTest();
        List<Authorisation__c> testAuth = GrantedASPAuthorisations.getAuthorisations(tempCase.Id);
        System.assertEquals('BSP', testAuth[0].Authorisation_Type__c);
        System.assertEquals('TSP', testAuth[1].Authorisation_Type__c);
        System.assertEquals('TSP', testAuth[2].Authorisation_Type__c);
        System.assertEquals(newAuths.size(),testAuth.size());
        test.stopTest();        
    }
}