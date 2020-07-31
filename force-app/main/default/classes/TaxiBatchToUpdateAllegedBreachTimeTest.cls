@isTest
public class TaxiBatchToUpdateAllegedBreachTimeTest {
    
    @testSetup
    private static void setupTestData() {
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert acc;
        
        Contact con = new Contact(Title='Mr.', LastName ='testCon', AccountId = acc.Id, Birthdate = Date.parse('01/01/1992'), Email='test@contest.com', FirstName = 'Name');
        insert con;
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Investigation').getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        
        /*CollaborationGroup collaborationGroupRecord = new CollaborationGroup(Name = 'InvestigationTeam', CollaborationType = 'Public', CanHaveGuests = false, IsArchived = false, IsAutoArchiveDisabled = true);
    	insert collaborationGroupRecord;*/

    }
    
    @isTest
    private static void startTest() { 
        List<Case> targetAccounts = [SELECT Id, CaseNumber FROM Case];
        targetAccounts[0].Date_of_alleged_breach__c = System.Today().addDays(-1);
        update targetAccounts;
        
        Test.startTest();
        TaxiBatchToUpdateAllegedBreachTime newBatch = new TaxiBatchToUpdateAllegedBreachTime();
        Database.executeBatch(newBatch);
        
        Test.stopTest();
    }

}