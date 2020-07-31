@isTest
public class PSP2ASPTransformerTest {

    @testSetup 
    static void setup() {
     
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerID=ownerid);
        insert account;
        
        Contact contact = new Contact(Title='Mr.',LastName ='testCon',AccountId = account.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert contact;
    }
    
    @isTest
    private static void testASPTranformation() {
     
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id pspProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.PSP_PROFILE_NAME LIMIT 1].Id;
        Id aspProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.ASP_PROFILE_NAME LIMIT 1].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = pspProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        Test.startTest();
        Set<Id> inputUserContacts = new Set<Id>();
        inputUserContacts.add(contactId);
        PSP2ASPTransformer.transform(inputUserContacts);
        Test.stopTest();
        
        user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
        System.assertEquals(user.ProfileId, aspProfileId);
    }
    
    @isTest
    private static void testTaxiAndASPTranformation() {
     
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiAndAccountManagerProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME LIMIT 1].Id;
        Id taxiAndAspProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.Taxi_ASP_PROFILE_NAME LIMIT 1].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiAndAccountManagerProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        Test.startTest();
        Set<Id> inputUserContacts = new Set<Id>();
        inputUserContacts.add(contactId);
        PSP2ASPTransformer.transform(inputUserContacts);
        PSP2AccountManagerTransformer.transform(inputUserContacts);
        Test.stopTest();
        
        user = [SELECT ProfileId FROM User WHERE Id = :user.Id];
        System.assertEquals(user.ProfileId, taxiAndAspProfileId);
    }
}