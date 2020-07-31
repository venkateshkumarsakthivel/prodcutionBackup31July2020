@isTest
public class P2PWIBSQBReturnsParserFacadeTest {
    
    @testSetup 
    static void setup(){
        Account account = new Account(Name = 'Account For Order');
        insert account;
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation;

       List<Order> listOfOrders = new List<Order>();
        for(Integer i=0;i<7;i++) {
            Order order = new Order(Name = 'paymentStatusControllerTestUser Order'+i, Authorisation__c =  authorisation.Id,AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
            listOfOrders.add(order);
        }
        insert listOfOrders;
        
        
    }
    
    @isTest
    private static void executeTest(){
        List<Order> selectOrder = new List<Order>();
        selectOrder = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER];
     
        List<String> tokens = new List<String>();
        for(Order s : selectOrder){
            tokens.add(s.Payment_Reference__c);
        }
        
        
        P2PWIBSQBReturnsParserFacade p2pWIBSQBReturnParserFacade = new P2PWIBSQBReturnsParserFacade();
        p2pWIBSQBReturnParserFacade.execute(tokens);
        System.assertEquals(tokens.get(3), p2pWIBSQBReturnParserFacade.ordersTobeUpdated.values().Payment_Reference__c);
        System.assertEquals(tokens.get(6),p2pWIBSQBReturnParserFacade.ordersTobeUpdated.values().Payment_Response_Description__c);
        System.assertEquals(tokens.get(5),p2pWIBSQBReturnParserFacade.ordersTobeUpdated.values().Payment_Response_Code__c);
        System.assertEquals('Payment Due',p2pWIBSQBReturnParserFacade.ordersTobeUpdated.values().Previous_Payment_Status__c);
       
        
    }
}