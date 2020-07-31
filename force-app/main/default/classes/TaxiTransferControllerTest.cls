@isTest
public class TaxiTransferControllerTest {
    
    @testSetup 
    static void setup(){
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation, OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
        
    }
    
    @isTest
    private static void getAuthorisationRecordTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Authorisation__c authRec = TaxiTransferController.getAuthorisationRecord(auth.Id);
            System.assert(authRec.Service_Provider__c == accountId);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void getAuthorisationRecordExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Application__c = c.Id);
            
            Authorisation__c authRec = TaxiTransferController.getAuthorisationRecord(auth.Id);
            System.assert(authRec == null);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void getTaxiTransferApplicationDetailsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            Case caseRec = [Select Id from Case where Id =: c.Id];
            caseRec.Id = c.Id;
            caseRec.Authorisation__c = auth.Id;
            caseRec.Transfer_Reason__c = 'Estate';
            caseRec.Licence_Fee_Due__c = 100;
            caseRec.Is_Privacy_Statement_Declared__c = true;
            caseRec.Beneficiary_Type__c ='Individual';
            upsert caseRec;
            
            String caseRecord = TaxiTransferController.getTaxiTransferApplicationDetails(caseRec.Id);
            system.assert(caseRecord != null);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void getTaxiTransferApplicationDetailsExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            //insert c;
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Application__c = c.Id);
            insert auth;
            
            String caseRecord = TaxiTransferController.getTaxiTransferApplicationDetails(c.Id);
            system.assert(caseRecord == null);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void getLicenceMarketValueAndLevyDueTaxiTransferTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            insert sellerCase;
            
            Case buyerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                      ,ParentId = sellerCase.Id,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            
            insert buyerCase;
            
            String caseRecord = TaxiTransferController.getLicenceMarketValueAndLevyDueTaxiTransfer(sellerCase.Id);
            system.assert(caseRecord != null);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void getRelatedContactsDataTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            
            List<Related_Contact__c> individualPartners = new List<Related_Contact__c>();
            List<Related_Contact__c> corporatePartners = new List<Related_Contact__c>();
            
            
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted');
            // insert authRec;
            
            
            //Create Case Record
            Case caseRecordIndv = new Case();
            caseRecordIndv.Subject = 'New lease request for taxi licence';
            caseRecordIndv.Status = 'Lodged';
            caseRecordIndv.Sub_Status__c = 'Review Pending';
            caseRecordIndv.Type = 'Taxi';
            caseRecordIndv.Sub_Type__c = 'Register Lease Arrangement';
            // caseRecordIndv.Authorisation__c = authRec.Id;
            
            insert caseRecordIndv;
            
            //Create Case Record
            Case caseRecordCorp = new Case();
            caseRecordCorp.Subject = 'New lease request for taxi licence';
            caseRecordCorp.Status = 'Lodged';
            caseRecordCorp.Sub_Status__c = 'Review Pending';
            caseRecordCorp.Type = 'Taxi';
            caseRecordCorp.Sub_Type__c = 'Register Lease Arrangement';
            // caseRecordCorp.Authorisation__c = authRec.Id;
            
            insert caseRecordCorp;
            
            
            //Create Case Record
            Case caseRecordJH = new Case();
            caseRecordJH.Subject = 'New lease request for taxi licence';
            caseRecordJH.Status = 'Lodged';
            caseRecordJH.Sub_Status__c = 'Review Pending';
            caseRecordJH.Type = 'Taxi';
            caseRecordJH.Sub_Type__c = 'Register Lease Arrangement';
            // caseRecordJH.Authorisation__c = authRec.Id;
            
            insert caseRecordJH;
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            individualContact.Related_Application__c = caseRecordIndv.Id;
            insert individualContact;
            
            //Create Related contact for corporate
            Related_Contact__c corporateContact = new Related_Contact__c();
            corporateContact.Corporation_Name__c = 'sample solution';
            corporateContact.ACN__c = '123456789';
            corporateContact.Contact_Type__c = 'Corporate Lessee';
            corporateContact.Name = 'Sample';
            corporateContact.First_Given_Name__c = '';
            corporateContact.Family_Name__c = '';
            corporateContact.Title__c = 'Mr.';
            corporateContact.Related_Application__c = caseRecordCorp.Id;
            insert corporateContact;
            
            //Create Related contact for Joint Holders
            for(integer i = 0; i<3; i++){
                Related_Contact__c individualContacts = new Related_Contact__c();
                individualContacts.Title__c = 'Mr.';
                individualContacts.First_Given_Name__c = 'Sample';
                individualContacts.Other_Given_Name__c = 'Other Given Name' + i;
                individualContacts.Australian_Driver_Licence__c = 'BSBBSB7';
                individualContacts.Australian_Driver_Licence_State__c = 'NSW';
                individualContacts.Contact_Type__c = 'Individual Lessee';
                individualContacts.Related_Application__c = caseRecordJH.Id;
                individualPartners.add(individualContacts);
                
            }
            
            for(integer i = 0; i<3; i++){
                Related_Contact__c corporateContacts = new Related_Contact__c();
                corporateContacts.Corporation_Name__c = 'sample solutions';
                corporateContacts.ACN__c = '123456789';
                corporateContacts.Contact_Type__c = 'Corporate Lessee';
                corporateContacts.Name = 'Sample'+i;
                corporateContacts.First_Given_Name__c = '';
                corporateContacts.Family_Name__c = '';
                corporateContacts.Title__c = 'Mr.';
                corporateContacts.Related_Application__c = caseRecordJH.Id;
                corporatePartners.add(corporateContacts);
            }
            insert individualPartners;
            insert corporatePartners;
            
            
            String IndvCons = TaxiTransferController.getRelatedContactsData(caseRecordIndv.Id, 'Individual');
            String CorpCons = TaxiTransferController.getRelatedContactsData(caseRecordCorp.Id, 'Corporation');
            String JHCons = TaxiTransferController.getRelatedContactsData(caseRecordJH.Id, 'Joint-Holders');
            
            System.assert(IndvCons != Null);
            System.assert(CorpCons != Null);
            System.assert(JHCons != Null);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveLicenceTransferDataIndvTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            insert sellerCase;
            
            Case buyerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                      ,ParentId = sellerCase.Id,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            
            insert buyerCase;
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted',
                                                            Application__c = sellerCase.Id);
            insert authRec;
            
            
            
            //Create Related contact for individual
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'Individual Lessee';
            insert individualContact;
            
            String indvCon = JSON.serialize(individualContact);
            String sellerRec = JSON.serialize(sellerCase);
            String buyerRec = JSON.serialize(buyerCase);
            
            String str = TaxiTransferController.saveLicenceTransferData(sellerRec, buyerRec, 'Individual', indvCon, '', '', '', authRec.Id);            
            System.assert(str == sellerCase.Id);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveLicenceTransferDataCorpTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            insert sellerCase;
            
            Case buyerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                      ,ParentId = sellerCase.Id,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            
            insert buyerCase;
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted',
                                                            Application__c = sellerCase.Id);
            insert authRec;
            
            
            
            //Create Related contact for corporate
            Related_Contact__c corporateContact = new Related_Contact__c();
            corporateContact.Corporation_Name__c = 'sample solution';
            corporateContact.ACN__c = '123456789';
            corporateContact.Contact_Type__c = 'Corporate Lessee';
            corporateContact.Name = 'Sample';
            corporateContact.First_Given_Name__c = '';
            corporateContact.Family_Name__c = '';
            corporateContact.Title__c = 'Mr.';
            insert corporateContact;
            
            String corpCon = JSON.serialize(corporateContact);
            String sellerRec = JSON.serialize(sellerCase);
            String buyerRec = JSON.serialize(buyerCase);
            
            String str = TaxiTransferController.saveLicenceTransferData(sellerRec, buyerRec, 'Corporation', '', corpCon, '', '', authRec.Id);            
            System.assert(str == sellerCase.Id);
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void saveLicenceTransferDataJHTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Related_Contact__c> individualPartners = new List<Related_Contact__c>();
            List<Related_Contact__c> corporatePartners = new List<Related_Contact__c>();
            
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            insert sellerCase;
            
            Case buyerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                      ,ParentId = sellerCase.Id,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase);
            
            insert buyerCase;
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted',
                                                            Application__c = sellerCase.Id);
            insert authRec;
            
            
            
            //Create Related contact for Joint Holders
            for(integer i = 0; i<3; i++){
                Related_Contact__c individualContacts = new Related_Contact__c();
                individualContacts.Title__c = 'Mr.';
                individualContacts.First_Given_Name__c = 'Sample';
                individualContacts.Other_Given_Name__c = 'Other Given Name' + i;
                individualContacts.Australian_Driver_Licence__c = 'BSBBSB7';
                individualContacts.Australian_Driver_Licence_State__c = 'NSW';
                individualContacts.Contact_Type__c = 'Individual Lessee';
                individualPartners.add(individualContacts);
                
            }
            
            for(integer i = 0; i<3; i++){
                Related_Contact__c corporateContacts = new Related_Contact__c();
                corporateContacts.Corporation_Name__c = 'sample solutions';
                corporateContacts.ACN__c = '123456789';
                corporateContacts.Contact_Type__c = 'Corporate Lessee';
                corporateContacts.Name = 'Sample'+i;
                corporateContacts.First_Given_Name__c = '';
                corporateContacts.Family_Name__c = '';
                corporateContacts.Title__c = 'Mr.';
                corporatePartners.add(corporateContacts);
            }
            insert individualPartners;
            insert corporatePartners;
            
            String indvCons = JSON.serialize(individualPartners);
            String corpCons = JSON.serialize(corporatePartners);
            String sellerRec = JSON.serialize(sellerCase);
            String buyerRec = JSON.serialize(buyerCase);
            
            String str = TaxiTransferController.saveLicenceTransferData(sellerRec, buyerRec, 'Joint-Holders', '', '',indvCons,corpCons, authRec.Id);            
            System.assert(str == sellerCase.Id);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveTransferPrivacyStatementTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase, Is_Privacy_Statement_Declared__c = true);
            // insert sellerCase;
            
            String sellerRec = JSON.serialize(sellerCase);
            
            String caseRecord = TaxiTransferController.saveTransferPrivacyStatement(sellerRec);
            system.assert(caseRecord != null);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void updateSellerAndBuyerCaseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id rtIdForSellerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdForBuyerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdForSellerCase, Is_Privacy_Statement_Declared__c = true);
            // insert sellerCase;
            
            String sellerRec = JSON.serialize(sellerCase);
            
            String result = TaxiTransferController.updateSellerAndBuyerCase(sellerRec);
            system.assert(result == 'Success');
        }
        test.stopTest();        
    }
    
    
    @isTest
    private static void isExistingTransferApplicationOpenTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        System.runAs(user){
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = accountId, Status__c ='Granted');
            insert authRec;
            
            
            Case sellerCase = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                                       ,Type = GlobalConstants.SERVICE_TYPE_TAXI ,Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER, RecordTypeId = transferRecordTypeId, Authorisation__c = authRec.Id);
            insert sellerCase;
            
            Boolean result = TaxiTransferController.isExistingTransferApplicationOpen(authRec.Id);
            system.assert(result == false);
        }
        test.stopTest();        
    }
    
    @isTest
    private static void createAttachmentsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id contactId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id profileId = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        test.startTest();
        System.runAs(user){
            Case caseRecord = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New');
            insert caseRecord;
            
            List<Attachment> attachments = new List<Attachment>();
            Attachment attachment1 = new Attachment();
            attachment1.ParentId = caseRecord.Id;
            attachment1.Name = 'test 1';
            attachment1.Description = 'Sample Description 1';
            attachment1.Body = EncodingUtil.base64Decode('Sample Content 1');
            attachments.add(attachment1);
            
            Attachment attachment2 = new Attachment();
            attachment2.ParentId = caseRecord.Id;
            attachment2.Name = 'test 2';
            attachment2.Description = 'Sample Description 2';
            attachment2.Body = EncodingUtil.base64Decode('Sample Content 2');
            attachments.add(attachment2);
            
            insert attachments;
            
            List<String> attachmentIds = new List<String>();
            attachmentIds.add(attachments[0].Id);
            attachmentIds.add(attachments[1].Id);
            
            TaxiTransferController.createAttachments(attachmentIds, caseRecord.Id);
                
            List<Attachment> addedAttachments = [SELECT Id, Name FROM Attachment WHERE parent.id =:caseRecord.Id];
            System.assertEquals(addedAttachments.size(), 2);
        }
        test.stopTest();
    }
}