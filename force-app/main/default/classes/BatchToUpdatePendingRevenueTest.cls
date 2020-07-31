@isTest

public class BatchToUpdatePendingRevenueTest {
    
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
        Order ord1 = new Order(Type='Authorisation fee',Accountid=accountId,EffectiveDate=System.Today() - 28,status='Payment Due');
        
        Order ord2 = new Order(Type='Authorisation fee',Accountid=accountId,EffectiveDate=System.Today() - 28,status='Payment Due');
        
        OrderList.add(ord1);
        OrderList.add(ord2);
        
        insert OrderList;
        
        test.startTest();
        
        BatchToUpdatePendingRevenue obj1 = New BatchToUpdatePendingRevenue();
        Database.executeBatch(obj1);
        //Database.QueryLocator ql = obj1.start(null);
        //obj1.execute(null,OrderList);
        //obj1.Finish(null);
        
        test.stopTest();
        
        
        
    }    
}