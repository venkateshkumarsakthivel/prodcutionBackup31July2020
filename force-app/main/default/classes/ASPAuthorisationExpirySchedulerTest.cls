@isTest
private class ASPAuthorisationExpirySchedulerTest {
    
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
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = ac.Id);
        insert authRec;
        date authEndDate = System.today().addDays(7);
        
        authRec.End_Date__c = authEndDate ;
        update authRec;
        
       Authorisation__c authRec1 = new Authorisation__c(Authorisation_Type__c = 'TSP', Status__c = 'Granted Conditionally', Service_Provider__c = ac.Id);
        insert authRec1;
      
    }
    
    @isTest
    public static void testBatchSchedule(){
        
        Test.StartTest();
        ASPAuthorisationExpiryScheduler expiryScheduler = new ASPAuthorisationExpiryScheduler();
        System.debug('output is '+expiryScheduler);
        expiryScheduler.execute(null);
        Test.StopTest();
       Case newCaseRec = [select Id from Case ];
        System.debug('new case record is '+ newCaseRec);
        System.assertNotEquals(NULL,newCaseRec);
        
      
    }
}