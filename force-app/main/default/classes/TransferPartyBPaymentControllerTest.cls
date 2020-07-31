@IsTest
private with sharing class TransferPartyBPaymentControllerTest {
    
    private static testMethod void testForRetrieveApplication(){
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        System.Test.startTest();
        Case result = TransferPartyBPaymentController.retrieveApplicationDetails(caseRec.Id);
        System.Test.stopTest();
        System.assert(result != null);
        System.assert(result.Id == caseRec.Id);
    }
    
    private static testMethod void testForInvalidDataForRetrieve(){
        System.Test.startTest();
        Case result = TransferPartyBPaymentController.retrieveApplicationDetails(null);
        System.Test.stopTest();
        System.assert(result != null);
        System.assert(result.Id == null);
    }
    
    private static testMethod void testForProcessPayment(){
        Order payment = [SELECT Id, Status, AccountId, Application__c, TotalAmount, Payment_Reference__c, Payment_Method__c  FROM Order LIMIT 1];
        System.Test.startTest();
        String result = TransferPartyBPaymentController.processPaymentRequest(payment);
        System.Test.stopTest();
        System.assert(result != null);
    }
    
    private static testMethod void testForSubmitInvalidApplication(){
        Order payment = [SELECT Id, Status, AccountId, Application__c FROM Order LIMIT 1];
        System.Test.startTest();
        Case result = TransferPartyBPaymentController.submitApplication(null, JSON.serialize(payment));
        System.Test.stopTest();
        System.assert(result == null);
    }
    
    private static testMethod void testForSubmitApplication(){
        Order payment = [SELECT Id, Status, AccountId, Application__c FROM Order LIMIT 1];
        System.Test.startTest();
        Case result = TransferPartyBPaymentController.submitApplication(payment.Application__c, JSON.serialize(payment));
        System.Test.stopTest();
        System.assert(result != null);
        System.assert(result.Id == payment.Application__c);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Case caseRec = createApplication(act.Id);
        Authorisation__c auth = createLicence(act.Id, caseRec.Id);
        Pricebook2 pb = createPricebook();
        createPayment(act.Id, caseRec.Id, pb.Id, auth.Id);
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
    
    private static Authorisation__c createLicence(Id actId, Id appId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addYears(1);
        auth.Application__c = appId;
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
    
    private static Case createApplication(Id actId){
        Case application = new Case();
        application.AccountId = actId;
        application.Subject = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;
        application.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;               
        application.Type = GlobalConstants.TAXI_CASE_TYPE;                 
        application.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER ;
        application.Status = GlobalConstants.CASE_DRAFT;
        application.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
        insert application;
        return application;
    }
    
    private static Pricebook2 createPricebook(){
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

        return customPB;        
    }
    
    private static void createPayment(Id actId, Id caseId, Id pbId, Id authId){
        Order payment = new Order();
        payment.AccountId = actId;
        payment.Authorisation__c = authId;
        payment.Application__c = caseId;
        payment.Pricebook2Id = pbId;
        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD;
        payment.EffectiveDate = System.today();
        payment.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        insert payment;
    }
}