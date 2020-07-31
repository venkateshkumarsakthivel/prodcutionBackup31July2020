@isTest
public class TaxiAgent0DaysRemainingExpirySchedTest {
    
    @isTest
    private static void executeTest() {        
        Test.startTest();
        new TaxiAgent0DaysRemainingExpiryScheduler().execute(null);
        Test.stopTest();
    }

}