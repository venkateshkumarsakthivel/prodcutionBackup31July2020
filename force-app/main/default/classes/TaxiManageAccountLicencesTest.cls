@isTest
public class TaxiManageAccountLicencesTest {
    
    @testSetup 
    static void testSetup(){
        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION];
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', Notice_Email__c = 'test@sample.com', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        ac.RecordTypeId = rt.Id;
        insert ac;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        
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
            accName = TaxiManageAccountLicences.getLoggedInUserAccount();
        }
        Test.stopTest();
        System.assert(accName != null);
        
    }
    
    
    
    //test for checkOpenRenewalRequest
    @isTest
    private static void checkOpenRenewalRequestPositiveTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                             End_Date__c = System.today()+20,Service_Provider__c = accountId, Status__c ='Granted');
            AuthList.add(authRec);
            AuthList.add(authRec1);
            insert AuthList;
            
            String renewalProductName = Label.Taxi_Renewal_Application_Product_Name+' '+authRec.Licence_Class__c;
            Product2 product = new Product2(Name = renewalProductName, IsActive = true);
            insert product;
            
            Pricebook2 priceBook = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);  
            insert priceBook;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = priceBook.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            String s = TaxiManageAccountLicences.checkOpenRenewalRequest(authRec.Id); 
            system.assert(s != null);
            
            String withoutClass = TaxiManageAccountLicences.checkOpenRenewalRequest(authRec1.Id);
            system.assert(withoutClass !=null);
            
        }
        Test.stopTest();
    }
    
    //test for checkOpenRenewalRequestException
    @isTest
    private static void checkOpenRenewalRequestExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            
            AuthList.add(authRec);
            
            insert AuthList;
            
            String renewalProductName = Label.Taxi_Renewal_Application_Product_Name+' '+authRec.Licence_Class__c;
            Product2 product = new Product2(Name = renewalProductName, IsActive = true);
            insert product;
            
            Pricebook2 priceBook = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);  
            insert priceBook;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = priceBook.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            String s = TaxiManageAccountLicences.checkOpenRenewalRequest(authRec.Id);
            
            System.debug('String Received is: '+s);
            System.assertEquals('0-2000.00', s);
        }
        Test.stopTest();
    }
    
    
    //test for getUserType
    @isTest
    private static void getUserTypeTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        String userType;
        Test.startTest();
        System.runAs(user) {
            userType = TaxiManageAccountLicences.getUserType();
            system.assert(userType == 'CspLitePortal');
        }
        Test.stopTest();
    }
    
    //test for getCPIPercentage
    @isTest
    private static void getCPIPercentageTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        
        String CPI;
        
        
        Test.startTest();
        System.runAs(user) {
            
            CPI = TaxiManageAccountLicences.getCPIPercentage();
            system.assert(CPI != null);
        }
        Test.stopTest();
        system.assertNotEquals('2', CPI);
    }
    
    //test for getTaxiLicenceSettings
    @isTest
    private static void getTaxiLicenceSettingsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        
        String TLS;
        Test.startTest();
        System.runAs(user) {
            TLS = TaxiManageAccountLicences.getTaxiLicenceSettings();
            system.assert(TLS != null);
        }
        Test.stopTest();
    }
    
    //test for getAuthorisationRecords
    @isTest
    private static void getAuthorisationRecordsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> ListAuths = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            for(Integer i = 0; i < 5; i++){
                Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                                End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted');
                AuthList.add(authRec);
            }
            insert AuthList;
            ListAuths = TaxiManageAccountLicences.getAuthorisationRecords('');
            System.assertEquals(5, ListAuths.size());
        }
        Test.stopTest();
      }
    
    //test for surrenderAuthorisation
    @isTest
    private static void surrenderAuthorisationTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            
            AuthList.add(authRec);
            
            insert AuthList;
            
            String s = TaxiManageAccountLicences.surrenderAuthorisation(authRec.Id);
            
            system.assert(s!=null);
        }
        Test.stopTest();
    }
    
    //test for validateAuthorisationRecord
    @isTest
    private static void validateAuthorisationRecordTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c = GlobalConstants.GRANTED_CONDITIONALLY);
            
            AuthList.add(authRec);
            
            insert AuthList;
            
            String s = TaxiManageAccountLicences.validateAuthorisationRecord(authRec.Id);
            
            System.assertNotEquals('ERROR', s);
        }
        Test.stopTest();
    }
    
    
    //test for isExistingTransferApplicationOpen
    @isTest
    private static void isExistingTransferApplicationOpenTrueTest() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c = GlobalConstants.GRANTED_CONDITIONALLY);
            
            AuthList.add(authRec);
            
            insert AuthList;
            
            Case caseRec = new Case ( Type = GlobalConstants.SERVICE_TYPE_TAXI, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER,Authorisation__c = authRec.Id,
                                     RecordTypeId = transferRecordTypeId);
            
            insert caseRec;
            Boolean s = TaxiManageAccountLicences.isExistingTransferApplicationOpen(authRec.Id);
            
            System.assertEquals(TRUE, s);
        }
        Test.stopTest();
    }
    
    
    //test for isExistingTransferApplicationOpen
    @isTest
    private static void isExistingTransferApplicationOpenFalseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c = GlobalConstants.GRANTED_CONDITIONALLY);
            
            AuthList.add(authRec);
            
            insert AuthList;
            
            Case caseRec = new Case ( Type = GlobalConstants.SERVICE_TYPE_TAXI, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER,Authorisation__c = authRec.Id,
                                     RecordTypeId = transferRecordTypeId);
            
            //insert caseRec;
            Boolean s = TaxiManageAccountLicences.isExistingTransferApplicationOpen(authRec.Id);
            
            System.assertEquals(FALSE, s);
        }
        Test.stopTest();
    }
    
    //test for getEntityType helper method
    @isTest
    private static void getEntityTypeTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            
            System.assertEquals('Company', TaxiManageAccountLicences.getEntityType());
            System.assertEquals('Individual', TaxiManageAccountLicences.getEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL));
            System.assertEquals('Individual Partner', TaxiManageAccountLicences.getEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL_PARTNERSHIP));
            System.assertEquals('Company Partner', TaxiManageAccountLicences.getEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP));
        }
        Test.stopTest();
    }
    
    @istest
    private static void checkSurrenderCasesforAuthorisationTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Test.startTest();
        System.runAs(user) {
            
            Id rtIdforTaxi = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
            Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c = GlobalConstants.GRANTED_CONDITIONALLY);
            List<Case> caselist = new List<Case>();
            List<Authorisation__c> Authlist=new List<Authorisation__c>();
            Authlist.add(authRec);
            
            
            insert AuthList;
            
            Case caseRec = new Case ( Type = GlobalConstants.SERVICE_TYPE_TAXI, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER,Authorisation__c = authRec.Id,
                                     RecordTypeId = rtIdforTaxi);
            
            //insert caseRec;
            Boolean s = TaxiManageAccountLicences.checkSurrenderCasesforAuthorisation(authRec.Id);
            
            System.assertEquals(FALSE, s);
        }
        Test.stopTest();
        
    }
    
    @istest
    private static void checkOtherSubTypeCasesforAuthorisationTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        string result;
        test.startTest();
        system.runAs(user)
        {
            
            Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c = GlobalConstants.GRANTED_CONDITIONALLY);
            insert authRec;
            result =TaxiManageAccountLicences.checkOtherSubTypeCasesforAuthorisation(authRec.Id);
            //System.debug('result is'+ result);
            system.assertEquals('NoOtherCaseExists',result);

            //Test when auth end date is within renewal period
            authRec.End_Date__c = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence) - 2);
            update authRec;
            result =TaxiManageAccountLicences.checkOtherSubTypeCasesforAuthorisation(authRec.Id);
            System.assertEquals('RequestInRenewalPeriod', result);
        } 
        test.stopTest();
     }
    
    @isTest
    private static void getAccountDataForAgentsTest(){
        Account getAccountAccess = [SELECT Id from Account];
        System.debug('Account here: '+getAccountAccess);
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id ownerid = GlobalUtility.getOwnerId();
        
        Account agentAcc = new Account(Name ='AgentAccount', BillingStreet='Agent Street', BillingCity='Sydney',
                                       BillingState='MAH', BillingPostalCode='1000',OwnerId=ownerid);
        insert agentAcc;
        Contact agentContact = new Contact(FirstName = 'Agent', LastName = 'Contact',
                                           Email = 'test@test.com', AccountId = agentAcc.Id);
        insert agentContact;
        
        
        
        
        Authorisation__c spAuth = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Full Access', Service_Provider__c = accountId,
                                                       Contact__c = conId, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth;
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforIndividual, Authorisation__c = spAuth.id);
        //c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;
        
        Case c1 = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforTaxiCorporation, Authorisation__c = spAuth.id);
        //c1.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c1;
        
        Authorisation_Agent__c aaRecord = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = agentAcc.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Full Access');
        
        insert aaRecord;
        
        Authorisation_Agent__c aaRecord1 = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = agentAcc.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Transfer Only');
        
        insert aaRecord1;
        
       
        
        Authorisation__c tempAuth = new Authorisation__c();
        tempAuth.Service_Provider__c = accountId;
        tempAuth.Application__c = c.Id;
        
        Id p = GlobalUtility.getTaxiAgentUserProfile().id;
        
        User user = new User(alias = 'agent', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = agentContact.Id ,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Id getAccountIds = [SELECT Id from Authorisation_Agent__c WHERE Authorisation__r.Service_Provider__c =: accountId LIMIT 1].Id;
        System.debug('getAccountId: '+getAccountIds);
        
        System.runAs(user){
            Id getAccountId = [SELECT Id from Authorisation_Agent__c WHERE Authorisation__r.Service_Provider__c =: accountId LIMIT 1].Id;
            System.debug('getAccountId: '+getAccountId);
            String agentAccess = TaxiManageAccountLicences.getAccountDataForAgents(spAuth.Service_Provider__c);
            System.debug('agentAccess: '+agentAccess);
            Account accountRec = (Account)JSON.deserialize(agentAccess, Account.class);
            //String a[] = JSON.
            if(agentAccess.length()!=0){
                System.assert(true);
            }
            else{
                System.assert(false);
            }
        }
    }
    
    @isTest
    private static void getAuthorisationAgentMapTest(){
        Account getAccountAccess = [SELECT Id from Account];
        System.debug('Account here: '+getAccountAccess);
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id ownerid = GlobalUtility.getOwnerId();
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        Id rtIdforTransfer = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        Account agentAcc = new Account(Name ='AgentAccount', BillingStreet='Agent Street', BillingCity='Sydney',
                                       BillingState='MAH', BillingPostalCode='1000',OwnerId=ownerid);
        insert agentAcc;
        Contact agentContact = new Contact(FirstName = 'Agent', LastName = 'Contact',
                                           Email = 'test@test.com', AccountId = agentAcc.Id);
        insert agentContact;
        Authorisation__c spAuth = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Full Access', Service_Provider__c = accountId,
                                                       Contact__c = conId, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth;
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforTransfer, Authorisation__c = spAuth.id, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER);
        //c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;
       
        Authorisation_Agent__c aaRecord = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = agentAcc.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Full Access');
        
        insert aaRecord;
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'agent', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId ,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        System.runAs(user){
            
            Map<Id, Authorisation_Agent__c> getAuthorisationAgentMap = TaxiManageAccountLicences.getAuthorisationAgentMap();
            System.debug('agentAccess: '+getAuthorisationAgentMap.size());
            System.debug('agentAccess: '+getAuthorisationAgentMap);
            System.assert(getAuthorisationAgentMap.containsKey(spAuth.Id));
        }
    }
    
    @isTest
    private static void getAuthorisationRecordsTest2() {
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert acc;
        
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
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c = authRecord.Id, Account__c = acc.Id, Status__c = 'Active');
        insert authAgent;
        
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiManageAccountLicences.getAuthorisationRecords(accId);
        Test.stopTest();
    }
}