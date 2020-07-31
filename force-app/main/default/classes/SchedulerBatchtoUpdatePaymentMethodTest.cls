@isTest
public class SchedulerBatchtoUpdatePaymentMethodTest {
    
    public static testmethod void  testschedule() {
        Test.StartTest();
        SchedulerBatchtoUpdatePaymentmethod sh1 = new SchedulerBatchtoUpdatePaymentmethod();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
    
}