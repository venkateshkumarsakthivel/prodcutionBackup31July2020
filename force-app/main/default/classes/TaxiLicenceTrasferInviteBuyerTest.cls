@isTest
public class TaxiLicenceTrasferInviteBuyerTest {
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
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE , Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS , Service_Provider__c = ac.Id,Agency__c=ac.Id,Agreement_Type__c=GlobalConstants.AUTHORISATION_AGENT_AGREEMENT_TYPE);
        insert authRec;
        
        Authorisation_Agent__c authAgentRec = new Authorisation_Agent__c(Account__c = ac.Id , Status__c = GlobalConstants.MASTER_CONDITION_ACTIVE , Approved_Date__c = system.today(), Authorisation__c = authRec.Id);
        insert authAgentRec;
        
        createPricebook();   
    }
    
    private static void createPricebook(){
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = Label.Taxi_Transfer_Levy_Product_Name , Family = 'Taxi Licence', IsActive = true));
        insert products;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        List<PriceBookEntry> stdPbEntries = new List<PriceBookEntry>();
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[0].Id,UnitPrice = 0, IsActive = true));
        
        insert stdPbEntries;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name= Label.ASP_Pricebook, isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[0].Id,UnitPrice = 0, IsActive = true));
        insert pbEntries;        
    }
    
    @isTest
    private static void inviteBuyerTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id authId = [SELECT Id FROM Authorisation__c].Id;
        
        test.startTest();
        
        Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Id TaxiAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Case sellerCase = new Case(AccountId = accountId, Authorisation__c = authId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                   ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = TaxiAdministrationRecordTypeId);
        insert sellerCase;
        
        Case buyerCase = new Case(AccountId = accountId, Authorisation__c = authId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                  ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = transferRecordTypeId, ParentId = sellerCase.Id,
                                  Levy_Due__c =100, Licence_Market_Value__c = 1000);
        insert buyerCase;
        
        String result = TaxiLicenceTrasferInviteBuyerController.inviteBuyer(buyerCase.Id);
        system.assertEquals('SUCCESS', result);
        test.stopTest();
    }
    
    @isTest
    private static void validateCaseDataTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id authId = [SELECT Id FROM Authorisation__c].Id;
        
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Id TaxiAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case sellerCase = new Case(AccountId = accountId, Authorisation__c = authId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = TaxiAdministrationRecordTypeId);
            insert sellerCase;
            
            Case buyerCase = new Case(AccountId = accountId, Authorisation__c = authId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                      ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = transferRecordTypeId, ParentId = sellerCase.Id
                                     );
            insert buyerCase;
            
            String result = TaxiLicenceTrasferInviteBuyerController.validateCaseData(buyerCase.Id);
            system.assertEquals('Please enter Licence Market Value and Levy Due.', result);
            
            Case updatedBuyerCase = new Case();
            updatedBuyerCase.Id = buyerCase.Id;
            updatedBuyerCase.Levy_Due__c = 100;
            updatedBuyerCase.Licence_Market_Value__c = 1000;
            upsert updatedBuyerCase;
            
            String result1 = TaxiLicenceTrasferInviteBuyerController.validateCaseData(buyerCase.Id);
            system.assertEquals('testAcc', result1);
            
        }
        test.stopTest();
    }
    
    private static testMethod void testForExceptionValidateCaseData(){
        System.Test.startTest();
        String result = TaxiLicenceTrasferInviteBuyerController.validateCaseData(null);
        System.Test.stopTest();
        System.assert(result == null);
    }
    
    private static testMethod void testForExceptionInviteBuyer(){
        System.Test.startTest();
        String result = TaxiLicenceTrasferInviteBuyerController.inviteBuyer(null);
        System.Test.stopTest();
        System.assert(result == null);
    }
    
    private static testMethod void testForMissingContactOnCase(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Case buyerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi', 
                                  Status = GlobalConstants.CASE_DRAFT,
                                  Sub_Status__c = GlobalConstants.CASE_DRAFT,
                                  Levy_Due__c = 100, Licence_Market_Value__c = 10000,
                                  Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,
                                  Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, 
                                  RecordTypeId = transferRecordTypeId);
        insert buyerCase;
        
        System.Test.startTest();
        String result = TaxiLicenceTrasferInviteBuyerController.validateCaseData(buyerCase.Id);
        System.Test.stopTest();
        System.assert(result == GlobalConstants.INVITE_BUYER_MISSING_ACT_ERR);
    }
    
}