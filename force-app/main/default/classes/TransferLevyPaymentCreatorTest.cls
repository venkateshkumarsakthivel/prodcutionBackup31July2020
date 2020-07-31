@IsTest
private with sharing class  TransferLevyPaymentCreatorTest{

    private static final Decimal LEVY_AMT = 100;

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            TransferLevyPaymentCreator paymentCreator = new TransferLevyPaymentCreator(null);
            System.assert(false);
        } catch(TransferLevyPaymentCreator.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForLevyDue(){
        Case application = [SELECT Id, Levy_Due__c, Licence_Market_Value__c, AccountId, Authorisation__c FROM Case];
        System.Test.startTest();
        TransferLevyPaymentCreator paymentCreator = new TransferLevyPaymentCreator(application);
        paymentCreator.create();
        System.Test.stopTest();
        List<Order> payments = [SELECT Id, TotalAmount FROM Order WHERE Application__c = :application.Id];
        System.assert(payments.size() == 1);
        System.assert(payments[0].TotalAmount == LEVY_AMT);
        
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
        auth.Licence_Fee__c = 10000;
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
        application.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER ;
        application.Status = GlobalConstants.CASE_DRAFT;
        application.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
        application.Levy_Due__c = LEVY_AMT;
        application.Licence_Market_Value__c = 100000;
        insert application;
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
}