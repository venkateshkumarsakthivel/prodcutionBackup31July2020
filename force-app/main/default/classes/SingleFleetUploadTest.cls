@isTest
private class SingleFleetUploadTest {

    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest static void saveSingleDriver_Test_Positive() {
        String reply;

        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;

        test.startTest();
        System.runAs(user) {
            reply = SingleFleetUpload.saveSingleDriver('testLastName', '12/31/1990', '12345ASD');
        }
        test.stopTest();
        System.debug(Label.SUCCESS_MESSAGE+' ===== '+reply);
        System.assertEquals(Label.SUCCESS_MESSAGE, reply);
        List<DVD_Entity__c> entities = [SELECT Id, Licence_Check__c , P2P_Offence__c , 
                                            Criminal_Check__c , Last_Name__c , 
                                            Drivers_Licence_Number__c, P2P_Eligibility__c 
                                        FROM DVD_Entity__c];
         for(DVD_Entity__c entity : entities){
             System.assert(entity.P2P_Eligibility__c == 'None');
             System.assert(entity.Licence_Check__c == 'None');
             System.assert(entity.Drivers_Licence_Number__c == '12345ASD');
         }
    }

    @isTest static void saveSingleDriver_Test_Negative() {
        String reply, reply1;

        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;

        test.startTest();
        System.runAs(user) {
            reply = SingleFleetUpload.saveSingleDriver('testLastName', '12/28/1990', '12345ASD');
            reply1 = SingleFleetUpload.saveSingleDriver('testLastName', '12/28/1990', '12345ASD');
        }
        test.stopTest();
        System.debug(Label.SUCCESS_MESSAGE+' ===== '+reply);
        System.assertEquals(Label.SUCCESS_MESSAGE, reply);        
    }
    
    @isTest static void saveSingleVehicle_Test_Positive() {
        String reply;
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;

        test.startTest();
        System.runAs(user) {
            reply = SingleFleetUpload.saveSingleVehicle('NH56G45', 'M', '1234');
        }
        test.stopTest();
        System.debug(Label.SUCCESS_MESSAGE+' ===== '+reply);
        System.assertEquals(Label.SUCCESS_MESSAGE, reply);
    }

    @isTest static void saveSingleVehicle_Test_Negative() {
        String reply, reply1;

        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                contactId = conId,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert user;

        test.startTest();
        System.runAs(user) {
            reply = SingleFleetUpload.saveSingleVehicle('NH56G45', 'M', '1234');
            reply1 = SingleFleetUpload.saveSingleVehicle('NH56G45', 'M', '1234');
        }
        test.stopTest();
        System.debug(Label.SUCCESS_MESSAGE+' ===== '+reply);
        System.assertEquals(Label.SUCCESS_MESSAGE, reply);        
    }
    
}