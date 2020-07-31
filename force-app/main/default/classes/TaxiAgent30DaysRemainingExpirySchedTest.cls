@isTest
public class TaxiAgent30DaysRemainingExpirySchedTest {
    
    @isTest
    private static void executeTest() {        
        Test.startTest();
        new TaxiAgent30DaysRemainingExpiryScheduler().execute(null);
        Test.stopTest();
    }

}