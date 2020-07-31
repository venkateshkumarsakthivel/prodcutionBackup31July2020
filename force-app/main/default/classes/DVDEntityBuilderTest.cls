@isTest
private class DVDEntityBuilderTest {
    
    public Enum DVDEntityType {DRIVER, VEHICLE}
    
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest static void buildDrivereTest() {        
        List<String> driverRecords = new List<String>{'Bailey','12/27/1990','8776P05K'};        
            Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_DRIVER_DEVELOPER_NAME).getRecordTypeId();        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DVD_Entity__c driver;
        test.startTest();
        System.runAs(user) {
            driver = DVDEntityBuilder.buildDriver(driverRecords,accountId,rtId);            
            insert driver;
            system.assertEquals('Bailey', driver.Last_Name__c);            
            system.assertEquals('8776P05K', driver.Drivers_Licence_Number__c);
        }
        test.stopTest();
    }
    
    @isTest static void buildVehicleTest() {
        List<String> vehicleRecords = new List<String>{'T4240','O','2223'}; 
            Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_VEHICLE_DEVELOPER_NAME).getRecordTypeId();
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        DVD_Entity__c vehicle;
        test.startTest();
        System.runAs(user) {
            vehicle = DVDEntityBuilder.buildVehicle(vehicleRecords,accountId,rtId);
            insert vehicle;
            system.assertEquals('T4240', vehicle.Plate_Number__c);
            system.assertEquals('O', vehicle.Plate_Type__c);
            system.assertEquals('2223', vehicle.VIN_Number_or_Chassis_Number__c);
        }
        test.stopTest();
    }           
}