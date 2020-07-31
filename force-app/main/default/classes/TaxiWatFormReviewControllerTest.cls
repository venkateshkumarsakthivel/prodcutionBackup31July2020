@IsTest
private with sharing class TaxiWatFormReviewControllerTest {
    
    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        String result = TaxiWatFormReviewController.lodgeWATApplication('12121');
        System.Test.stopTest();
        System.assert(result == null);
    }
    
    private static testMethod void testForLoggedInUserProfile(){
        System.Test.startTest();
        String result = TaxiWatFormReviewController.getLoggedInUserProfile();
        System.Test.stopTest();
        System.assert(result != null);
    }
    
    private static testMethod void testForWatLodgement(){
        Case app = [SELECT Id, Status, AccountId FROM Case LIMIT 1];
        System.Test.startTest();
        String result = TaxiWatFormReviewController.lodgeWATApplication(JSON.serialize(app));
        System.Test.stopTest();
        System.assert(result != null);
        List<Case> lodgedApp = [SELECT Id FROM Case 
                                WHERE Sub_Status__c = :GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING AND Id =:app.Id];
        System.assert(!lodgedApp.isEmpty());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Case app = createCase(act.Id);
        Authorisation__c auth = createAuth(act.Id, app.Id);
        
    }
    
    private static Case createCase(Id actId){
        Case app = new Case();
        app.AccountId = actId;
        app.Status = 'Draft';
        insert app;
        
        return app;
    }
    
    private static Account createAccount(){
        Account act = new Account();
        act.Name = 'Test Account';
        act.Email__c = 'test@example.com';
        act.Notice_Email__c = 'test@example.com';
        act.Notice_Address_City__c = 'Sydney';
        act.Notice_Address_Country__c = 'Australia';
        act.Notice_Address_Postal_Code__c = '2000';
        act.Notice_Address_State__c = 'NSW';
        act.Notice_Address_Street__c = '333 George Street';
        act.ACN__c = '000000019';
        act.ABN__c = '89000000019';
        
        insert act;
        return act;        
    }
    
    private static Authorisation__c createAuth(Id actId, Id caseId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addYears(1);
        auth.Start_Date__c = System.today();
        auth.Application__c = caseId;
        
        insert auth;
        return auth;
    }
}