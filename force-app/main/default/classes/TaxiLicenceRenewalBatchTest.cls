@IsTest
private with sharing class TaxiLicenceRenewalBatchTest {
    private static final Decimal BASE_PRICE = 120000;
    private static final Decimal APPLICATION_FEE = 200;
    
    private static testMethod void testForLicenceRenewal(){
        System.Test.startTest();
        Database.executeBatch(new TaxiLicenceRenewalBatch());
        System.Test.stopTest();
        List<Authorisation__c> licences = [SELECT Id FROM Authorisation__c WHERE Renewal_Requested__c = true];
        //System.assert(!licences.isEmpty());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Authorisation__c auth = createLicence(act.Id);
        createPricebook();
    }
    
    private static Account createAccount(){
        Account act = new Account();
        act.Name = 'Test Account';
        act.Email__c = 'test@example.com';
        act.Notice_Email__c = 'test@example.com';
        act.Notice_Address_City__c = 'Sydney';
        act.Notice_Address_Country__c = 'Australia';
        act.Notice_Address_Postal_Code__c = '2000';
        act.Notice_Address_State__c = 'NSW';
        act.Notice_Address_Street__c = '333 George Street';
        act.ACN__c = '000000019';
        act.ABN__c = '89000000019';
        
        insert act;
        return act;        
    }
    
    private static Authorisation__c createLicence(Id actId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addDays(1);
        auth.Start_Date__c = System.today().addYears(-1);
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        auth.Licence_Class__c = 'TX03';
        auth.Licence_Fee__c = BASE_PRICE;
        auth.Licence_Type__c = GlobalConstants.LICENCE_TYPE_ANNUAL;
        auth.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
        
        insert auth;
        return auth;
    }
    
    private static void createPricebook(){
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - TX03', Family = 'Taxi Licence'));
        products.add(new Product2(Name = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - TX12 Annual', Family = 'Taxi Licence'));
        products.add(new Product2(Name = GlobalConstants.ANNUAL_TAXI_LICENCE_PRODUCT_NAME, Family = 'Taxi Licence'));
        insert products;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        List<PriceBookEntry> stdPbEntries = new List<PriceBookEntry>();
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[0].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[1].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[2].Id,UnitPrice = 0, IsActive = true));
        
        insert stdPbEntries;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name= Label.ASP_Pricebook, isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[0].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[1].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[2].Id,UnitPrice = 0, IsActive = true));
        
        insert pbEntries;        
    }
}