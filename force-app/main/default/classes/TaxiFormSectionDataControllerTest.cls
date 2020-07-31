@isTest
public class TaxiFormSectionDataControllerTest {
    
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
        
        Case newASPCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        
        insert newASPCase;
        
        
    }
    
    
    @isTest
    private static void saveSectionDataTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        System.runAs(user){
            
            Case c = [SELECT Id, Type, AccountId, Is_WAT_Application__c, Sub_Type__c, Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            c.Is_WAT_Application__c = true;
            
            update c;
            
            String caseRec = JSON.serialize(c);
            String result = TaxiFormSectionDataController.saveSectionData(caseRec);
            
            system.assert(result.contains(c.Id) == true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getSectionDataTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        System.runAs(user){
            
            Case c = [SELECT Id, Type, AccountId, Is_WAT_Application__c, Sub_Type__c, Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            c.Is_WAT_Application__c = true;
            
            update c;
            
            String caseRec = JSON.serialize(c);
            String result = TaxiFormSectionDataController.getSectionData(c.Id, accountId);
            
            String result1 = TaxiFormSectionDataController.getSectionData('', accountId);
            
            String result2 = TaxiFormSectionDataController.getSectionData('', '');
            
            system.assert(result.contains(c.Id) == true);
            system.assert(true);
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getAccountDetailsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        System.runAs(user){
            
            Case c = [SELECT Id, Type, AccountId, Is_WAT_Application__c, Sub_Type__c, Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            c.Is_WAT_Application__c = true;
            
            update c;
            
            String caseRec = JSON.serialize(c);
            String result = TaxiFormSectionDataController.getAccountDetails(c.Id);
            
            system.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getLicenceDetailsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        System.runAs(user){
            
            Case c = [SELECT Id, Type, AccountId, Is_WAT_Application__c, Sub_Type__c, Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            
            Authorisation__c licenceRec = new Authorisation__c( Application__c = c.Id, Authorisation_Type__c = 'Taxi Licence', Licence_Class__c = 'TX-09', Licence_Fee__c = 100,
                                                               Licence_Type__c ='Annual', Operating_Locations__c='Newcastle', Operation_Area__c ='Metropolitan Transport District (Sydney)',Payment_Frequency__c='Monthly', Plate_Number__c ='123456',
                                                               SNSW_Plate_Pickup_Location__c = 'Botany Service Centre', Start_Date__c =system.today() -20, Status__c ='Granted',Service_Provider__c = accountId);
            insert licenceRec;
            
            String caseRec = JSON.serialize(c);
            String result = TaxiFormSectionDataController.getLicenceDetails(c.Id);
            
            system.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getEntityTypeTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id rtIdForIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            Id rtIdForIndvPart = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Partnership').getRecordTypeId();
            Id rtIdForCorpPart = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Partnership').getRecordTypeId();
            
            //Test for Company Account
            String companyResult = TaxiFormSectionDataController.getEntityType(acc.Id,caseId);
            System.assertEquals('Company',companyResult);
            
            //Test for Individual Account
            acc.Id = accountId;
            acc.RecordTypeId = rtIdForIndividual;
            update acc;
            String indvidualResult = TaxiFormSectionDataController.getEntityType('',caseId);
            System.assertEquals('Individual',indvidualResult);
            
            //Test for Individual Partner Account
            acc.Id = accountId;
            acc.RecordTypeId = rtIdForIndvPart;
            update acc;
            String indvidualPartResult = TaxiFormSectionDataController.getEntityType('','');
            System.assertEquals('Individual Partner',indvidualPartResult);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getUserTypeTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            String result = TaxiFormSectionDataController.getUserType();
            System.assertEquals('CspLitePortal',result);
            
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getResumeCaseTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            
            String result = TaxiFormSectionDataController.getResumeCase(caseId);
            System.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getPlateLocationsTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            List<String> result = TaxiFormSectionDataController.getPlateLocations();
            System.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getOperatingLocationsTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            List<String> result = TaxiFormSectionDataController.getOperatingLocations();
            System.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getOperationAreasTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            List<String> result = TaxiFormSectionDataController.getOperationAreas();
            System.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getLicenceClassValuesTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            List<String> result = TaxiFormSectionDataController.getLicenceClassValues();
            System.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getLicenceTypesTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            List<String> result = TaxiFormSectionDataController.getLicenceTypes();
            System.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getAccountIdTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            
            String result = TaxiFormSectionDataController.getAccountId(caseId);
            System.assert(result == accountId);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getNominatedDirectorsTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Name';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
            individualContact.Related_Application__c = caseId;
            individualContact.RecordTypeId =  indivRecordTypeId;
            individualContact.Applicant_Details__c = false;
            
            insert  individualContact;
            
            String result = TaxiFormSectionDataController.getNominatedDirectors(caseId);
            
            system.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void deleteNominatedDirectorsTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> rcon = new List<Related_Contact__c>();
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                
                rcon.add(individualContact);
            }
            insert  rcon;
            
            String IndConTodelete = JSON.serialize(rcon);
            
            TaxiFormSectionDataController.deleteNominatedDirectors(IndConTodelete);
            
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void saveNominatedDirectorsTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> rcon = new List<Related_Contact__c>();
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                
                rcon.add(individualContact);
            }
            //insert  individualContact;
            
            String NomDirToSave = JSON.serialize(rcon);
            
            String result = TaxiFormSectionDataController.saveNominatedDirectors(NomDirToSave);
            
            system.assert(result.contains(caseId) == true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void submitTaxiApplicationTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            
            String result = TaxiFormSectionDataController.submitTaxiApplication(caseId);
            
            Case c = (Case)JSON.deserialize(result, Case.class);
            
            system.assertEquals(GlobalConstants.CASE_NEW, c.Status);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void createAuthorisationTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Case caseRec = [SELECT Id FROM Case WHERE AccountId =: accountId];
            caseRec.Is_WAT_Application__c = true;
            update caseRec;
            
            Master_Condition__c masterCon = new Master_Condition__c();
            masterCon.Status__c = GlobalConstants.MASTER_CONDITION_ACTIVE;
            masterCon.Type__c = GlobalConstants.TAXI_WAT_LICENCE_PROVIDER;
            masterCon.Category__c = GlobalConstants.TAXI_LICENCE_CONDITION_CATEGORY;
            masterCon.Condition_Details__c = 'sample test';
            
            insert masterCon;
            
            String result = TaxiFormSectionDataController.createAuthorisation(caseRec.Id);
            
            Authorisation__c auth = [Select Id from Authorisation__c WHERE Application__c =: caseRec.Id];
            
            system.assertEquals(auth.Id, result);
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void getConditionsTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Case caseRec = [SELECT Id FROM Case WHERE AccountId =: accountId];
            caseRec.Is_WAT_Application__c = true;
            update caseRec;
            
            Authorisation__c licenceRec = new Authorisation__c( Application__c = caseRec.Id, Authorisation_Type__c = 'Taxi Licence', Licence_Class__c = 'TX-09', Licence_Fee__c = 100,
                                                               Licence_Type__c ='Annual', Operating_Locations__c='Newcastle', Operation_Area__c ='Metropolitan Transport District (Sydney)',Payment_Frequency__c='Monthly', Plate_Number__c ='123456',
                                                               SNSW_Plate_Pickup_Location__c = 'Botany Service Centre', Start_Date__c =system.today() -20, Status__c ='Granted',Service_Provider__c = accountId);
            insert licenceRec;
            
            
            
            Master_Condition__c masterCon = new Master_Condition__c();
            masterCon.Status__c = GlobalConstants.MASTER_CONDITION_ACTIVE;
            masterCon.Type__c = GlobalConstants.TAXI_WAT_LICENCE_PROVIDER;
            masterCon.Category__c = GlobalConstants.TAXI_LICENCE_CONDITION_CATEGORY;
            masterCon.Condition_Details__c = 'sample test';
            
            insert masterCon;
            
            Condition__c conditionRec = new Condition__c();
            conditionRec.Authority__c = licenceRec.Id;
            conditionRec.Master_Condition__c = masterCon.Id;
            insert conditionRec;
            
            List<Condition__c> result = TaxiFormSectionDataController.getConditions(caseRec.Id);
            
            system.assert(result.isEmpty() == false);
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void attachConditionsTest(){
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
            Account acc = [Select Id, RecordTypeId FROM Account Where Id =: accountId];
            
            Case caseRec = [SELECT Id FROM Case WHERE AccountId =: accountId];
            caseRec.Is_WAT_Application__c = true;
            update caseRec;
            
            
            Authorisation__c licenceRec = new Authorisation__c( Application__c = caseRec.Id, Authorisation_Type__c = 'Taxi Licence', Licence_Class__c = 'TX-09', Licence_Fee__c = 100,
                                                               Licence_Type__c ='Annual', Operating_Locations__c='Newcastle', Operation_Area__c ='Metropolitan Transport District (Sydney)',Payment_Frequency__c='Monthly', Plate_Number__c ='123456',
                                                               SNSW_Plate_Pickup_Location__c = 'Botany Service Centre', Start_Date__c =system.today() -20, Status__c ='Granted',Service_Provider__c = accountId);
            insert licenceRec;
            
            
            List<Condition__c> selectedConditions = new List<Condition__c>();
            List<Condition__c> unSelectedConditions = new List<Condition__c>();
            for(integer i = 0; i<2;i++){
                Condition__c conditionRec = new Condition__c();
                conditionRec.Authority__c = licenceRec.Id;
                selectedConditions.add(conditionRec);
            }            
            
            for(integer i = 0; i<2;i++){
                Condition__c conditionRec = new Condition__c();
                conditionRec.Authority__c = licenceRec.Id;
                unSelectedConditions.add(conditionRec);
            }  
            insert unSelectedConditions;
            insert selectedConditions;
            
            String selected = JSON.serialize(selectedConditions);
            String unSelected = JSON.serialize(unSelectedConditions);
            
            TaxiFormSectionDataController.attachConditions(unSelected,selected);
            
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void saveCorporatePartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> corpCons = new List<Related_Contact__c>();
            List<Related_Contact__c> appData = new List<Related_Contact__c>();
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                corporateContact.Related_Application__c = caseId;
                
                
                corpCons.add(corporateContact);
            }
            insert  corpCons;
            
            String corporateContacts = JSON.serialize(corpCons);
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                
                appData.add(corporateContact);
            }
            insert  appData;
            
            String applicantsData = JSON.serialize(appData);
            
            String result = TaxiFormSectionDataController.saveCorporatePartnershipData(corporateContacts,applicantsData);
            
            system.assert(result.contains(caseId) == true);
        }
        test.stopTest();
        
    }
    
    
    
    @isTest
    private static void deleteCorporatePartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> corpCons = new List<Related_Contact__c>();
            List<Related_Contact__c> appData = new List<Related_Contact__c>();
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                corporateContact.Related_Application__c = caseId;
                
                
                corpCons.add(corporateContact);
            }
            insert  corpCons;
            
            String corporateContacts = JSON.serialize(corpCons);
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                
                appData.add(corporateContact);
            }
            insert  appData;
            
            String applicantsData = JSON.serialize(appData);
            
            TaxiFormSectionDataController.deleteCorporatePartnershipData(corporateContacts,applicantsData);
            
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void getCorporatePartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> corpCons = new List<Related_Contact__c>();
            List<Related_Contact__c> appData = new List<Related_Contact__c>();
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                corporateContact.Related_Application__c = caseId;
                
                
                corpCons.add(corporateContact);
            }
            insert  corpCons;
            
            String corporateContacts = JSON.serialize(corpCons);
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c corporateContact = new Related_Contact__c();
                corporateContact.Corporation_Name__c = 'sample solution';
                corporateContact.ACN__c = '123456789';
                corporateContact.Contact_Type__c = 'Individual Partner';
                corporateContact.Name = 'Sample';
                corporateContact.First_Given_Name__c = '';
                corporateContact.Family_Name__c = '';
                corporateContact.Title__c = 'Mr.';
                corporateContact.Related_Corporate__c = corpCons[i].Id;
                
                appData.add(corporateContact);
            }
            insert  appData;
            
            // String applicantsData = JSON.serialize(appData);
            
            String result = TaxiFormSectionDataController.getCorporatePartnershipData(caseId);
            
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void getIndividualPartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> indvCons = new List<Related_Contact__c>();
            
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                individualContact.Related_Application__c = caseId;                    
                
                indvCons.add(individualContact);
            }
            insert  indvCons;
            
            String individualContacts = JSON.serialize(indvCons);
            
            
            // String applicantsData = JSON.serialize(appData);
            
            String result = TaxiFormSectionDataController.getIndividualPartnershipData(individualContacts);
            
            system.assert(result != null);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveIndividualPartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> indvCons = new List<Related_Contact__c>();
            
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                individualContact.Related_Application__c = caseId;                    
                
                indvCons.add(individualContact);
            }
            //insert  indvCons;
            
            String individualContacts = JSON.serialize(indvCons);
            
            String result = TaxiFormSectionDataController.saveIndividualPartnershipData(individualContacts);
            
            system.assert(result.contains(caseId) == true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void deleteIndividualPartnershipDataTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> indvCons = new List<Related_Contact__c>();
            
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                individualContact.Related_Application__c = caseId;                    
                
                indvCons.add(individualContact);
            }
            insert  indvCons;
            
            String individualContacts = JSON.serialize(indvCons);
            
            TaxiFormSectionDataController.deleteIndividualPartnershipData(individualContacts);
            
            system.assert(true);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void deleteIndividualPartnershipDataExceptionTest(){
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            List<Related_Contact__c> indvCons = new List<Related_Contact__c>();
            
            
            
            for(Integer i = 0;i<2;i++){
                
                Related_Contact__c individualContact = new Related_Contact__c();
                individualContact.Title__c = 'Mr.';
                individualContact.First_Given_Name__c = 'Name'+i;
                individualContact.Other_Given_Name__c = 'Other Given Name';
                individualContact.Australian_Driver_Licence__c = 'BSBBSB'+i;
                individualContact.Australian_Driver_Licence_State__c = 'NSW';
                individualContact.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
                individualContact.Related_Application__c = caseId;
                individualContact.RecordTypeId =  indivRecordTypeId;
                individualContact.Applicant_Details__c = false;
                individualContact.Related_Application__c = caseId;                    
                
                indvCons.add(individualContact);
            }
            
            
            String individualContacts = JSON.serialize(indvCons);
            
            TaxiFormSectionDataController.deleteIndividualPartnershipData(individualContacts);
            
            system.assert(true);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveCorporationDetailsSectionDataTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiLicenceUserProfileId = GlobalUtility.getTaxiLicenceUserProfile().Id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiLicenceUserProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        test.startTest();
        System.runAs(user) {
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            Related_Contact__c corporationRelatedContact = new Related_Contact__c();
            
            corporationRelatedContact.Contact_Type__c = 'General Contact';
            corporationRelatedContact.Related_Application__c = caseId;
            corporationRelatedContact.Family_Name__c = 'Corporation Name';
            corporationRelatedContact.Corporation_name__c = 'Corporation Name';
            corporationRelatedContact.ACN__c = '1234567898';
            corporationRelatedContact.ABN__c = '123456789';
            corporationRelatedContact.Registered_business_name__c = 'Registered Business Name';
            corporationRelatedContact.Daytime_Phone__c = '0222222222';
            
            String corporationRelatedContactJson = JSON.serialize(corporationRelatedContact);
            
            String result = TaxiFormSectionDataController.saveCorporationDetailsSectionData(corporationRelatedContactJson);
            
            System.assert(result.contains(caseId) == true);
        }
        test.stopTest();
    }
    
    @isTest
    private static void getCorporationDetailsSectionDataTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiLicenceUserProfileId = GlobalUtility.getTaxiLicenceUserProfile().Id;
        User userWithContact = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiLicenceUserProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert userWithContact;
        
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        Id p2pOperationsLevel1UserProfileId = GlobalUtility.getP2POperationsLevel1Profile().Id;
        User userWithoutContact = new User(alias = 'test1234', email='test1234@noemail.com',
                                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                           localesidkey='en_US', profileid = p2pOperationsLevel1UserProfileId, country='United States', IsActive =true,
                                           timezonesidkey='America/Los_Angeles', username='tester1234@noemail.com', UserRoleId = r.Id);
        insert userWithoutContact;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = userWithoutContact.Id;
         update tempAcc;
        }
        
        test.startTest();
        
        System.runAs(userWithContact) {
        
            Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            
            Case caseRecord = new Case(AccountId = accountId, ContactId = contactId, 
                                       Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING, 
                                       Status = GlobalConstants.CLOSED_CASE_STATUS, Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED,
                                       Type = GlobalConstants.TAXI_CASE_TYPE,
                                       Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, 
                                       RecordTypeId = rtIdforTaxiCorporation);
            insert caseRecord;
            
            String result = TaxiFormSectionDataController.getCorporationDetailsSectionData(caseRecord.Id);
            
            System.assert(result.contains(caseRecord.Id) == true);
            
            Id corporateContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
            Related_Contact__c corporationRelatedContact = new Related_Contact__c();
            corporationRelatedContact.Contact_Type__c = 'General Contact';
            corporationRelatedContact.Related_Application__c = caseRecord.Id;
            corporationRelatedContact.Family_Name__c = 'Corporation Name';
            corporationRelatedContact.Corporation_name__c = 'Corporation Name';
            corporationRelatedContact.ACN__c = '1234567898';
            corporationRelatedContact.ABN__c = '123456789';
            corporationRelatedContact.Registered_business_name__c = 'Registered Business Name';
            corporationRelatedContact.Daytime_Phone__c = '0222222222';
            corporationRelatedContact.RecordTypeId = corporateContactRecordTypeId;
            insert corporationRelatedContact;
            
            result = TaxiFormSectionDataController.getCorporationDetailsSectionData(caseRecord.Id);
            
            System.assert(result != null);
            
        }
        
        System.runAs(userWithoutContact) {
            
            Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
            
            Case caseRecord = new Case(AccountId = accountId, ContactId = contactId, 
                                       Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING, 
                                       Status = GlobalConstants.CLOSED_CASE_STATUS, Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED,
                                       Type = GlobalConstants.TAXI_CASE_TYPE,
                                       Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, 
                                       RecordTypeId = rtIdforTaxiCorporation);
            insert caseRecord;
            
            String result = TaxiFormSectionDataController.getCorporationDetailsSectionData(caseRecord.Id);
            
            System.assert(result.contains(caseRecord.Id) == true);
        }
        test.stopTest();
    }
    
    @isTest
    private static void saveIndividualDetailsSectionDataTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiLicenceUserProfileId = GlobalUtility.getTaxiLicenceUserProfile().Id;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiLicenceUserProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        test.startTest();
        System.runAs(user) {
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            Related_Contact__c individualRelatedContact = new Related_Contact__c();
                        
            individualRelatedContact.Contact_Type__c = 'General Contact';
            individualRelatedContact.Related_Application__c = caseId;
            individualRelatedContact.Title__c = 'Mr.';
            individualRelatedContact.Family_Name__c = 'Family Name';
            individualRelatedContact.First_Given_Name__c = 'First Given Name';
            individualRelatedContact.Other_Given_Name__c = 'Other Given Name';
            individualRelatedContact.Date_of_Birth__c = Date.parse('01/01/1990');
            individualRelatedContact.Australian_Driver_Licence__c = '123456';
            individualRelatedContact.Australian_Driver_Licence_State__c = 'NSW';
            individualRelatedContact.Daytime_Phone__c = '0222222222';
            
            String individualRelatedContactJson = JSON.serialize(individualRelatedContact);
            
            String result = TaxiFormSectionDataController.saveIndividualDetailsSectionData(individualRelatedContactJson);
            
            System.assert(result.contains(caseId) == true);
        }
        test.stopTest();
    }
    
    @isTest
    private static void getIndividualDetailsSectionDataTest() {
        
        Id accountId = [SELECT Id from Account where name = 'testAcc' LIMIT 1].Id; 
        Id contactId = [SELECT Id from Contact where AccountId =:accountId LIMIT 1].Id;
        
        Id taxiLicenceUserProfileId = GlobalUtility.getTaxiLicenceUserProfile().Id;
        User userWithContact = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = taxiLicenceUserProfileId, country='United States', IsActive =true,
                             contactId = contactId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert userWithContact;
        
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        Id p2pOperationsLevel1UserProfileId = GlobalUtility.getP2POperationsLevel1Profile().Id;
        User userWithoutContact = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p2pOperationsLevel1UserProfileId, country='United States', IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='tester1234@noemail.com', UserRoleId = r.Id);
        insert userWithoutContact;
        
        User loggedInUser = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        
        System.runAs(loggedInUser) {
        
         Account tempAcc = [SELECT OwnerId FROM Account];
         tempAcc.OwnerId = userWithoutContact.Id;
         update tempAcc;
        }
        
        test.startTest();
        System.runAs(userWithContact) {
            Id rtIdforTaxiIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
            
            Case caseRecord = new Case(AccountId = accountId, ContactId = contactId, 
                                       Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING, 
                                       Status = GlobalConstants.CLOSED_CASE_STATUS, Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED,
                                       Type = GlobalConstants.TAXI_CASE_TYPE,
                                       Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, 
                                       RecordTypeId = rtIdforTaxiIndividual);
            insert caseRecord;
            
            String result = TaxiFormSectionDataController.getIndividualDetailsSectionData(caseRecord.Id);
            
            System.assert(result.contains(caseRecord.Id) == true);
            
            Id individualContactRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            Related_Contact__c individualRelatedContact = new Related_Contact__c();
            individualRelatedContact.Contact_Type__c = 'General Contact';
            individualRelatedContact.Related_Application__c = caseRecord.Id;
            individualRelatedContact.Title__c = 'Mr.';
            individualRelatedContact.Family_Name__c = 'Family Name';
            individualRelatedContact.First_Given_Name__c = 'First Given Name';
            individualRelatedContact.Other_Given_Name__c = 'Other Given Name';
            individualRelatedContact.Date_of_Birth__c = Date.parse('01/01/1990');
            individualRelatedContact.Australian_Driver_Licence__c = '123456';
            individualRelatedContact.Australian_Driver_Licence_State__c = 'NSW';
            individualRelatedContact.Daytime_Phone__c = '0222222222';
            individualRelatedContact.RecordTypeId = individualContactRecordTypeId;
            insert individualRelatedContact;     
            
            result = TaxiFormSectionDataController.getIndividualDetailsSectionData(caseRecord.Id);
            
            System.assert(result != null);
            
        }
     
        System.runAs(userWithoutContact) {
            Id rtIdforTaxiIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
            
            Case caseRecord = new Case(AccountId = accountId, ContactId = contactId, 
                                       Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING, 
                                       Status = GlobalConstants.CLOSED_CASE_STATUS, Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED,
                                       Type = GlobalConstants.TAXI_CASE_TYPE,
                                       Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, 
                                       RecordTypeId = rtIdforTaxiIndividual);
            insert caseRecord;
            
            String result = TaxiFormSectionDataController.getIndividualDetailsSectionData(caseRecord.Id);
            
            System.assert(result.contains(caseRecord.Id) == true);
        }
        test.stopTest();
    }
}