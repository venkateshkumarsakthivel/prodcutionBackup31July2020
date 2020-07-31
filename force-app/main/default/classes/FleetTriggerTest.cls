@isTest
public class FleetTriggerTest {

    @isTest
    private static void fleetTriggerTestMethod(){
    
        Test.startTest();
        DVD_Entity__c tempFleet = new DVD_Entity__c();
        tempFleet.Drivers_Licence_Number__c = '12345678901';
        tempFleet.Date_of_Birth__c = System.Today().addYears(-30);
        tempFleet.Last_Name__c = 'LastName';
        tempFleet.Plate_Number__c = '1234';
        tempFleet.VIN_Number_or_Chassis_Number__c = '1234';
        tempFleet.Plate_Type__c = 'M';
        
        insert tempFleet;
        Test.stopTest();
        
        tempFleet = [SELECT Unique_Id__c FROM DVD_Entity__c WHERE Id = :tempFleet.Id];
        System.assertNotEquals(NULL, tempFleet.Unique_Id__c);
    }
}