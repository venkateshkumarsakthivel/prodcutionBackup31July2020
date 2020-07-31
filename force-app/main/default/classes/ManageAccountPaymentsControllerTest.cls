@isTest
public class ManageAccountPaymentsControllerTest {
    
    @testSetup 
    static void setup(){
        Id rtIdforIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Partnership').getRecordTypeId();
        Id rtIdforCompany = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc',RecordTypeId = rtIdforIndividual, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Account ac2 = new Account(name ='testAcc2',RecordTypeId = rtIdforCompany, BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac2;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac2.Id, Email='test2@contest.com');
        insert con2; 
        
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert acc;
        
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
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c = authRecord.Id, Account__c = acc.Id, Status__c = 'Active');
        insert authAgent;
    }
    
    
        // test for getLoggedInUserAccount
    @isTest
    private static void getLoggedInUserAccountTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        String accName;
        Test.startTest();
        System.runAs(user) {
            accName = ManageAccountPaymentsController.getLoggedInUserAccount();
        }
        Test.stopTest();
        System.assert(accName != null);
        
    }
    
    
    @isTest
    private static void getPendingPaymentsForAccountASPTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String payments;
        Test.startTest();
        System.runAs(user) {
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
            insert c;
            
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
            insert authRec;
            
            Order o = new Order(Name = 'Sample name', Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_DUE_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
            
            payments = ManageAccountPaymentsController.getPendingPaymentsForAccountASP();
            
        }
        Test.stopTest();
        System.assert(payments != null);
        
    }

@isTest
    private static void getPaidPaymentsForAccountASPTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String payments;
        Test.startTest();
        System.runAs(user) {
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
            insert c;
            
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
            insert authRec;
            
            Order o = new Order(Name = 'Sample name', Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
            
            payments = ManageAccountPaymentsController.getPaidPaymentsForAccountASP();
            
        }
        Test.stopTest();
        System.assert(payments != null);
        
    } 
    
    @isTest
    private static void getPendingPaymentsForAccountTaxiTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String payments;
        Test.startTest();
        System.runAs(user) {
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
            insert c;
            
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
            insert authRec;
            
            Order o = new Order(Name = 'Sample name', Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_REJECTED_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
            
            payments = ManageAccountPaymentsController.getPendingPaymentsForAccountTaxi();
            
        }
        Test.stopTest();
        System.assert(payments != null);
        
    } 
    
     @isTest
    private static void getPaidPaymentsForAccountTaxiTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String payments;
        Test.startTest();
        System.runAs(user) {
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
            insert c;
            
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
            insert authRec;
            
            Order o = new Order(Name = 'Sample name', Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
            
            payments = ManageAccountPaymentsController.getPaidPaymentsForAccountTaxi();
            
        }
        Test.stopTest();
        System.assert(payments != null);
        
    } 
    
    @isTest
    private static void checkCustomerEnquiryCaseCreatedTest() {
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Enquiry').getRecordTypeId();
        Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'Lodged', RecordTypeId = rtIdforCorporation);
        insert c;
        
        Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
        insert authRec;
        
        Order o = new Order(Name = 'Sample name', AccountId = accountId, Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
        insert o;
        
        c.Payment__c = o.Id;
        update c;
        
        Test.startTest();
        ManageAccountPaymentsController.checkCustomerEnquiryCaseCreated(o.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void checkCustomerEnquiryCaseCreatedTest2() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Enquiry').getRecordTypeId();
        Case c = new Case(AccountId = AccountId, Service_Type__c = 'Taxi', Status = 'Lodged', RecordTypeId = rtIdforCorporation);
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();

        insert c;
        Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted', Application__c = c.Id);
            
        insert authRec;
        
        Order o = new Order(Name = 'Sample name', AccountId = accountId, Authorisation__c = authRec.Id, EffectiveDate = system.today() - 80, Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS, Application__c = c.Id, Payment_Method__c = 'Cash');
        insert o;
                
        Test.startTest();
        ManageAccountPaymentsController.checkCustomerEnquiryCaseCreated(o.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void ManageAccountPaymentsControllerTest() {
        
        Test.startTest();
        ManageAccountPaymentsController.getAccountDataForAgents('123456');
        Test.stopTest();
    }
    
    @isTest
    private static void ManageAccountPaymentsControllerTest2() {
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        ManageAccountPaymentsController.getAccountDataForAgents(accId);
        Test.stopTest();
    }
    
    @isTest
    private static void getPendingPaymentsForAgentsTaxiTest() {
        
        Test.startTest();
        ManageAccountPaymentsController.getPendingPaymentsForAgentsTaxi('123456');
        Test.stopTest();
    }
    
    @isTest
    private static void getPendingPaymentsForAgentsTaxiTest2() {
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        ManageAccountPaymentsController.getPendingPaymentsForAgentsTaxi(accId);
        Test.stopTest();
    }
    
    @isTest
    private static void getPaidPaymentsForAgentsTaxiTest() {
        
        Test.startTest();
        ManageAccountPaymentsController.getPaidPaymentsForAgentsTaxi('123456');
        Test.stopTest();
    }
    
    @isTest
    private static void getPaidPaymentsForAgentsTaxiTest2() {
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        ManageAccountPaymentsController.getPaidPaymentsForAgentsTaxi(accId);
        Test.stopTest();
    }
    
    @isTest
    private static void getAgentsPaymentsMapTest() {
        
        Test.startTest();
        ManageAccountPaymentsController.getAgentsPaymentsMap('123456');
        Test.stopTest();
    }
}