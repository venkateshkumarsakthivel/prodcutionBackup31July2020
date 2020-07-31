@isTest
public class P2POSRGetPaymentStatusSchedulerTest {
    
    @isTest
    private static void executeTest(){
        P2POSRGetPaymentStatusScheduler p2POSRGetPaymentStatusScheduler = new P2POSRGetPaymentStatusScheduler();
        test.startTest();
        p2POSRGetPaymentStatusScheduler.execute(null);
        test.stopTest();
        system.assert(true);
    }
}