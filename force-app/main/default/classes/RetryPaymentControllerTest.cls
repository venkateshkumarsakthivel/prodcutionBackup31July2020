@IsTest
private with sharing class RetryPaymentControllerTest {
    
    private static testMethod void testForNonRejectedPaymentVerification(){
        List<Order> payments = [SELECT Id, Status FROM Order];
        for(Order payment: payments){
            payment.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        }
        update payments;        
        
        System.Test.startTest();
        String returnStr = RetryPaymentController.verifyPaymentDetails(payments[0].Id);
        System.Test.stopTest();
        System.assert(returnStr == null);
    }
    
    private static testMethod void testForInvalidPaymentIdVerification(){
        System.Test.startTest();
        String returnStr = RetryPaymentController.verifyPaymentDetails('1231321');
        System.Test.stopTest();
        System.assert(returnStr == null);
    }
    
    private static testMethod void testForNonRecurringRejectedPaymentVerification(){
        List<Authorisation__c> auths = [SELECT Id, Payment_Frequency__c FROM Authorisation__c];
        for(Authorisation__c auth: auths){
            auth.Payment_Frequency__c = null;
        }
        update auths;
        
        List<Order> payments = [SELECT Id FROM Order];
        System.Test.startTest();
        String returnStr = RetryPaymentController.verifyPaymentDetails(payments[0].Id);
        System.Test.stopTest();
        System.assert(returnStr == null);
    }
    
    private static testMethod void testForRecurringRejectedPaymentVerification(){
        List<Order> payments = [SELECT Id FROM Order];
        payments[0].Processing_Date__c = System.today().addDays(-1);
        update payments;
        
        System.Test.startTest();
        String returnStr = RetryPaymentController.verifyPaymentDetails(payments[0].Id);
        System.Test.stopTest();
        System.assert(returnStr != null);       
    }
    
    private static testMethod void testForResendingPayment(){
        List<Order> payments = [SELECT Id FROM Order];
        System.Test.startTest();
        RetryPaymentController.CURRENT_DATETIME = Datetime.newInstance(2017, 8, 21, 14,10,10);
        RetryPaymentController.resendPaymentRequest(payments[0].Id);
        System.Test.stopTest();
        payments = [SELECT Id, Status FROM Order WHERE Id = :payments[0].Id];
        System.assert(!payments.isEmpty());
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_DUE_STATUS);
        }
    }
    
    private static testMethod void testForResendingPaymentOnNonBusinessDay(){
        List<Order> payments = [SELECT Id FROM Order];
        System.Test.startTest();
        RetryPaymentController.CURRENT_DATETIME = Datetime.newInstance(2017, 8, 20, 10,10,10);
        Date testDate = Date.newInstance(2017,8, 21);
        RetryPaymentController.resendPaymentRequest(payments[0].Id);
        System.Test.stopTest();
        payments = [SELECT Id, Status, Received_Date__c, Processing_Date__c FROM Order WHERE Id = :payments[0].Id];
        System.assert(!payments.isEmpty());
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_DUE_STATUS);
            System.assert(testDate.isSameDay(payment.Processing_Date__c));
        }
    }
    
    private static testMethod void testForResendingPaymentAfterThreePM(){
        List<Order> payments = [SELECT Id FROM Order];
        System.Test.startTest();
        RetryPaymentController.CURRENT_DATETIME = Datetime.newInstance(2017, 8, 21, 16,10,10);
        Date testDate = Date.newInstance(2017,8, 22);
        RetryPaymentController.resendPaymentRequest(payments[0].Id);
        System.Test.stopTest();
        payments = [SELECT Id, Status, Received_Date__c, Processing_Date__c FROM Order WHERE Id = :payments[0].Id];
        System.assert(!payments.isEmpty());
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_DUE_STATUS);
            System.assert(testDate.isSameDay(payment.Processing_Date__c));
        }
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Authorisation__c auth = createAuth(act.Id);
        createPayment(act.Id, auth.Id);
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
    
    private static Authorisation__c createAuth(Id actId){
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = System.today().addYears(1);
        auth.Start_Date__c = System.today();
        auth.Payment_Frequency__c = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;
        
        insert auth;
        return auth;
    }
    
    private static void createPayment(Id actId, Id authId){
        Order payment = new Order();
        payment.Authorisation__c = authId;
        payment.AccountId = actId;
        payment.EffectiveDate = System.today().addDays(-1);
        payment.Processing_Date__c = System.today().addDays(-1);
        payment.Status = GlobalConstants.PAYMENT_REJECTED_STATUS;
        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
        
        insert payment;
    }
}