@isTest
private class ScheduleBatchAuthorisationStatusTest {
    
    @testSetup 
    static void setupTestData(){
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
        
        Case newASPCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        
        insert newASPCase;

        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = ac.Id, Application__c = newASPCase.Id);
        insert authRec;
        
        newASPCase.Sub_Status__c = 'Withdrawn';
        update newASPCase;
    }
    
    @isTest
    public static void testBatchSchedule(){
        
        Test.StartTest();
        ScheduleBatchAuthorisationStatusUpdator batchUpdator = new ScheduleBatchAuthorisationStatusUpdator();
        System.schedule('Update Authorisations Test', '0 0 * * * ?', batchUpdator);
        Test.StopTest();
        
        Authorisation__c authRec = [SELECT Id, Status__c, Application__r.Sub_Status__c, Application__c, Application__r.Decision_Made_By__c FROM Authorisation__c];
        System.assertNotEquals(NULL, authRec);
    }
}