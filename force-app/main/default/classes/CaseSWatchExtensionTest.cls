@isTest
public class CaseSWatchExtensionTest {
    
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
    private static void resumeClockTest(){
        
        Case c1 = [SELECT Id FROM Case];
        
        PageReference pageRef = Page.StopwatchForCase;
        Test.startTest();
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(c1.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(c1);
        CaseSWatchExtension caseWatchExt = new CaseSWatchExtension(sc);
        caseWatchExt.pauseClock();
        caseWatchExt.resumeClock();
        Test.stopTest();
        
        c1 = [SELECT isPaused__c FROM Case WHERE Id =:c1.Id];
        System.assertEquals(FALSE, c1.isPaused__c);
    }
    
    @isTest
    private static void pauseClockTest(){
        
        Case c1 = [SELECT Id FROM Case];
        
        PageReference pageRef = Page.StopwatchForCase;
        Test.startTest();
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(c1.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(c1);
        CaseSWatchExtension caseWatchExt = new CaseSWatchExtension(sc);
        caseWatchExt.pauseClock();
        Test.stopTest();
        
        c1 = [SELECT isPaused__c FROM Case WHERE Id =:c1.Id];
        System.assertEquals(TRUE, c1.isPaused__c);
    }
}