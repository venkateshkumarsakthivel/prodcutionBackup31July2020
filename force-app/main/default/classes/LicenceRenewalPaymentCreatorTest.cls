@IsTest
private with sharing class LicenceRenewalPaymentCreatorTest {
    private static final Decimal BASE_PRICE = 12000;
    private static final Decimal APPLICATION_FEE = 200;
    
    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try {
            LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(null);
            System.assert(false);
        } catch(LicenceRenewalPaymentCreator.InvalidDataException e){
            System.assert(true);
        }       
        System.Test.stopTest();
    }
    
    private static testMethod void testForNonRecurringLicence(){
        List<Case> applications =   [SELECT Id, Authorisation__c, Authorisation__r.Licence_Class__c, Authorisation__r.Service_Provider__c,
                                        Authorisation__r.Licence_Type__c, Authorisation__r.Payment_Frequency__c, 
                                        Authorisation__r.Start_Date__c, Authorisation__r.End_Date__c, Authorisation__r.Licence_Fee__c 
                                    FROM Case];
        Map<Id, Authorisation__c> appVsLicence = new Map<Id, Authorisation__c>();
        for(Case app : applications){
            appVsLicence.put(app.Id, app.Authorisation__r);
        }
        
        System.Test.startTest();
        LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(appVsLicence);
        paymentCreator.create();
        System.Test.stopTest();
        
        List<Order> payments = [SELECT Id FROM Order WHERE Application__c IN :applications];
        System.assert(payments.size() == 1);
        List<OrderItem> applicationLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice = :APPLICATION_FEE];
        System.assert(applicationLineItems.size() == 1);
        List<OrderItem> licenceLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice = :BASE_PRICE];
        System.assert(applicationLineItems.size() == 1);
    }
    
    private static testMethod void testForRecurringLicence(){
        Authorisation__c licence = [SELECT Id, Payment_Frequency__c FROM Authorisation__c];
        licence.Payment_Frequency__c = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;
        update licence;
        
        List<Case> applications =   [SELECT Id, Authorisation__c, Authorisation__r.Licence_Class__c, Authorisation__r.Service_Provider__c,
                                        Authorisation__r.Licence_Type__c, Authorisation__r.Payment_Frequency__c, Authorisation__r.Bank_Account_Number__c, Authorisation__r.Payment_Card_Number__c, 
                                        Authorisation__r.Start_Date__c, Authorisation__r.End_Date__c, Authorisation__r.Licence_Fee__c 
                                    FROM Case];
        Map<Id, Authorisation__c> appVsLicence = new Map<Id, Authorisation__c>();
        for(Case app : applications){
            appVsLicence.put(app.Id, app.Authorisation__r);
        }
        
        System.Test.startTest();
        LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(appVsLicence);
        paymentCreator.create();
        System.Test.stopTest();
        
        List<Order> payments = [SELECT Id FROM Order WHERE Application__c IN :applications];
        System.assert(payments.size() == 13);
        List<OrderItem> applicationLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice = :APPLICATION_FEE];
        System.assert(applicationLineItems.size() == 1);
        List<OrderItem> licenceLineItems = [SELECT Id FROM OrderItem WHERE OrderId IN :payments AND UnitPrice = :(BASE_PRICE/12)];
        System.assert(licenceLineItems.size() == 12);
    }
    
    private static testMethod void testForInvalidLicenceClass(){
        List<Case> applications =   [SELECT Id, Authorisation__c, Authorisation__r.Licence_Class__c, Authorisation__r.Service_Provider__c,
                                        Authorisation__r.Licence_Type__c, Authorisation__r.Payment_Frequency__c, 
                                        Authorisation__r.Start_Date__c, Authorisation__r.End_Date__c, Authorisation__r.Licence_Fee__c 
                                    FROM Case];
        Map<Id, Authorisation__c> appVsLicence = new Map<Id, Authorisation__c>();
        for(Case app : applications){
            Authorisation__c licence = app.Authorisation__r;
            licence.Licence_Class__c = 'Test';
            appVsLicence.put(app.Id, licence);
        }
        
        System.Test.startTest();
        try {
            LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(appVsLicence);
            paymentCreator.create();
            System.assert(false);
        } catch(LicenceRenewalPaymentCreator.InvalidDataException e){
            System.assert(true);
        }        
        System.Test.stopTest();     
    }
    
    private static testMethod void testForInvalidLicenceType(){
        List<Case> applications =   [SELECT Id, Authorisation__c, Authorisation__r.Licence_Class__c, Authorisation__r.Service_Provider__c,
                                        Authorisation__r.Licence_Type__c, Authorisation__r.Payment_Frequency__c, 
                                        Authorisation__r.Start_Date__c, Authorisation__r.End_Date__c, Authorisation__r.Licence_Fee__c 
                                    FROM Case];
        Map<Id, Authorisation__c> appVsLicence = new Map<Id, Authorisation__c>();
        for(Case app : applications){
            Authorisation__c licence = app.Authorisation__r;
            licence.Licence_Type__c = 'Type';
            appVsLicence.put(app.Id, licence);
        }
        
        System.Test.startTest();
        try {
            LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(appVsLicence);
            paymentCreator.create();
            System.assert(false);
        } catch(LicenceRenewalPaymentCreator.InvalidDataException e){
            System.assert(true);
        }        
        System.Test.stopTest();
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Authorisation__c auth = createLicence(act.Id);
        createApplication(act.Id, auth.Id);
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
        auth.End_Date__c = System.today().addYears(1);
        auth.Start_Date__c = System.today();
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        auth.Licence_Class__c = 'TX08';
        auth.Licence_Type__c = GlobalConstants.LICENCE_TYPE_ANNUAL;
        auth.Licence_Fee__c = BASE_PRICE;
        auth.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
        
        insert auth;
        return auth;
    }
    
    private static void createApplication(Id actId, Id licenceId){
        Case application = new Case();
        application.AccountId = actId;
        application.Authorisation__c = licenceId;
        application.Subject = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;
        application.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;               
        application.Type = GlobalConstants.TAXI_CASE_TYPE;                 
        application.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
        application.Status = GlobalConstants.CASE_NEW ;
        application.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
        insert application;
    }
    
    private static void createPricebook(){
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - TX08', Family = 'Taxi Licence'));
        products.add(new Product2(Name = GlobalConstants.ANNUAL_TAXI_LICENCE_PRODUCT_NAME, Family = 'Taxi Licence'));
        insert products;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        List<PriceBookEntry> stdPbEntries = new List<PriceBookEntry>();
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[0].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        stdPbEntries.add(new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = products[1].Id,UnitPrice = 0, IsActive = true));
        
        insert stdPbEntries;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name= Label.ASP_Pricebook, isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[0].Id,UnitPrice = APPLICATION_FEE, IsActive = true));
        pbEntries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = products[1].Id,UnitPrice = 0, IsActive = true));
        
        insert pbEntries;        
    }
}