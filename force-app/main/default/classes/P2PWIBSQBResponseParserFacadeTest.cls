@isTest
public class P2PWIBSQBResponseParserFacadeTest {
    
    public static P2PWIBSQBResponseParserFacade p2pWIBSQBResponseParserFacade = new P2PWIBSQBResponseParserFacade();
    public static List<String> tokens = new List<String>(14);
    public static void getrandomstring(Integer sizeoft)
    {
        
        for(Integer i=0;i<sizeoft;i++)
        {    
            tokens.set(i, 'random'+i);
        }
        
        System.debug('Token List is :'+tokens);
    }
    
    @testSetup 
    static void setup(){
        
        Account account = new Account(Name = 'Account For Order');
        insert account;
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation;
        Order order = new Order(Name = 'paymentStatusControllerTestUser Order', Authorisation__c =  authorisation.Id,AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
        insert order;
    }
    
    @isTest
    private static void executeTest1(){
        Order order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
        
        Integer sizeOfTokens = tokens.size();
        getrandomstring(sizeOfTokens);
        
        tokens.set(0,'3');
        tokens.set(3,'CC');
        tokens.set(4,'5000');
        tokens.set(7,order.Payment_Reference__c);
        tokens.set(11,'1');
        tokens.set(12,'Response Code Test Text' );
        tokens.set(13,'Response Description Test Text');
        
        System.debug('Tokens are '+tokens);
        System.debug('11th index token: '+tokens[11]);
        p2pWIBSQBResponseParserFacade.execute(tokens);
        System.assertEquals(tokens.get(3),p2pWIBSQBResponseParserFacade.header.type);
        
    }
    
    @isTest
    private static void executeTest2(){
        Order order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
        
        Integer sizeOfTokens = tokens.size();
        getrandomstring(sizeOfTokens);
        tokens.set(0,'5');
        tokens.set(3,'DD');
        tokens.set(4,'5000');
        tokens.set(7,order.Payment_Reference__c);
        tokens.set(11,'1');
        tokens.set(12,'Response Code Test Text' );
        tokens.set(13,'Response Description Test Text');
        
        System.debug('Test 2 tokens: '+tokens);
        System.debug('11th index token: '+tokens[11]);
        
        P2PWIBSQBResponseParserFacade.header header = new P2PWIBSQBResponseParserFacade.header('DD');
        p2pWIBSQBResponseParserFacade.header = header;
        p2pWIBSQBResponseParserFacade.execute(tokens);
        
        System.assertEquals(tokens.get(3),p2pWIBSQBResponseParserFacade.header.type);
        System.assertEquals(tokens.get(11),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Summary_Code__c);
        System.assertEquals(tokens.get(12),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Code__c);
        System.assertEquals(tokens.get(13),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Description__c);
        System.assertEquals('Payment Rejected',p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Status);
    }
    
    @isTest
    private static void executeTest3(){
        Order order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
        
        Integer sizeOfTokens = tokens.size();
        getrandomstring(sizeOfTokens);
        tokens.set(0,'5');
        tokens.set(3,'DD');
        tokens.set(4,'5000');
        tokens.set(7,order.Payment_Reference__c);
        tokens.set(11,'0');
        tokens.set(12,'Response Code Test Text' );
        tokens.set(13,'Response Description Test Text');
        
        System.debug('Test 3 tokens: '+tokens);
        System.debug('11th index token: '+tokens[11]);
        
        P2PWIBSQBResponseParserFacade.header header = new P2PWIBSQBResponseParserFacade.header('DD');
        p2pWIBSQBResponseParserFacade.header = header;
        p2pWIBSQBResponseParserFacade.execute(tokens);
        Date t3_date = P2PWIBSParserFacadeBase.calculateT3(date.today());
        Date rdate = System.today();
        
        System.assertEquals(tokens.get(3),p2pWIBSQBResponseParserFacade.header.type);
        System.assertEquals('Payment Uncleared',p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Status);
        System.assertEquals(rdate,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values(). Received_Date__c);
        System.assertEquals(t3_date,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Cleared_Date__c);
        
        
    }
    
    @isTest
    private static void executeTest4(){
        Order order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
        
        Integer sizeOfTokens = tokens.size();
        getrandomstring(sizeOfTokens);
        tokens.set(0,'5');
        tokens.set(3,'CC');
        tokens.set(4,'5000');
        tokens.set(7,order.Payment_Reference__c);
        tokens.set(11,'1');
        tokens.set(12,'Response Code Test Text' );
        tokens.set(13,'Response Description Test Text');
        
        System.debug('Test 4 tokens: '+tokens);
        System.debug('11th index token: '+tokens[11]);
        
        P2PWIBSQBResponseParserFacade.header header = new P2PWIBSQBResponseParserFacade.header('CC');
        p2pWIBSQBResponseParserFacade.header = header;
        p2pWIBSQBResponseParserFacade.execute(tokens);
        
        System.assertEquals(tokens.get(3),p2pWIBSQBResponseParserFacade.header.type);
        System.assertEquals(tokens.get(11),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Summary_Code__c);
        System.assertEquals(tokens.get(12),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Code__c);
        System.assertEquals(tokens.get(13),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Description__c);
        System.assertEquals('Payment Rejected',p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Status);
    }
    
    @isTest
    private static void executeTest5(){
        Order order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
        
        Integer sizeOfTokens = tokens.size();
        getrandomstring(sizeOfTokens);
        tokens.set(0,'5');
        tokens.set(3,'CC');
        tokens.set(4,'5000');
        tokens.set(7,order.Payment_Reference__c);
        tokens.set(11,'0');
        tokens.set(12,'Response Code Test Text' );
        tokens.set(13,'Response Description Test Text');
        
        System.debug('Test 5 tokens: '+tokens);
        System.debug('11th index token: '+tokens[11]);
        
        P2PWIBSQBResponseParserFacade.header header = new P2PWIBSQBResponseParserFacade.header('CC');
        p2pWIBSQBResponseParserFacade.header = header;
        p2pWIBSQBResponseParserFacade.execute(tokens);
        
        Decimal totalAmountPaid = (Decimal.valueOf(tokens.get(4).trim())/100);
        Decimal surchargeAmount = (p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Surcharge_Amount__c) - (p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().TotalAmount) ;
        Date rdate = System.today();
        
        System.assertEquals(tokens.get(3),p2pWIBSQBResponseParserFacade.header.type);
        System.assertEquals(tokens.get(11),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Summary_Code__c);
        System.assertEquals(tokens.get(12),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Code__c);
        System.assertEquals(tokens.get(13),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Response_Description__c);
        System.assertEquals(tokens.get(9),p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values(). Receipt_Number__c);
        
        System.assertEquals(totalAmountPaid,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Amount_Paid__c);
        System.assertEquals(surchargeAmount,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Surcharge_Amount__c);
        
        System.assertEquals(rdate,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Received_Date__c);
        System.assertEquals(rdate,p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values().Payment_Cleared_Date__c);
        
        System.debug('Final test: '+p2pWIBSQBResponseParserFacade.ordersToBeUpdated.values());
    }
}