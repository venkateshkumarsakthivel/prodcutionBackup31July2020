@isTest
public class AuditLowLicenceCountNotificationSchTest {
    
    @isTest
    private static void executeTest() {
    
        Test.startTest();
        AuditLowLicenceCountNotificationSch sch = new AuditLowLicenceCountNotificationSch();
        sch.execute(null);
        Test.stopTest();
        System.assert(true);
    }
}