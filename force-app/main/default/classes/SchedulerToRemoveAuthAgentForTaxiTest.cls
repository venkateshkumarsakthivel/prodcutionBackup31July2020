// this class is used as SchedulerToRemoveAuthAgentForTaxi's test class 
@isTest
public class SchedulerToRemoveAuthAgentForTaxiTest {
    
    @isTest
    private static void executeTest() {        
        Test.startTest();
        new SchedulerToRemoveAuthAgentForTaxi().execute(null);
        Test.stopTest();
    }

}