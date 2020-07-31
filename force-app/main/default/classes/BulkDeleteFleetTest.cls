@isTest
public class BulkDeleteFleetTest {
      
    @testSetup 
    static void createASPUserAndAccount(){
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

        Id rtId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_DRIVER_DEVELOPER_NAME).getRecordTypeId();
        // Insert Driver Entity record
        DVD_Entity__c dvdEntity = new DVD_Entity__c();
        
            dvdEntity.Last_Name__c = 'Scott';
            dvdEntity.Date_of_Birth__c = Date.parse('01/01/1992'); //formDateString(driverRecord[1]);
            dvdEntity.Drivers_Licence_Number__c = 'D90O909A';
            dvdEntity.Criminal_Check__c = 'None';
            dvdEntity.Licence_Check__c = 'None';
            dvdEntity.P2P_Offence__c = 'None';
            dvdEntity.Serious_Driving_Offence__c = 'None';
            dvdEntity.RecordTypeId = rtId;
            
            dvdEntity.Authorised_Service_Provider__c = ac.ID;   
        insert dvdEntity;    

        Id rtVehId = Schema.SObjectType.DVD_Entity__c.getRecordTypeInfosByName().get(Label.DVD_ENTITY_VEHICLE_DEVELOPER_NAME).getRecordTypeId();
         // Insert Vehicle Entity record
        DVD_Entity__c dvdEntityVeh = new DVD_Entity__c();
        dvdEntityVeh.Plate_Number__c = '123456';
        dvdEntityVeh.Plate_Type__c = 'O';
        dvdEntityVeh.VIN_Number_or_Chassis_Number__c = 'A458';
        dvdEntityVeh.Vehicle_Check__c = 'None';
        dvdEntityVeh.RecordTypeId = rtVehId;
        dvdEntityVeh.Authorised_Service_Provider__c = ac.ID;

        insert dvdEntityVeh;
        
    }
    
    
    
      @isTest
    private static void deleteDriversFromCSVTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id dvdEntityID = [select id from DVD_Entity__c where Authorised_Service_Provider__c =:accountId and Drivers_Licence_Number__c = 'D90O909A' LIMIT 1].id;

        String fileContent = 'DRIVERS LICENCE NUMBER\r\nD90O909A';
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Integer result = BulkDeleteFleet.deleteDriversFromCSV(fileContent);
            System.assert(result == 1);
        }
        test.stopTest();
    }

    @isTest
    private static void deleteVehiclesFromCSVTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id dvdEntityID = [select id from DVD_Entity__c where Authorised_Service_Provider__c =:accountId and Plate_Number__c = '123456' LIMIT 1].id;
       String fileContent = 'PlateNumber\r\n123456';
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Integer result = BulkDeleteFleet.deleteVehiclesFromCSV(fileContent);
          
        }
        test.stopTest();
    }

}