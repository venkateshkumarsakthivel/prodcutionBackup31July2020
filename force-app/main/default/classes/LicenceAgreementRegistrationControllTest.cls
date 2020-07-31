// this class is used as LicenceAgreementRegistrationController's test class 
@isTest
public class LicenceAgreementRegistrationControllTest {
    
    @testSetup
    private static void setupTestData() {
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert acc;
        Account acc2 = new Account(ACN__c = '1234567888',ABN__c = '123456788', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert acc2;
        
        Contact con = new Contact(Title='Mr.', LastName ='testCon', AccountId = acc.Id, Birthdate = Date.parse('01/01/1992'), Email='test@contest.com', FirstName = 'Name');
        insert con;
        Contact con2 = new Contact(Title='Mr.', LastName ='testCon', AccountId = acc2.Id, Birthdate = Date.parse('01/01/1992'), Email='test@contest.com', FirstName = 'Name');
        insert con2;
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        Case newTaxiCase2 = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc2.ACN__c, Corporation_name__c = acc2.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc2.Id);
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
        Authorisation__c authRecord3 = new Authorisation__c(Plate_Number__c = '33333', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc2.Id);
        authRecord3.Application__c = newTaxiCase2.Id;
        authList.add(authRecord3);
        Authorisation__c authRecord4 = new Authorisation__c(Plate_Number__c = '33333', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc2.Id);
        authRecord4.Application__c = newTaxiCase2.Id;
        authList.add(authRecord4);
        Authorisation__c authRecord5 = new Authorisation__c(Plate_Number__c = '44444', Authorisation_Type__c = 'Taxi Licence', Status__c = 'NEW', Service_Provider__c = acc.Id);
        authRecord5.Application__c = newTaxiCase.Id;
        authList.add(authRecord5);
        Authorisation__c authRecord6 = new Authorisation__c(Plate_Number__c = '66666', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc2.Id);
        authRecord6.Application__c = newTaxiCase.Id;
        authList.add(authRecord6);
        Authorisation__c authRecord7 = new Authorisation__c(Plate_Number__c = '77777', Authorisation_Type__c = 'Taxi Licence', Status__c = 'New', Service_Provider__c = acc.Id);
        authRecord7.Application__c = newTaxiCase.Id;
        authList.add(authRecord7);
        Authorisation__c authRecord8 = new Authorisation__c(Plate_Number__c = '77777', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord8.Application__c = newTaxiCase.Id;
        authList.add(authRecord8);
        
        insert authList;
        
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
            if(auth.Plate_Number__c == '33333') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '33333', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
            if(auth.Plate_Number__c == '44444') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '44444', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
            if(auth.Plate_Number__c == '66666') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '66666', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
            if(auth.Plate_Number__c == '77777') {
                relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '77777', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId =  indivRecordTypeId, Related_Application__c = newTaxiCase.Id);
        		relatedContactList.add(relatedContact);
            }
        }
        insert relatedContactList;
    }
    
    //for saveRelatedContacts method, for normal process to upsert data without account
    @isTest
    private static void saveRelatedContactsTest() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111')];
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for normal process to upsert data with account
    @isTest
    private static void saveRelatedContactsTest1() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111')];
        String accountId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, accountId);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for duplicate entries
    @isTest
    private static void saveRelatedContactsTest2() {
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        Related_Contact__c relatedCon = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111') LIMIT 1];
        relatedContactList.add(relatedCon);
        relatedContactList.add(relatedCon);
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for invalid plate number
    @isTest
    private static void saveRelatedContactsTest3() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111','22222')];
        for(Related_Contact__c relCon : relatedContactList) {
            relCon.Plate_Number__c = '99999';
        }
        update relatedContactList;
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for different account
    @isTest
    private static void saveRelatedContactsTest4() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Authorisation__c> authorisationList1 = [SELECT Id, Name, Plate_Number__c, Service_Provider__c FROM Authorisation__c WHERE Plate_Number__c = '11111' LIMIT 1];
        List<Related_Contact__c> relatedContactList1 = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c = '11111' LIMIT 1];
        relatedContactList1[0].Taxi_Licence__c = authorisationList1[0].Name;
        relatedContactList1[0].Plate_Number__c = authorisationList1[0].Plate_Number__c;
        update relatedContactList1;
        List<Authorisation__c> authorisationList2 = [SELECT Id, Name, Plate_Number__c, Service_Provider__c FROM Authorisation__c WHERE Service_Provider__c !=: authorisationList1[0].Service_Provider__c LIMIT 1];
        List<Related_Contact__c> relatedContactList2 = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c =: authorisationList2[0].Plate_Number__c LIMIT 1];
        relatedContactList2[0].Taxi_Licence__c = authorisationList2[0].Name;
        relatedContactList2[0].Plate_Number__c = authorisationList2[0].Plate_Number__c;
        update relatedContactList2;
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        relatedContactList.addAll(relatedContactList1);
        relatedContactList.addAll(relatedContactList2);
                
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for multiple autorisation record with different status
    @isTest
    private static void saveRelatedContactsTest5() {
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Authorisation__c> authorisationList = [SELECT Id, Name, Plate_Number__c, Service_Provider__c FROM Authorisation__c WHERE Plate_Number__c = '77777'];
        authorisationList[1].Name = authorisationList[0].Name;
        update authorisationList;
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('77777')];
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for inavlid taxi licence
    @isTest
    private static void saveRelatedContactsTest6() {
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        List<Related_Contact__c> relatedConList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111','22222')];
        RelatedConList[0].Taxi_Licence__c = '99999';
        update RelatedConList[0];
        relatedContactList.add(relatedConList[0]);
        relatedContactList.add(relatedConList[1]);
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for not matching any authorisation record
    @isTest
    private static void saveRelatedContactsTest7() {
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        Related_Contact__c relatedCon = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111') LIMIT 1];
        relatedCon.Taxi_Licence__c = '99999';
        relatedCon.Plate_Number__c = '99999';
        update relatedCon;
        relatedContactList.add(relatedCon);
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for not granted status
    @isTest
    private static void saveRelatedContactsTest8() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Authorisation__c> authorisationList = [SELECT Id, Name, Plate_Number__c FROM Authorisation__c WHERE Plate_Number__c = '44444' LIMIT 1];
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c = '44444' LIMIT 1];
        relatedContactList[0].Taxi_Licence__c = authorisationList[0].Name;
        relatedContactList[0].Plate_Number__c = authorisationList[0].Plate_Number__c;
        update relatedContactList;
        
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
    
    //for saveRelatedContacts method, for all entries both taxi licences and plate numbers are blank
    @isTest
    private static void saveRelatedContactsTest9() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Related_Contact__c> relatedContactList = [SELECT Id, Taxi_Licence__c, Plate_Number__c FROM Related_Contact__c WHERE Plate_Number__c IN ('11111','22222')];
        for(Related_Contact__c relCon : relatedContactList) {
            relCon.Taxi_Licence__c = '';
            relCon.Plate_Number__c = '';
        }
        update relatedContactList;
        Test.startTest();
        LicenceAgreementRegistrationController.saveRelatedContacts(relatedContactList, caseId, null);
        Test.stopTest();
    }
        
    //for fetchRelatedContactRecords method
    @isTest
    private static void fetchRelatedContactRecordsTest() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        
        Test.startTest();
        LicenceAgreementRegistrationController.fetchRelatedContactRecords(caseId);
        Test.stopTest();
    }
    
    //for updateCase method
    @isTest
    private static void updateCaseTest() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        
        Test.startTest();
        LicenceAgreementRegistrationController.updateCase(caseId);
        Test.stopTest();
    }
    
    //for deleteRelatedContactRecord method
    @isTest
    private static void deleteRelatedContactRecordTest() {
        Related_Contact__c relatedContact = [SELECT Id FROM Related_Contact__c LIMIT 1];
        
        Test.startTest();
        LicenceAgreementRegistrationController.deleteRelatedContactRecord(relatedContact);
        Test.stopTest();
    }
    
}