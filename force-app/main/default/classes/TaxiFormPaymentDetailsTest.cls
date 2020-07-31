@isTest
public class TaxiFormPaymentDetailsTest {
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
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            String resultProfile = TaxiFormPaymentDetails.getLoggedInUserProfile();
            system.assertEquals('Taxi Licences User', resultProfile);
        }
        test.stopTest();
    }
    
    @isTest
    private static void getApplicationFeeTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Decimal fee = TaxiFormPaymentDetails.getApplicationFee(c.Id, 'Renew'); 
            System.assertEquals(2000, fee);
            
            fee = TaxiFormPaymentDetails.getApplicationFee(c.Id, GlobalConstants.NEW_APPLICATION_TYPE); 
            System.assertEquals(100, fee); 
                            
        }
        test.stopTest();
    }
    
    
    @isTest 
    private static void getTaxiTransferLevyDueAmountTest(){
   
         Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
         Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
         Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
                
        insert user;
                
        Case case1 = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS ,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION);
   
        case1.All_Applicant_Verification__c = 'Verified';
        case1.Corporation_Verification__c = 'Verified';
        case1.Director_Manager_Verification__c = 'Verified';
        case1.Individual_Verification__c = 'Verified';
        case1.Individual_Verification__c = 'Verified';
            
        insert case1;
            
        Case buyercase = new Case(AccountId = accountId, Levy_Due__c=100,Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,ParentId=case1.Id);
            insert buyercase;
        
         System.runAs(user){
              Case parentcase = [SELECT Id FROM Case WHERE Id =: case1.Id];
             String parentcaseId=parentcase.Id;
             test.startTest();
             Decimal levy_due=TaxiFormPaymentDetails.getTaxiTransferLevyDueAmount(parentcaseId);
             test.stopTest();
             system.assert(levy_due==100);
         }
    }
    
    
    @isTest
    private static void updateOrderPaymentMethodTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
       insert user;
        
       System.runAs(user) {
             
        Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Case case1 = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS  , Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,RecordTypeId = recordTypeId);
        
        case1.All_Applicant_Verification__c = 'Verified';
        case1.Corporation_Verification__c = 'Verified';
        case1.Director_Manager_Verification__c = 'Verified';
        case1.Individual_Verification__c = 'Verified';
            
        insert case1;
             
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
        Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
        
        authRec.Payment_Frequency__c = 'Monthly';
        insert authRec;
            
        Order order=new Order(Status='Paid in Full',Previous_Payment_Status__c='Payment Due',AccountId =accountId,EffectiveDate=system.today(),Application__c=case1.Id,
                              Receipt_Number__c='12345', Amount_Paid__c=100, Authorisation__c = authRec.Id);
        insert order;
             
        String orderId = order.Id;
          
        String paymentmethod = 'BPay';
             
        Test.startTest();
        TaxiFormPaymentDetails.updateOrderPaymentMethod(paymentmethod,orderId);
        Test.stopTest();
             
        Order testorder = [select Id,Payment_Method__c from Order where Id=: order.Id];
        system.assert(testorder.Payment_Method__c=='BPay');
             
       } 
    }
    
    
    @isTest
    private static void submitTaxiTransferApplicationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION);
        
        c.All_Applicant_Verification__c = 'Verified';
        c.Corporation_Verification__c = 'Verified';
        c.Director_Manager_Verification__c = 'Verified';
        c.Individual_Verification__c = 'Verified';
        c.Individual_Verification__c = 'Verified';
        
        insert c;
        
        System.runAs(user){
            
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
        insert auth;
        
         Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
        
          Order order=new Order(Status='Paid in Full',Previous_Payment_Status__c='Payment Due',AccountId =accountId,EffectiveDate=system.today(),Application__c=c.Id,
                             Receipt_Number__c='12345',Amount_Paid__c=100,Authorisation__c=auth.Id);
            insert order;
        
            String productNameToOperate = Label.Taxi_Transfer_Levy_Product_Name;
            Product2 product = new Product2(Name = productNameToOperate,IsActive = true);
            insert product;
            
                       
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
               test.startTest();
                    TaxiFormPaymentDetails.submitTaxiTransferApplication(c.Id,'BPay',0);
               test.stopTest();
        }
        
        
        Case testcase=[select Id,Sub_Status__c from Case where Id=: c.Id];
        System.assert(testcase.Sub_Status__c== GlobalConstants.PENDING_PAYMENT_SUB_STATUS);
    }
  
     
    @isTest
    private static void submitTaxiApplicationForNewAndCashMonthlyTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
        
            insert c;
            String caseData = JSON.serialize(c);
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = c.Id;
            insert individualContact;
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = 'Monthly', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
            auth.RecordTypeId = taxiAuthorisationRecordTypeId;
            auth.Authorisation_Type__c = 'Taxi Licence';
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            
            test.startTest();
            String str2 = TaxiFormPaymentDetails.submitTaxiApplication(caseData, 'Cash', 'New', 2000);
            System.assertEquals(TRUE, str2.contains(','));
            test.stopTest();
        }
    }
    
    @isTest
    private static void submitTaxiApplicationForRenewAndCashMonthlyTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
        
            insert c;
            
            String caseData = JSON.serialize(c);
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = c.Id;
            insert individualContact;
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today().addDays(-80), Payment_Frequency__c = 'Monthly', End_Date__c = system.today().addDays(-20),Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
            auth.RecordTypeId = taxiAuthorisationRecordTypeId;
            auth.Authorisation_Type__c = 'Taxi Licence';
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Product2 renewalProduct = new Product2(Name = Label.Taxi_Renewal_Application_Product_Name+' TX-08',IsActive = true);
            insert renewalProduct;
            
            PricebookEntry renewalPricebookEntrystd = new  PricebookEntry(Product2Id = renewalProduct.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert renewalPricebookEntrystd;
            
            PricebookEntry renewalPricebookEntry = new  PricebookEntry(Product2Id = renewalProduct.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert renewalPricebookEntry;
            
            
            Test.startTest();
            String str = TaxiFormPaymentDetails.submitTaxiApplication(caseData, GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT, GlobalConstants.RENEWAL_APPLICATION_TYPE, 2000);
            String str1 = TaxiFormPaymentDetails.submitTaxiApplication(caseData, 'Cash', GlobalConstants.RENEWAL_APPLICATION_TYPE, 2000);
            System.assertEquals(TRUE, str.contains(','));
            System.assertEquals(TRUE, str1.contains(','));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void submitTaxiApplicationForNewAndCashTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
        
            insert c;
            String caseData = JSON.serialize(c);
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = c.Id;
            insert individualContact;
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = '', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
            auth.RecordTypeId = taxiAuthorisationRecordTypeId;
            auth.Authorisation_Type__c = 'Taxi Licence';
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            
            test.startTest();
            String str2 = TaxiFormPaymentDetails.submitTaxiApplication(caseData, 'Cash', 'New', 2000);
            System.assertEquals(TRUE, str2.contains(','));
            test.stopTest();
        }
    }
    
    @isTest
    private static void submitTaxiApplicationForRenewAndCashTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
        
            insert c;
            
            String caseData = JSON.serialize(c);
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = c.Id;
            insert individualContact;
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today().addDays(-80), Payment_Frequency__c = '', End_Date__c = system.today().addDays(-20),Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
            auth.RecordTypeId = taxiAuthorisationRecordTypeId;
            auth.Authorisation_Type__c = 'Taxi Licence';
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            Product2 renewalProduct = new Product2(Name = Label.Taxi_Renewal_Application_Product_Name+' TX-08',IsActive = true);
            insert renewalProduct;
            
            PricebookEntry renewalPricebookEntrystd = new  PricebookEntry(Product2Id = renewalProduct.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert renewalPricebookEntrystd;
            
            PricebookEntry renewalPricebookEntry = new  PricebookEntry(Product2Id = renewalProduct.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert renewalPricebookEntry;
            
            
            Test.startTest();
            String str = TaxiFormPaymentDetails.submitTaxiApplication(caseData, GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT, GlobalConstants.RENEWAL_APPLICATION_TYPE, 2000);
            String str1 = TaxiFormPaymentDetails.submitTaxiApplication(caseData, 'Cash', GlobalConstants.RENEWAL_APPLICATION_TYPE, 2000);
            System.assertEquals(TRUE, str.contains(','));
            System.assertEquals(TRUE, str1.contains(','));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void processPaymentTest() {
    
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p, country='Australia', IsActive =true,
                             contactId = conId,
                             timezonesidkey='Australia/Sydney', username='tester@noemail.com');
        
        insert user;
        
        System.runAs(user){
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            
            c.All_Applicant_Verification__c = 'Verified';
            c.Corporation_Verification__c = 'Verified';
            c.Director_Manager_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
            c.Individual_Verification__c = 'Verified';
        
            insert c;
            String caseData = JSON.serialize(c);
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = c.Id;
            insert individualContact;
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Start_Date__c = system.today() - 80, Payment_Frequency__c = '', End_Date__c = system.today() - 20,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, Contact__c = conId, Application__c = c.Id);
            Id taxiAuthorisationRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
            auth.RecordTypeId = taxiAuthorisationRecordTypeId;
            auth.Authorisation_Type__c = 'Taxi Licence';
            insert auth;
            
            
            Pricebook2 pb = new Pricebook2(Name = Label.ASP_Pricebook, IsActive = true);
            insert pb;
            
            
            Product2 product = new Product2(Name = Label.Taxi_Licence_Fee_Product_Name+' Annual',IsActive = true);
            insert product;
            
            PricebookEntry pricebookEntrystd = new  PricebookEntry(Product2Id = product.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 2000, IsActive = true, UseStandardPrice = false);
            insert pricebookEntrystd;
            
            PricebookEntry pricebookEntry = new  PricebookEntry(Product2Id = product.Id, Pricebook2Id = pb.Id, UnitPrice = 2000, IsActive = true, UseStandardPrice = true);
            insert pricebookEntry;
            
            
            Test.startTest();
            String str2 = TaxiFormPaymentDetails.submitTaxiApplication(caseData, GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD, 'New', 2000);
            System.assertEquals(TRUE, str2.contains(','));
            System.assertNotEquals(NULL, TaxiFormPaymentDetails.processPayment('New', str2.split(',')[0], TRUE, c.Id));
            Test.stopTest();
     }
   }
}