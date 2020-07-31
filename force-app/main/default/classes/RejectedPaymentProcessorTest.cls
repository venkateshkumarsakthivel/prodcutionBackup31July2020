@IsTest
private with sharing class RejectedPaymentProcessorTest {

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            RejectedPaymentProcessor paymentProcessor = new RejectedPaymentProcessor(null, null);
            System.assert(false);
        } catch(RejectedPaymentProcessor.InvalidDataException e){
            //expected exception
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForNonRejectedPayment(){
        List<Order> payments = [SELECT Id, Status, Payment_Method__c, 
                                    Amount_Paid__c, Authorisation__c, AccountId
                                FROM Order ];
        Map<Id, Order> oldPayments = new Map<Id, Order>();
        for(Order payment : payments){
            oldPayments.put(payment.Id, payment);
        }
        
        System.Test.startTest();
        RejectedPaymentProcessor processor = new RejectedPaymentProcessor(oldPayments, oldPayments);
        processor.process();
        System.Test.stopTest();
        List<Case> cases = [SELECT Id FROM Case WHERE Payment__c IN :payments ];
        System.assert(cases.isEmpty());
    }
    
    private static testMethod void testForRejectedNonRecurringPayment(){
        List<Order> payments = [SELECT Id, Status, Payment_Method__c, 
                                    Amount_Paid__c, Authorisation__c, AccountId
                                FROM Order ];
        Map<Id, Order> oldPaymentMap = new Map<Id, Order>();
        for(Order payment : payments){
            oldPaymentMap.put(payment.Id, payment);
        }
        
        List<Order> newPayments = [SELECT Id, Status, Payment_Method__c, 
                                    Amount_Paid__c, Authorisation__c, AccountId
                                FROM Order ];
        Map<Id, Order> newPaymentMap = new Map<Id, Order>();
        for(Order payment : newPayments){
            payment.Status = GlobalConstants.PAYMENT_REJECTED_STATUS;
            newPaymentMap.put(payment.Id, payment);
        }
        
        List<Authorisation__c> auths = [SELECT Id, Payment_Frequency__c FROM Authorisation__c];
        for(Authorisation__c auth : auths){
            auth.Payment_Frequency__c = null;
        }
        update auths;
        System.Test.startTest();
        RejectedPaymentProcessor processor = new RejectedPaymentProcessor(newPaymentMap, oldPaymentMap);
        processor.process();
        System.Test.stopTest();
        List<Case> cases = [SELECT Id FROM Case WHERE Payment__c IN :payments ];
        System.assert(cases.isEmpty());
    }
    
    private static testMethod void testForRejectedRecurringPayment(){
        List<Order> payments = [SELECT Id, Status, Payment_Method__c, 
                                    Amount_Paid__c, Authorisation__c, AccountId
                                FROM Order ];
        Map<Id, Order> oldPaymentMap = new Map<Id, Order>();
        for(Order payment : payments){
            oldPaymentMap.put(payment.Id, payment);
        }
        
        List<Order> newPayments = [SELECT Id, Status, Payment_Method__c, 
                                    Amount_Paid__c, Authorisation__c, AccountId
                                FROM Order ];
        Map<Id, Order> newPaymentMap = new Map<Id, Order>();
        for(Order payment : newPayments){
            payment.Status = GlobalConstants.PAYMENT_REJECTED_STATUS;
            newPaymentMap.put(payment.Id, payment);
        }
        
        System.Test.startTest();
        RejectedPaymentProcessor processor = new RejectedPaymentProcessor(newPaymentMap, oldPaymentMap);
        processor.process();
        System.Test.stopTest();
        List<Case> cases = [SELECT Id FROM Case WHERE Payment__c IN :payments ];
        System.assert(!cases.isEmpty());
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
        payment.EffectiveDate = System.today();
        payment.Status = GlobalConstants.PAYMENT_PAID_UNCLEARED_STATUS;
        payment.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
        
        insert payment;
    }
}