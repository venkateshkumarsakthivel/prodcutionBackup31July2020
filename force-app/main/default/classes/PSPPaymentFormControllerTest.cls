@isTest
public class PSPPaymentFormControllerTest {
    
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
    private static void getLoggedInUserProfileTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            String resultProfile = PSPPaymentFormController.getLoggedInUserProfile();
            system.assertEquals('Taxi Licences User', resultProfile);
        }
        test.stopTest();
    }
    
    @isTest
    private static void getApplicationFeeTaxiRenewalTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.ASP_Application_Renewal_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Decimal fee = PSPPaymentFormController.getApplicationFee(c.Id, 'Renew'); 
            System.assertEquals(2000, fee);
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void getApplicationFeeBookingTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Booking',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.ASP_Application_Renewal_BSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Decimal fee = PSPPaymentFormController.getApplicationFee(c.Id, 'Renew'); 
            System.assertEquals(2000, fee);
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void getApplicationFeeTaxiAndBookingTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_BSP_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Decimal fee = PSPPaymentFormController.getApplicationFee(c.Id, 'Renew'); 
            System.assertEquals(2000, fee);
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void submitASPApplicationTaxiTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            String caseData = JSON.serialize(c);
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id, Authorisation_Type__c = 'TSP');
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            test.startTest();
            String result = PSPPaymentFormController.submitAspApplication(caseData, GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT, 'New');
            test.stopTest();
            
            system.assert(result != null);
        }
    }
    
    
    @isTest
    private static void submitASPApplicationBookingTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            String caseData = JSON.serialize(c);
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id, Authorisation_Type__c = 'TSP');
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_BSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            test.startTest();
            String result = PSPPaymentFormController.submitAspApplication(caseData, GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT, 'New');
            test.stopTest();
            
            system.assert(result != null);
        }
    }
    
    @isTest
    private static void submitASPApplicationTaxiAndBookingTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            String caseData = JSON.serialize(c);
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id, Authorisation_Type__c = 'TSP');
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_BSP_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            test.startTest();
            String result = PSPPaymentFormController.submitAspApplication(caseData, GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD, 'New');
            test.stopTest();
            
            system.assert(result != null);
            
        }
    }
    
     @isTest
    private static void updateOrderPaymentMethodTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
         
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
         
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            
            authRec.Payment_Frequency__c = 'Monthly';
            insert authRec;
            
            Order o = new Order(AccountId = accountId, EffectiveDate = system.today() -20, Status = 'Paid in Full', Authorisation__c = authRec.Id);
            insert o;
            
            Order ordObjUpdated = [SELECT BPay_Reference__c FROM Order WHERE Id =: o.Id];
            
            test.startTest();
            String result = PSPPaymentFormController.updateOrderPaymentMethod(GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD, o.Id);
            
            system.assert(result == 'Success'+','+ordObjUpdated.BPay_Reference__c);
        }
    }
    
     @isTest
    private static void submitASPApplicationExceptionTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            String caseData = JSON.serialize(c);
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_BSP_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            
            test.startTest();
            String result = PSPPaymentFormController.submitAspApplication(caseData, GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD, 'New');
            test.stopTest();
            
             system.assert(result != null);
            
        }
    }
    
    @isTest
    private static void processPaymentTest() {
     
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Related_Application__c = c.Id;
            individualContact.Contact_Type__c = 'Individual Lessee';
            
            insert individualContact;
            
            String caseData = JSON.serialize(c);
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08'
                                                         ,Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id, Authorisation_Type__c = 'TSP');
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.ASP_Application_New_BSP_TSP_Product_Name ,IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            test.startTest();
            String result = PSPPaymentFormController.submitAspApplication(caseData, GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD, 'New');
            System.assertNotEquals(NULL, PSPPaymentFormController.processPayment('New', result.split(',')[0], TRUE, c.Id));
            System.assertNotEquals(NULL, PSPPaymentFormController.updateOrderReceiptNumber(result.split(',')[0], 'R1234'));
            test.stopTest();
            
            system.assert(result != null);
            
        }
    }
}