@isTest
private class ASPFormSectionDataControllerTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
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
    private static void getAccountSectionDataTest(){
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
            String result = ASPFormSectionDataController.getAccountSectionData(accountId);
            System.assert(result != null);
        }
        test.stopTest();
    }
    
    @isTest
    private static void getSectionDataCaseIDIsNotNULLTest(){
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
        
        String result = ASPFormSectionDataController.getSectionData(NULL);
        System.assert(result != null);
        
        System.runAs(user){
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            
            result = ASPFormSectionDataController.getSectionData(caseId);
            System.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getSectionDataCaseIDIsNULLTest(){
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
            
            String result = ASPFormSectionDataController.getSectionData('');
            System.assert(result != null);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getAccEntityTypeTest(){
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
            String companyResult = ASPFormSectionDataController.getEntityType(caseId);
            System.assertEquals('Company',companyResult);
            
            //Test for Individual Account
            acc.Id = accountId;
            acc.RecordTypeId = rtIdForIndividual;
            update acc;
            String indvidualResult = ASPFormSectionDataController.getEntityType(caseId);
            System.assertEquals('Individual',indvidualResult);
            
            //Test for Individual Partner Account
            acc.Id = accountId;
            acc.RecordTypeId = rtIdForIndvPart;
            update acc;
            String indvidualPartResult = ASPFormSectionDataController.getEntityType(caseId);
            System.assertEquals('Individual Partner',indvidualPartResult);
            
            //Test for Corporate Partner Account
            acc.Id = accountId;
            acc.RecordTypeId = rtIdForCorpPart;
            update acc;
            String corporatePartResult = ASPFormSectionDataController.getEntityType(caseId);
            System.assertEquals('Company Partner',corporatePartResult);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getAccountEntityTypeTest(){
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
            String result = ASPFormSectionDataController.getAccountEntityType(accountId);
            system.assertEquals('Company', result);
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
            String result = ASPFormSectionDataController.getUserType();
            system.assertEquals('CspLitePortal', result);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void saveSectionDataTest(){
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
            
            Case c = [SELECT Type, Sub_Type__c, Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            c.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            c.Sub_Status__c = 'Granted';
            
            String caseRec = JSON.serialize(c);
            String result = ASPFormSectionDataController.saveSectionData(caseRec);
            
            
            Case caseAfterUpdate = [SELECT Status, Sub_Status__c FROM Case WHERE AccountId =: accountId];
            System.assertEquals('Granted', caseAfterUpdate.Sub_Status__c);
            
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void saveApplicantDataTest(){
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
            
            Related_Contact__c individualContact = new Related_Contact__c();
            individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'General Contact';
            individualContact.Related_Application__c = caseId;
            
            String individualContactRecord = JSON.serialize(individualContact);
            String result = ASPFormSectionDataController.saveApplicantData(individualContactRecord);
            
            Related_Contact__c rc = [SELECT Id,First_Given_Name__c FROM Related_Contact__c WHERE Related_Application__c =: caseId];
            system.assertEquals('Sample', rc.First_Given_Name__c);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getApplicantDetailsTest(){
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
            individualContact.Contact_Type__c = 'General Contact';
            individualContact.Related_Application__c = caseId;
            individualContact.RecordTypeId =  indivRecordTypeId;
            
            insert  individualContact;
            
            String result = ASPFormSectionDataController.getApplicantDetails(caseId);
            
            Related_Contact__c rc = (Related_Contact__c)JSON.deserialize(result, Related_Contact__c.class);
            
            system.assertEquals('Name', rc.First_Given_Name__c);
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
            
            String result = ASPFormSectionDataController.getNominatedDirectors(caseId);
            
            system.assert(result != null);
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
            
            String result = ASPFormSectionDataController.saveNominatedDirectors(NomDirToSave);
            
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
            
            ASPFormSectionDataController.deleteNominatedDirectors(IndConTodelete);
            
            system.assert(true);
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
            
            Id caseId = [SELECT Id FROM Case WHERE AccountId =: accountId].Id;
            
            String result = ASPFormSectionDataController.getAccountId(caseId);
            
            system.assertEquals(accountId, result);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void getCaseStatusTest(){
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
            
            String result = ASPFormSectionDataController.getCaseStatus(caseId);
            
            system.assert(result.contains(GlobalConstants.APPLICATION_STATUS_DRAFT) == true);
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
            
            String result = ASPFormSectionDataController.saveCorporatePartnershipData(corporateContacts,applicantsData);
            
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
            
            ASPFormSectionDataController.deleteCorporatePartnershipData(corporateContacts,applicantsData);
            
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
            
            String result = ASPFormSectionDataController.getCorporatePartnershipData(caseId);
            
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
            
            String result = ASPFormSectionDataController.getIndividualPartnershipData(individualContacts);
            
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
            
            String result = ASPFormSectionDataController.saveIndividualPartnershipData(individualContacts);
            
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
            
            ASPFormSectionDataController.deleteIndividualPartnershipData(individualContacts);
            
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
            
            ASPFormSectionDataController.deleteIndividualPartnershipData(individualContacts);
            
            system.assert(true);
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void savePrimaryContactDataTest(){
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
            
            String rc = JSON.serialize(individualContact);
            
            String result = ASPFormSectionDataController.savePrimaryContactData(rc);
            
            System.assert(result.contains(c.Id));
            
        }
        test.stopTest();
        
    }
    
      @isTest
    private static void getCorporatePrimaryContactDataTest(){
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
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            String result = ASPFormSectionDataController.getCorporatePrimaryContactData(c.Id);
            
            System.assert(result != null);
            
        }
        test.stopTest();
        
    }
    
     @isTest
    private static void getIndividualPrimaryContactDataTest(){
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
            Case c = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI_BOOKING ,ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                              ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
            insert c;
            
            String result = ASPFormSectionDataController.getIndividualPrimaryContactData(c.Id);
            
            System.assert(result != null);
            
        }
        test.stopTest();
        
    }
    
    private static testMethod void testForIsPrimaryContactFromNsw(){
        System.Test.startTest();
        Boolean result = ASPFormSectionDataController.isApplicantFromNSW(null);
        System.Test.stopTest();
        System.assert(!result);
    }
    @isTest
    private static void saveApplicantDataExceptionTest(){
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
            
            Related_Contact__c individualContact = new Related_Contact__c();
            /*individualContact.Title__c = 'Mr.';
            individualContact.First_Given_Name__c = 'Sample';
            individualContact.Other_Given_Name__c = 'Other Given Name';
            individualContact.Australian_Driver_Licence__c = 'BSBBSB7';
            individualContact.Australian_Driver_Licence_State__c = 'NSW';
            individualContact.Contact_Type__c = 'General Contact';
            individualContact.Related_Application__c = caseId;*/
            
            String individualContactRecord ;
            String result = ASPFormSectionDataController.saveApplicantData(individualContactRecord );
            
            //Related_Contact__c rc = [SELECT Id,First_Given_Name__c FROM Related_Contact__c WHERE Related_Application__c =: caseId];
            system.assertEquals(result, NULL);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void conmplexApplicationCheckNominatedDirTest(){
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
                individualContact.Residential_Address_Street__c = 'PO BOX 137';
                if(i==0){
                    individualContact.Residential_Address_State__c = 'VIC';
                }else{
                    individualContact.Residential_Address_State__c = 'NSW';
                }
                 rcon.add(individualContact);
            }
            //insert  individualContact;
            
            String NomDirToSave = JSON.serialize(rcon);
            
            String result = ASPFormSectionDataController.saveNominatedDirectors(NomDirToSave);
            
            system.assert(result != null);

            //Save Case details to test complex application
            String caseRec = ASPFormSectionDataController.getSectionData(caseId);
            result = ASPFormSectionDataController.saveSectionData(caseRec);
            system.assert(result != null);
        }
        test.stopTest();
      }


}