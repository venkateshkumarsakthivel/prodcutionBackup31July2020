@isTest
public class TaxiLicenceCancellationControllerTest {
    @testSetup
    private static void setupTestData()
    {
        /* Using this record type for Case creation---*/
        
        Id ownerid = GlobalUtility.getOwnerId();
        /* Account created------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert ac;
        
        /* Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /*---Authorisation related to Account--*/
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  );
        
        insert taxiAuth;
    }
    
    @isTest
    private static void ValidateAuthorisationTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        string result;
        string invalidresult;
        string invalidprofile;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester72@noemail.com', UserRoleId = r.Id);
        System.debug('profile id is' + user.ProfileId);
        insert user;
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        Authorisation__c taxiAuthIvalidProfile = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                      Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
        
        
        invalidprofile = TaxiLicenceCancellationController.validateAuthorisationRecord(taxiAuthIvalidProfile.Id);
        System.assertNotEquals('SUCCESS', invalidprofile);
        
        Test.startTest();
        System.runAs(user){
            //----Authorisation is valid--
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            
            system.debug('auth inserted');
            result = TaxiLicenceCancellationController.validateAuthorisationRecord(taxiAuth.Id);
            System.assertEquals('SUCCESS', result);
            
            //---- Authorisation is invalid--
            
        }
        Test.stopTest();
    }
    
    @isTest
    private static void createTaxiLicenceCancellationCaseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester73@noemail.com',UserRoleId = u.Id);
        insert user;
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        Test.startTest();
        System.runAs(user){
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            List<String> reasons = new List<String>();
            reasons =TaxiLicenceCancellationController.fetchCancelationReasonsMPicklist();
            // system.debug('reasons are' + reasons);
            string fetchreason;
            for( String c : reasons)
            {
                fetchreason = reasons.get(1);
            }
            
            result = TaxiLicenceCancellationController.createTaxiLicenceCancellationCase(taxiAuth.Id ,fetchreason);
            system.debug('result is' + result);
            System.assert(result.startsWith('C-'));
        }
    }
    @isTest
    private static void getAuthorisationTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester74@noemail.com');
        
        insert user;
        
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
        insert taxiAuth;
        result = TaxiLicenceCancellationController.getAuthorisation(taxiAuth.Id);
        System.debug('getauthorisation is' + result);
        System.assertNotEquals(null, result);
        
    }
    @isTest
    private static void createTaxiLicenceCancellationCaseTX03WATTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester75@noemail.com',UserRoleId = u.Id);
        insert user;
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        Test.startTest();
        System.runAs(user){
            Authorisation__c taxiAuthTX03 = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                 Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            
            insert taxiAuthTX03; 
            
            Authorisation__c taxiAuthTX03WAT = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03WAT',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                    Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            
            insert taxiAuthTX03WAT;  
            taxiAuthTX03.Paired_License__c = taxiAuthTX03WAT.Id;
            update taxiAuthTX03;
            taxiAuthTX03WAT.Paired_License__c= taxiAuthTX03.Id;
            update taxiAuthTX03WAT;
            
            List<String> reasons = new List<String>();
            reasons =TaxiLicenceCancellationController.fetchCancelationReasonsMPicklist();
            
            string fetchreason;
            for( String c : reasons)
            {
                fetchreason = reasons.get(1);
            }
            result= TaxiLicenceCancellationController.createTaxiLicenceCancellationCaseTX03WAT( taxiAuthTX03WAT.Id,fetchreason);
            System.debug('taxiAuthTX03WAT is' +result );
            System.assert(result.startsWith('C-'));
        }
    }
    
}