// this class is used as TaxiLicenceAgreementRevokeController's test class 
@isTest
public class TaxiLicenceAgreementRevokeControllerTest {
    
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
        
        Case newTaxiCase2 = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase2.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase2;
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
        Id taxiAuthRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Authorisation__c authRecord = new Authorisation__c(Plate_Number__c = '11111', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord.Application__c = newTaxiCase.Id;
        authList.add(authRecord);
        Authorisation__c authRecord2 = new Authorisation__c(Plate_Number__c = '22222', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord2.Application__c = newTaxiCase.Id;
        authList.add(authRecord2);
        
        insert authList;
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c = authList[0].Id, Account__c = acc.Id, Status__c = 'Active');
        insert authAgent;
        
        Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        
        List<Authorisation__c> authorisationList = [SELECT Id, Name, Plate_Number__c FROM Authorisation__c];
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        Related_Contact__c relatedContact = new Related_Contact__c();
        for(Authorisation__c auth : authorisationList) {
            if(auth.Plate_Number__c == '11111') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '11111', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
            if(auth.Plate_Number__c == '22222') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '22222', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
        }
        insert relatedContactList;
    }
    
    //for fetchServiceProviderList method
    @isTest
    private static void fetchServiceProviderListTest() {
        String accountId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.fetchServiceProviderList(accountId, accountId);
        Test.stopTest();
    }
    
    //for fetchAuthorisationAgentList method
    @isTest
    private static void fetchAuthorisationAgentListTest() {
        String accountId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.fetchAuthorisationAgentList(accountId, accountId);
        Test.stopTest();
    }
    
    //for validatiedForCaseNumber method
    @isTest
    private static void validatiedForCaseNumberTest() {
        String CaseNumberStr = [SELECT Id, CaseNumber FROM Case LIMIT 1].CaseNumber;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.validatiedForCaseNumber(CaseNumberStr);
        Test.stopTest();
    }
    
    //for validatiedForCaseNumber method
    @isTest
    private static void validatiedForCaseNumberTest2() {
        String CaseNumberStr = [SELECT Id, CaseNumber FROM Case LIMIT 1].CaseNumber;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.validatiedForCaseNumber(CaseNumberStr + '123');
        Test.stopTest();
    }
    
    //for upsertCase method
    @isTest
    private static void upsertCaseTest() {
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case];
        List<Authorisation_Agent__c> authorisationAgentList = new List<Authorisation_Agent__c>();
        String accountId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.upsertCase(authorisationAgentList, caseList[0].Id, caseList[1].Id, accountId, accountId);
        Test.stopTest();
    }
    
    //for upsertRelatedContacts method
    @isTest
    private static void upsertRelatedContactsTest() {
        List<Case> caseList= [SELECT Id, CaseNumber, Authorisation_Account_Name__c  FROM Case LIMIT 1];
        List<Authorisation_Agent__c> authorisationAgentList = [SELECT Id, isSelectedForRevokeAgreement__c, Authorisation__c, Authorisation__r.Name, 
                                                               Authorisation__r.Plate_Number__c, Authorisation__r.Service_Provider__r.Name  
                                                               FROM Authorisation_Agent__c];
        authorisationAgentList[0].isSelectedForRevokeAgreement__c = true;
        update authorisationAgentList;
        caseList[0].Authorisation_Account_Name__c = authorisationAgentList[0].Authorisation__r.Service_Provider__r.Name;
        update caseList;
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.upsertRelatedContacts(authorisationAgentList, caseList[0].Id);
        Test.stopTest();
    }
    
    //for updateCase method
    @isTest
    private static void updateCaseTest() {
        List<Case> caseList= [SELECT Id, CaseNumber FROM Case];
        
        Test.startTest();
        TaxiLicenceAgreementRevokeController.updateCase(caseList[0].Id);
        Test.stopTest();
    }

}