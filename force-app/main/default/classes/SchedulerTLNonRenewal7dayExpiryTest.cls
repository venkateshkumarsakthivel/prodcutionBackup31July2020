@isTest
public class SchedulerTLNonRenewal7dayExpiryTest {
    
    public static testmethod void testschedule() {
        Test.StartTest();
        SchedulerTLNonRenewal7dayExpiry sh1 = new SchedulerTLNonRenewal7dayExpiry();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
    
}