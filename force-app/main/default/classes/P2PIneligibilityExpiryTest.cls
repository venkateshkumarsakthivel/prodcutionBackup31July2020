@isTest
public class P2PIneligibilityExpiryTest {
	
    private static testmethod void testExecute(){
        
        Ineligible_Drivers__c rmsDriver = new Ineligible_Drivers__c(
        		Driver_Authority_ID__c = 'Test1',
            	Driver_Authority_Status__c = 'Cancelled',
            	Driver_Authority_Status_Start_Date__c = System.today().addYears(-2),
            	Driver_Authority_Status_Date__c = System.today().addDays(-1),
                Driver_Date_of_Birth__c = System.today().addYears(-25),
                Driver_Last_Name__c = 'TestDriver',
                Driver_Licence_Number__c = 'TestLicNum',
                Eligibility_Status_Reason__c = 'Testing scheduled ineligibilty reversal',
                Traffic_Light_Indicator__c = 'Fail'
        	);
        insert rmsDriver;
        
        
        Test.StartTest();
		P2PIneligibilityExpiry sh1 = new P2PIneligibilityExpiry();      
 		String sch = '0 0 23 * * ?';
        system.schedule('Test Ineligibilty Expiry Routine', sch, sh1);
		Test.stopTest();
        
        Ineligible_Drivers__c driver = [SELECT Id, Ignore_End_Date__c, Traffic_Light_Indicator__c 
                                        FROM Ineligible_Drivers__c
                                       WHERE Id = :rmsDriver.Id];
        System.assert(driver.Traffic_Light_Indicator__c == 'Pass', 'Traffic Light not reversed');
        System.assert(driver.Ignore_End_Date__c == TRUE, 'Ignore End Date not set');
    }
}