@isTest
public class SchedulerTLRenewalMaxYearsZeroBatchTest {
    
    public static testmethod void testschedule() {
        Test.StartTest();
        SchedulerTLRenewalMaxYearsZeroBatch sh1 = new SchedulerTLRenewalMaxYearsZeroBatch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
    
}