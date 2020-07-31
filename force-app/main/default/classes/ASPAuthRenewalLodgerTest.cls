@isTest
public class ASPAuthRenewalLodgerTest {

    @testSetup 
    static void setup(){
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
    }
    
    @isTest
    private static void deleteDraftAuthNotSelectedForRenewalTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        test.startTest();
        Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
        insert c;
        
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
        insert auth;
        
        
        Authorisation__c auth1 = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-09'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 200, Contact__c = conId, Application__c = c.Id);
        insert auth1;
        
        ASPAuthRenewalLodger.deleteDraftAuthNotSelectedForRenewal(c);
        test.stopTest();   
    }
}