@isTest

public class BpayReferenceGenerationDeciderTest {
    
    @testSetup 
    static void setup(){
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void BatchToUpdatePendingRevenueTestMethod() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        List<Order> OrderList = new List<Order>();  
        Order ord1 = new Order(Type='Authorisation fee',Accountid=accountId,EffectiveDate=System.Today() - 28,status='Payment Due',payment_method__c='BPay');
        
        Order ord2 = new Order(Type='Authorisation fee',Accountid=accountId,EffectiveDate=System.Today() - 28,status='Payment Due',payment_method__c='None');
        
        OrderList.add(ord1);
        OrderList.add(ord2);
        
        insert OrderList;
        Map<Id, Order> newOrders = new Map<Id, Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        oldOrders=null;
        for(Order ord: OrderList){
         newOrders.put(ord.Id,ord);  
            
        }
        test.startTest();
        
        BpayReferenceGenerationDecider obj1 = New BpayReferenceGenerationDecider(newOrders,oldOrders);
        obj1.validateBpayReferenceGeneration();
        
        
        test.stopTest();
        
        
        
    }    
}