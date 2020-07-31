@isTest
public class UnsuspendTaxiLicenseControllerTest {
    
    @testSetup
    private static void setupTestData()
    {
     
        
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
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
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
        
        string invalidauth;
        
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester92@noemail.com', UserRoleId = r.Id);
        System.debug('profile id is' + user.ProfileId);
        
        insert user;
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        Test.startTest();
        System.runAs(user){
            //----Authorisation is valid--
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            
            system.debug('auth inserted');
            
            result = UnsuspendTaxiLicenseController.validateAuthorisationRecord(taxiAuth.Id);
            System.assertEquals('SUCCESS', result);
            
            //---- Authorisation is invalid--
            Authorisation__c taxiAuthIvalidProfile = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                          Contact__c = conId, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            
            
            invalidauth = UnsuspendTaxiLicenseController.validateAuthorisationRecord(taxiAuthIvalidProfile.Id);
            System.assertEquals(null, invalidauth);
        }
        Test.stopTest();
    }
    @isTest
    private static void createUnsuspensionCaseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester93@noemail.com',UserRoleId = u.Id);
        insert user;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        Test.startTest();
        System.runAs(user){
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_SUSPENDED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            
            Authorisation__c TX03taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_SUSPENDED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert TX03taxiAuth;
            
            Authorisation__c TX03WATtaxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03WAT',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_SUSPENDED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return',
                                                                   Paired_License__c = TX03taxiAuth.Id);
            insert TX03WATtaxiAuth;
            
            TX03taxiAuth.Paired_License__c = TX03WATtaxiAuth.Id;
            update TX03taxiAuth;
            
            result = UnsuspendTaxiLicenseController.createUnsuspensionCase(taxiAuth.Id);
            System.debug('result '+result);
            
            Authorisation__c updatetaxiAuth = [Select Id, Request_Type__c from Authorisation__c where Id=:taxiAuth.Id];
            System.assertEquals('Unsuspend', updatetaxiAuth.Request_Type__c);
            
            if(result.contains('C-')){
               System.assert(true); 
            }else{
                System.assert(false); 
            }
            
            String TX03WATresult = UnsuspendTaxiLicenseController.createUnsuspensionCase(TX03WATtaxiAuth.Id);
            System.debug('TX03WATresultresult '+TX03WATresult);
            
            Authorisation__c TX03WATupdatetaxiAuth = [Select Id, Request_Type__c from Authorisation__c where Id=:TX03WATtaxiAuth.Id];
            System.assertEquals('Unsuspend', TX03WATupdatetaxiAuth.Request_Type__c);
            
            if(TX03WATresult.contains('C-')){
               System.assert(true); 
            }else{
                System.assert(false); 
            }
            
            String TX03result = UnsuspendTaxiLicenseController.createUnsuspensionCase(TX03taxiAuth.Id);
            System.debug('TX03resultresult '+TX03result);
            
            Authorisation__c TX03updatetaxiAuth = [Select Id, Request_Type__c from Authorisation__c where Id=:TX03taxiAuth.Id];
            System.assertEquals('Unsuspend', TX03updatetaxiAuth.Request_Type__c);
            
            if(TX03result.contains('C-')){
               System.assert(true); 
            }else{
                System.assert(false); 
            }
        
        }
        Test.stopTest();
    }
    
    @isTest
    private static void InValidateProfileTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_1];
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester94@noemail.com', UserRoleId = r.Id);
        insert user;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        Test.startTest();
        System.runAs(user){
            //----Authorisation is valid--
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            string invalidprofile;
            invalidprofile = UnsuspendTaxiLicenseController.validateAuthorisationRecord(taxiAuth.Id);
            System.assertEquals('ERROR', invalidprofile);
        }
        Test.stopTest();
    }
}