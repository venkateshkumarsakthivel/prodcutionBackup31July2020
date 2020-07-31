@isTest 
public class CircularProgressControllerTest {
    
    @testSetup 
    static void setup(){
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
              Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
        
    }
    
    @isTest
    private static void computePercentageTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        String fileContent = 'lastname,dob,licence\r\nScott,01/21/1980,D90909A\r\nTotts,09/24/1982,D90910A\r\nPotts,01/05/1977,D90911A';
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Id driverRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Driver').getRecordTypeId();
        Id vehicleRTID = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<DVD_Entity__c> dvdEntities = new List<DVD_Entity__c>();
        
        DVD_Entity__c vehicle = new DVD_Entity__c();
        vehicle.RecordTypeId = vehicleRTID;
        vehicle.Plate_Number__c = 'VEH-001'; 
        vehicle.Plate_Type__c = 'O'; 
        vehicle.VIN_Number_or_Chassis_Number__c = String.valueOf(1112);
        vehicle.Authorised_Service_Provider__c = accountId;
        dvdEntities.add(vehicle);
        
        
        DVD_Entity__c driver = new DVD_Entity__c();
        driver.RecordTypeId = driverRTID;
        driver.Drivers_Licence_Number__c= 'DL-001'; 
        driver.Date_of_Birth__c = System.today() - 6940;
        driver.Last_Name__c = 'Driver';
        driver.Authorised_Service_Provider__c = accountId;
        dvdEntities.add(driver);
        
        insert dvdEntities;
        test.startTest();
        
        String queueDrivers = ASPDashboardController.runCheckAllDrivers();
        String queueVehicles = ASPDashboardController.runCheckAllVehicles();
        List<DVD_Query_Group__c> result = ASPDashboardController.getDVDQueryGroupLogs();
        String qGrpId = result[0].Id;
        String resultafter = CircularProgressController.computePercentage('DVD_Query_Group__c', qGrpId, 'Eligibility_Check_Total_Count__c', 'Total__c');
        
        System.assertNotEquals(NULL, resultafter);
    }
}