// this class is used as SchedulerToDeleteAgreementCases's test class 
@isTest
public class SchedulerToDeleteAgreementCasesTest {
    
    @isTest
    private static void executeTest() {        
        Test.startTest();
        new SchedulerToDeleteAgreementCases().execute(null);
        Test.stopTest();
    }

}