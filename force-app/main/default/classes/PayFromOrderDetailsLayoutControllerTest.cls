@istest
public class PayFromOrderDetailsLayoutControllerTest {

   @testSetup 
    static void setup(){
   
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;     
    }
    
    @istest
    private static void showTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        
        Case case1=new Case(AccountId =accountId,Status='Approved',Licence_Type__c='Annual');
        insert case1;
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = accountId, Authorisation_Name__c = 'Authorisation for Order');
		insert authorisation;
        Order order=new Order(Status='Paid in Full',Previous_Payment_Status__c='Payment Due',AccountId =accountId, Authorisation__c =  authorisation.Id, EffectiveDate=system.today(),Application__c=case1.Id,
                             Receipt_Number__c='12345',Amount_Paid__c=100);
        insert order;
        
        Test.startTest();
        System.assert(PayFromOrderDetailsLayoutController.show(order.Id)!=null);
        Test.stopTest();
    }
}