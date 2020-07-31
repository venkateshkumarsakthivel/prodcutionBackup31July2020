@isTest
public class BatchToIdentifyExpiryingAgreementsTest {
    
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
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        
        Id taxiAuthRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Authorisation__c authRecord = new Authorisation__c(Plate_Number__c = '11111', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord.Application__c = newTaxiCase.Id;
        insert authRecord;
        
        
        Authorisation_Agent__c authorisationAgentRecord = new Authorisation_Agent__c(Expiry_Date__c = System.Today(), Status__c = 'Active', Account__c  = acc.Id, Authorisation__c  = authRecord.Id);
        insert authorisationAgentRecord;
    }
    
    @isTest
    private static void startTest() { 
        List<Authorisation_Agent__c> authorisationAgentList = [SELECT Id, Name, Status__c, Expiry_Date__c, Days_to_Expire__c, Authorisation__r.Service_Provider__c FROM Authorisation_Agent__c];
        List<Account> targetAccounts = [SELECT Id, Name, Notice_Email__c, No_of_Licences_Managed__c FROM Account];
        
        String query ;
        query = 'SELECT Id, Name, Notice_Email__c, No_of_Licences_Managed__c FROM Account WHERE No_of_Licences_Managed__c > 0';
        
        Test.startTest();
        BatchToIdentifyExpiryingAgreements newBatch = new BatchToIdentifyExpiryingAgreements(query, 0);
        Database.executeBatch(newBatch);
        Test.stopTest();
    }

}