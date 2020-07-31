@isTest
private class BulkFleetLoaderTest {
    
    //static String driversFile, vehiclesFile;
    @testSetup 
    static void createASPUserAndAccount(){
         Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest static void testParseDrivers() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;
        
        List<DVD_Entity__c> fleet;
        String fileContent = 'lastname,dob,licence\r\nScott,01/21/1980,D909P09A\r\nTotts,09/24/1982,D909810A\r\nPotts,01/05/1977,D950911A';
        test.startTest();
        System.runAs(user) {
            BulkFleetLoader bfl = new BulkFleetLoader(fileContent, DVDEntityBuilder.DVDEntityType.DRIVER);
            fleet = bfl.parseDrivers();
        }
        test.stopTest();
        
        
        System.assert(fleet.size() == 3, 'Incorrect size parsed');
    }
    
    @isTest static void testParseVehicles() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;
        
        List<DVD_Entity__c> fleet;
        String fileContent = 'PlateNumber,PlateType,ChassisNumber\r\n123456,O,A458\r\n980765,M,J458\r\n67487,M,437A';
        test.startTest();
        System.runAs(user) {
            BulkFleetLoader bfl = new BulkFleetLoader(fileContent, DVDEntityBuilder.DVDEntityType.VEHICLE);
            fleet = bfl.parseVehicles();
        }
        test.stopTest();
       
        System.assert(fleet.size() == 3, 'Incorrect size parsed');
    }

    @isTest static void testExecute() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;
        
        List<DVD_Entity__c> fleet;
        String fileContent = 'lastname,dob,licence\r\nScott,02/22/1980,D90909OA\r\nTotts,11/10/1982,D909P10A\r\nPotts,02/05/1977,D904911A';
        test.startTest();
        System.runAs(user) {    
            BulkFleetLoader bfl = new BulkFleetLoader(fileContent, DVDEntityBuilder.DVDEntityType.DRIVER);
            bfl.execute();
            fleet = [SELECT Id FROM DVD_Entity__c];
        }
        test.stopTest();
        
        system.assertEquals(3,fleet.size());
        
    }
    
}