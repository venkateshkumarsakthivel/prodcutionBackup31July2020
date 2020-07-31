@isTest
public class SchedulerTLRenewalCountZeroBatchTest {
    
    public static testmethod void testschedule() {
        Test.StartTest();
        SchedulerTLRenewalCountZeroBatch sh1 = new SchedulerTLRenewalCountZeroBatch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
    
}