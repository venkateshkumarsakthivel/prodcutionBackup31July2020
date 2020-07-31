@IsTest
private with sharing class DDPendingPaymentProcessorBatchTest {
    
    private static testMethod void testForAuthWithoutBankDetails(){
        List<Authorisation__c> auths = [SELECT Id , BSB_Number__c FROM Authorisation__c];
        for(Authorisation__c auth : auths){
            auth.BSB_Number__c = null;
        }
        update auths;
        
        System.Test.startTest();
        Database.executeBatch(new DDPendingPaymentProcessorBatch(new List<Date>{System.today()}));
        System.Test.stopTest();
        List<Order> payments = [SELECT Id, Status FROM Order];
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_DUE_STATUS);
        }
    }
    
    private static testMethod void testForPaymentWithRejectedStatus(){
        List<Order> payments = [SELECT Id, Payment_Method__c FROM Order];
        for(Order payment : payments){
            payment.Status = GlobalConstants.PAYMENT_REJECTED_STATUS ;
        }
        update payments;
        
        System.Test.startTest();
        Database.executeBatch(new DDPendingPaymentProcessorBatch(new List<Date>{System.today()}));
        System.Test.stopTest();
        payments = [SELECT Id, Status FROM Order];
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_REJECTED_STATUS);
        }
    }
    
    private static testMethod void testForMultipleStartDate(){     
        System.Test.startTest();
        Database.executeBatch(new DDPendingPaymentProcessorBatch(
                new List<Date>{System.today(),System.today().addDays(-1), System.today().addDays(-2)}));
        System.Test.stopTest();
        List<Order> payments = [SELECT Id, Status FROM Order];
        for(Order payment : payments){
            System.assert(payment.Status == GlobalConstants.PAYMENT_PAID_UNCLEARED_STATUS );
            System.assert(true);
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
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Payment_Frequency__c = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        
        insert auth;
        return auth;
    }
    
    private static void createPayment(Id actId, Id authId){
        Order payment = new Order();
        payment.Authorisation__c = authId;
        payment.AccountId = actId;
        payment.EffectiveDate = System.today();
        payment.Received_Date__c = System.today();
        payment.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
        
        insert payment;
    }
}