@isTest
public class SchedulerBatchToUpdatePendingRevenueTest {
    
    public static testmethod void  testschedule() {
        Test.StartTest();
        SchedulerBatchToUpdatePendingRevenue sh1 = new SchedulerBatchToUpdatePendingRevenue();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
    
}