@isTest
private class LicenceExpirationProcessTest {
    @testSetup 
    static void testSetup(){
        Account ac = new Account(name ='testAcc',Notice_Email__c = 'test@sample.com', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    // test for getLoggedInUserAccount
    @isTest
    private static void createCaseFalseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforTaxiAdministrator = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        List<Authorisation__c> AuthList = new List<Authorisation__c>();
        List<Id> AuthIdsList = new List<Id>();
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        
        Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                        End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
        
        AuthList.add(authRec);
        insert AuthList;
        AuthIdsList.add(authRec.Id);
        test.startTest();
        LicenceExpirationProcess.createCase(AuthIdsList); 
        
        List<Case> caseRecs = [Select Id FROM Case WHERE RecordTypeId =: rtIdforTaxiAdministrator AND Authorisation__c =: authRec.Id];
        system.assert(caseRecs.size() >0);
        test.stopTest();
        
    }
}