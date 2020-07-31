@isTest
public class TaxiLicenceSurrenderControllerTest {
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
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX03WAT',Licence_Type__c='Annual', Licence_Fee__c = 100,
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  );
        
        insert taxiAuth;
    }
    @isTest
    private static void validateAuthorisationRecordTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        string result;
        
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester82@noemail.com', UserRoleId = r.Id);
        
        insert user;
        User loggedInUser1 = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser1) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        Test.startTest();
        
        
        System.runAs(user){
            Authorisation__c taxiAuthNoLicense = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03WAT',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                  Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE , Paired_License__c = null);
        
        system.debug('auth is '+ taxiAuthNoLicense);
        insert taxiAuthNoLicense;
        
        result  = TaxiLicenceSurrenderController.validateAuthorisationRecord(taxiAuthNoLicense.Id);
        System.assertEquals('NoPairedLicense', result);
        
            
            //----Authorisation is valid--
            Taxi_Class__mdt config = [SELECT Licence_Class__c, Licence_Type__c,Renew_Months__c
                                    FROM Taxi_Class__mdt
                                    WHERE Is_Renewable__c = 'Yes'
                                    AND Max_Years__c > 0 AND Is_WAT__c = 'No' LIMIT 1];
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = config.Licence_Class__c,Licence_Type__c=config.Licence_Type__c, Licence_Fee__c = 100, 
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth;
            
            // system.debug('auth inserted');
            result = TaxiLicenceSurrenderController.validateAuthorisationRecord(taxiAuth.Id);
            System.assertEquals('SUCCESS', result);

            //Test when auth end date is within renewal period
            taxiAuth.End_Date__c = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence) - 2);
            update taxiAuth;
            result = TaxiLicenceSurrenderController.validateAuthorisationRecord(taxiAuth.Id);
            System.assertEquals('RequestInRenewalPeriod', result);

          }
        
        Test.stopTest();
        
    }
    @isTest
    private static void validateAuthorisationRecordExceptionTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        Profile failureProfile = [SELECT Id FROM Profile WHERE Name = 'P2P Compliance'];
        
        string result;
        
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester83@noemail.com', UserRoleId = r.Id);
        
        insert user;
        
        User failureUser = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = failureProfile.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester84@noemail.com', UserRoleId = r.Id);
        
        insert failureUser;
        
        User loggedInUser1 = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser1) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = failureUser.Id;
         update tempAcc;
        }
       
        Test.startTest();
        
        System.runAs(failureUser){
         
         Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
         insert taxiAuth;
         
         result  = TaxiLicenceSurrenderController.validateAuthorisationRecord(taxiAuth.Id);
         System.assertEquals('InvalidProfileUser', result);
        }
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        
        System.runAs(user){
            
            Authorisation__c taxiAuth1 = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                              Contact__c = conId, Status__c = null, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
            insert taxiAuth1;
            
            
            result = TaxiLicenceSurrenderController.validateAuthorisationRecord(taxiAuth1.Id);
            System.assertEquals('InvalidAuthorisationRecord', result);
        }
        Test.stopTest();
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
                             timezonesidkey='Australia/Sydney', username='tester85@noemail.com');
        
        insert user;
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Request_Type__c = 'Return');
        insert taxiAuth;
        result = TaxiLicenceSurrenderController.getAuthorisation(taxiAuth.Id);
        System.debug('getauthorisation is' + result);
        System.assertNotEquals(null, result);
        
    }
    @isTest
    private static void createTaxiLicenceSurrenderCaseTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester86@noemail.com',UserRoleId = u.Id);
        insert user;
        string invalidAuthId= null;
        result= TaxiLicenceSurrenderController.createTaxiLicenceSurrenderCase(invalidAuthId);
        System.assertEquals('ERROR',result);
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        Test.startTest();
        System.runAs(user){
            Authorisation__c taxiAuth1 = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                              Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            insert taxiAuth1;   
            result= TaxiLicenceSurrenderController.createTaxiLicenceSurrenderCase(taxiAuth1.Id);
            System.assert(result.startsWith('C-'));
        }
    }
    @isTest
    private static void createTaxiLicenceSurrenderCaseTX03WATTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester87@noemail.com',UserRoleId = u.Id);
        
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
            
            string reason;
            result= TaxiLicenceSurrenderController.createTaxiLicenceSurrenderCaseTX03WAT( taxiAuthTX03WAT.Id,reason);
            //System.debug('taxiAuthTX03WAT is' +result );
            System.assert(result.startsWith('C-'));
        }
    }
    @isTest
    private static void createTaxiLicenceSurrenderCaseFromPortalTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
        string result;
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester88@noemail.com',UserRoleId = u.Id);
        
        insert user;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
        Test.startTest();
        System.runAs(user){
            Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03',Licence_Type__c='Annual', Licence_Fee__c = 100,
                                                             Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            insert taxiAuth; 
            String platesReturned = 'true';
            date dt= system.today();
           //String SurrenderDate = dt.format("YYYY-MM-DD");
            String SurrenderDate = Datetime.now().format('yyyy-MM-dd');
            result= TaxiLicenceSurrenderController.createTaxiLicenceSurrenderCaseFromPortal(taxiAuth.Id,SurrenderDate);
            System.debug('result is' +result);
            System.assert(result.startsWith('C-'));
        }
    }
    @isTest
    private static void getAuthorisationPaymentCalculationTest()
    {        Id accountId  = [select id from Account where name = 'testAcc' LIMIT 1].id; 
     Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
     Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
     UserRole u = [select Id from UserRole where Name = 'Director - Operations'];
     
     User user = new User(alias = 'test1234', email='test1234@noemail.com',
                          emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                          localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                          timezonesidkey='Australia/Sydney', username='tester89@noemail.com',UserRoleId = u.Id);
     insert user;
     User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = user.Id;
         update tempAcc;
        }
     Test.startTest();
     System.runAs(user){
         Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX03WAT',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                          Contact__c = conId, Status__c = GlobalConstants.AUTHORISATION_GRANTED , Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE , Payment_Frequency__c = 'Monthly');
         
         insert taxiAuth; 
         Order order = new Order(Name ='Test Order', AccountId = accountId, Authorisation__c =  taxiAuth.Id, Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' ,EffectiveDate=system.today());
         insert order;
         
         List<String> orders =new List<String>();
         orders=TaxiLicenceSurrenderController.getAuthorisationPaymentCalculation(taxiAuth.Id);
         System.debug('orders list is' + orders);
         System.assertEquals(3, orders.size());
     }
    }
    
    @isTest
    private static void createSurrenderCaseFromAgentPortalTest() {
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account acc = [SELECT Id, Name, ACN__c FROM Account LIMIT 1];
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Email='test@contest.com');
        insert con;
        
        Id individualTaxiCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case newTaxiCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        
        Id taxiAuthRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Authorisation__c authRecord = new Authorisation__c(Plate_Number__c = '11111', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord.Application__c = newTaxiCase.Id;
        insert authRecord;
        
        Test.startTest();
        TaxiLicenceSurrenderController.createSurrenderCaseFromAgentPortal(authRecord.Id);
        Test.stopTest();
    }
    
}