@IsTest
private with sharing class TransferPartyBDetailsControllerTest {

    private static testMethod void testForRetrievingApplication(){
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        System.Test.startTest();
        Case result = TransferPartyBDetailsController.retrieveApplicationDetails(caseRec.Id);
        System.Test.stopTest();
        System.assert(result != null);
        System.assert(result.Id == caseRec.Id);
    }
    
    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        Case result = TransferPartyBDetailsController.retrieveApplicationDetails(null);
        System.Test.stopTest();
        System.assert(result != null);
        System.assert(result.Id == null);
    }
    
    private static testMethod void testForEntityType(){
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        System.Test.startTest();
        String result = TransferPartyBDetailsController.getEntityType(caseRec.AccountId, caseRec.Id);
        System.Test.stopTest();
        System.assert(result != null);
    }
    
    private static testMethod void testForSaveDetails(){
        Case caseRec = [SELECT Id, Status, Subject FROM Case LIMIT 1];
        caseRec.Subject = 'Test';
        System.Test.startTest();
        Case result = TransferPartyBDetailsController.saveApplicationDetails(caseRec);
        System.Test.stopTest();
        System.assert(result.Subject == caseRec.Subject);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Authorisation__c auth = createLicence(act.Id);
        createApplication(act.Id, auth.Id);
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
    
    private static Authorisation__c createLicence(Id actId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addYears(1);
        auth.Start_Date__c = System.today();
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        auth.Licence_Class__c = 'TX08';
        auth.Licence_Type__c = GlobalConstants.LICENCE_TYPE_ANNUAL;
        auth.Licence_Fee__c = 10000;
        auth.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
        
        insert auth;
        return auth;
    }
    
    private static void createApplication(Id actId, Id licenceId){
        Case application = new Case();
        application.AccountId = actId;
        application.Authorisation__c = licenceId;
        application.Subject = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;
        application.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;               
        application.Type = GlobalConstants.TAXI_CASE_TYPE;                 
        application.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER ;
        application.Status = GlobalConstants.CASE_DRAFT;
        application.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
        insert application;
    }
}