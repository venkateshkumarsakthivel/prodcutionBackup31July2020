@IsTest
private with sharing class TaxiLicenceRenewalInitiatorTest {
    private static final Decimal BASE_PRICE = 120000;
    private static final Decimal APPLICATION_FEE = 200;
    
    private static testMethod void testForNonEligibleLicences(){
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        
        System.Test.startTest();
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess );
        System.Test.stopTest();
        List<Authorisation__c> licences = [SELECT Id FROM Authorisation__c];
        List<Case> applications = [SELECT Id FROM Case];
        System.assert(applications.isEmpty());
        System.assert(licences.size() == 1);
    }
    
    private static testMethod void testForEligibleLicenceWithEmailPreference(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today();
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        System.Test.startTest();
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
    }
    
    private static testMethod void testForServiceProviderWithPrimaryContact(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        Contact con = createContact(act.Id, true);
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today();
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        System.Test.startTest();
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c, ContactId FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
        System.assert(applications[0].ContactId == con.Id);
    }
    
    private static testMethod void testForServiceProviderWithoutPrimaryContactAndEmail(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        createContact(act.Id, false);
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE AccountId = :act.Id];
        for(Contact con : contacts){
            con.Email = null;
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        
        Database.update(contacts, dml);
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today();
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        System.Test.startTest();
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c, ContactId FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);       
    }
    
    private static testMethod void testForEligibleLicenceWithLetterPreference(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Letter';
        update act;
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today().addDays(10);
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        
        System.Test.startTest();
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_NEW);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
    }
    
    private static testMethod void testForEligibleLicenceWithBasePrice(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today().addDays(28);
        licence.Licence_Class__c = 'TXA20';
        update licence;
        
        List<Authorisation__c> licencesToProcess = [SELECT Id, Status__c, Authorisation_Type__c,
                                                    End_Date__c, Licence_Class__c, Renewal_Requested__c 
                                                    FROM Authorisation__c];
        
        System.debug('Updated Licence: '+licencesToProcess);
        
        System.Test.startTest();
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c, Authorisation__c, Authorisation__r.Licence_Fee__c FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
        System.assert(applications[0].Authorisation__r.Licence_Fee__c == BASE_PRICE);
        
        
    }
    
    //commenting out as currently no class in meta exists with renewal formula as Base+CPI
    /* 
    private static testMethod void testForEligibleLicenceWithBasePlusCpiPrice(){
        List<Consumer_Price_Index_Configuration__mdt> taxiCPIConfig = [SELECT CPI__c
                                                                       FROM Consumer_Price_Index_Configuration__mdt
                                                                       WHERE DeveloperName = :GlobalConstants.CPI_INDEX_METADATA_NAME  
                                                                       LIMIT 1];
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today();
        licence.Licence_Class__c = 'TX03';
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        
        System.Test.startTest();
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c, Authorisation__c, Authorisation__r.Licence_Fee__c FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
        System.assert(applications[0].Authorisation__r.Licence_Fee__c == (BASE_PRICE  + (BASE_PRICE * taxiCPIConfig[0].CPI__c/100)));
    }
    */
    
    private static testMethod void testForEligibleRecurringPaymentLicence(){
        Account act = [SELECT Id, Document_Delivery_Preference__c FROM Account];
        act.Document_Delivery_Preference__c = 'Email';
        update act;
        
        Authorisation__c licence = [SELECT Id, Start_Date__c, End_Date__c FROM Authorisation__c];
        licence.Start_Date__c = System.today().addYears(-1);
        licence.End_Date__c = System.today();
        licence.Payment_Frequency__c = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;
        update licence;
        List<Authorisation__c> licencesToProcess = [SELECT Id FROM Authorisation__c];
        
        System.Test.startTest();
        System.debug(LoggingLevel.INFO, 'Licences to process: ' + licencesToProcess);
        TaxiLicenceRenewalInitiator.initiate(licencesToProcess);
        System.Test.stopTest();
        
        List<Case> applications = [SELECT Id, Status, Sub_Status__c, Type, Sub_Type__c FROM Case];
        System.assert(!applications.isEmpty());
        System.assert(applications[0].Status == GlobalConstants.CASE_DRAFT);
        System.assert(applications[0].Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_DRAFT);
        System.assert(applications[0].Type == GlobalConstants.TAXI_CASE_TYPE);
        System.assert(applications[0].Sub_Type__c == GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
        
        List<Order> payments = [SELECT Id FROM Order WHERE Application__c IN :applications];
        System.assert(payments.size() == 13);
        List<OrderItem> applicationLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice = :APPLICATION_FEE];
        System.assert(applicationLineItems.size() == 1);
        List<OrderItem> licenceLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice >= :(BASE_PRICE/12)];
        System.debug(LoggingLevel.INFO, licenceLineItems);
        System.assert(licenceLineItems.size() == 12);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        createContact(act.Id, false);
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
    
    private static Contact createContact(Id actId, Boolean isPrimary){
        Contact con = new Contact();
        con.AccountId = actId;
        con.Email = 'test@example.com';
        con.FirstName = 'Test';
        con.LastName = 'User';
        con.Contact_Type__c = GlobalConstants.CONTACT_GENERAL_CONTACT ;
        con.Deactivated__c = false;
        con.Primary_Contact__c = isPrimary;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        
        Database.insert(con, dml);
        return con;
    }
    
    private static Authorisation__c createLicence(Id actId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addYears(1);
        auth.Start_Date__c = System.today();
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        auth.Licence_Class__c = 'TX12 Annual';
        auth.Licence_Fee__c = BASE_PRICE;
        auth.Licence_Type__c = GlobalConstants.LICENCE_TYPE_ANNUAL;
        auth.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
        auth.Renewal_Requested__c = false;
        
        insert auth;
        return auth;
    }
    
    private static void createPricebook(){
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - TX12 Annual', Family = 'Taxi Licence'));
        products.add(new Product2(Name = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - TXA20', Family = 'Taxi Licence'));
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