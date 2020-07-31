@isTest
public class TaxiRenewalApplicationControllerTest {

    @testSetup 
    static void setup() {
     
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.', LastName ='testCon', AccountId = ac.Id, Birthdate = Date.parse('01/01/1992'), Email='test@contest.com', FirstName = 'Name');
        insert con;
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
    }
    
    @isTest
    private static void retrieveApplicationDetailsTest() {
      
        Case taxiExistingCase = [SELECT Id FROM Case];  
        Test.startTest();
        System.assertNotEquals(NULL, TaxiRenewalApplicationController.retrieveApplicationDetails(taxiExistingCase.Id));
        Test.stopTest();
    }
    
    @isTest
    private static void getEntityTypeTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME LIMIT 1].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        Case taxiExistingCase = [SELECT Id FROM Case];  
        System.runAs(user) {
        
            Test.startTest();
            System.assertNotEquals(NULL, TaxiRenewalApplicationController.getEntityType(taxiExistingCase.Id));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void saveApplicationTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME LIMIT 1].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        Case taxiExistingCase = [SELECT Id FROM Case];  
        System.runAs(user) {
             
            Test.startTest();
            taxiExistingCase.Status = 'Lodged';
            TaxiRenewalApplicationController.saveApplication(taxiExistingCase);
            Test.stopTest();
        }
        taxiExistingCase = [SELECT Id, Status FROM Case];  
        System.assertEquals('Lodged', taxiExistingCase.Status);
    }
}