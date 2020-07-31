// this class is used as SchedulerToInactiveAuthorisationAgent's test class 
@isTest
public class SchedulerToInactiveAuthorisationAgenTest {
    
    @isTest
    private static void executeTest() {        
        Test.startTest();
        new SchedulerToInactiveAuthorisationAgent().execute(null);
        Test.stopTest();
    }

}