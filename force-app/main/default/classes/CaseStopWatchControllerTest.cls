@isTest
public class CaseStopWatchControllerTest {
    
    @testSetup  
    static void TestSetup() {
        
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        
        Id rtIdforSPA = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Case c1 = new Case(Family_name__c = 'Family Name 1',Birthdate__c= Date.parse('01/01/1985'),Contact_Type__c = 'Nominated Director/Manager',
                               Email__c='Test@test.com',First_given_name__c='First Name 1',Residential_Address_City__c='Test City',
                               Residential_Address_Country__c='Test Country',Residential_Address_State__c='Test state',Residential_Address_Street__c='Test street',
                               Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = ac.Id, Service_Type__c = 'Taxi', Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                               Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                               Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = rtIdforSPA);
        
        insert c1;
    }
    
    @isTest
    private static void detailsTest(){
        
        Case tempCase = [SELECT Id FROM Case];
        Test.startTest();
        System.assertNotEquals(NULL, CaseStopWatchController.details(tempCase.Id));
        Test.stopTest();
    }
    
    @isTest
    private static void CSWpauseTest(){
        
        Case tempCase = [SELECT Id FROM Case];
        Test.startTest();
        System.assertNotEquals(NULL, CaseStopWatchController.CSWpause(tempCase.Id));
        Test.stopTest();
    }
    
    @isTest
    private static void CSWresumeTest(){
        
        Case tempCase = [SELECT Id FROM Case];
        Test.startTest();
        CaseStopWatchController.CSWpause(tempCase.Id);
        System.assertNotEquals(NULL, CaseStopWatchController.CSWresume(tempCase.Id));
        Test.stopTest();
    }
}