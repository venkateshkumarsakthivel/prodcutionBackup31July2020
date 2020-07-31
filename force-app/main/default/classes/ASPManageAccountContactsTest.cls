@isTest
private class ASPManageAccountContactsTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com',Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE);
        insert con;
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,Status__c = GlobalConstants.STATUS_ACTIVE);
            //taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
            insert taxPayerData;
    }
    
    // tax payer record details
     @isTest
    private static void TPRrecordTest2() {
           ASPManageAccountContacts.getTaxPayerRegistrationRecord();     
    }
    //deactivate contact
    @isTest
    private static void deactivateContactTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        //Id TaxpayerId= [select Id,Service_Provider_Name__c from Tax_Payer_Registration__c where Service_Provider_Name__c=:accountId LIMIT 1].ID;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        List<Contact> contactsToBeDeactivated = new List<Contact>();
        
        Case caseRecord = null;
        List<Related_Contact__c> deactivatedRelatedContacts = new List<Related_Contact__c>();
        List<Id> idsToDeactivate = new List<Id> {conId};
       
            test.startTest();
        system.runAs(user){
            ASPManageAccountContacts.deactivateContact(idsToDeactivate);
            System.assertEquals(1, idsToDeactivate.size());
          }
        test.stopTest();
        User con = [SELECT IsActive FROM User WHERE ContactId =:conId];
        //system.assertNotEquals(false, con.IsActive);
    }
    
    @isTest
    private static void deactivateContactTest2() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Contact con = [select id, Email, LastName, Primary_Contact__c, Contact_Type__c from contact where AccountId =:accountId LIMIT 1];
        con.Primary_Contact__c = true;
        con.Contact_Type__c = '';
        update con;
        Contact con2 = new Contact(LastName ='testCon',AccountId = accountId, Email='test@contest.com', Primary_Contact__c = true);
        insert con2;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        List<Contact> contactsToBeDeactivated = new List<Contact>();
        
        Case caseRecord = null;
        List<Related_Contact__c> deactivatedRelatedContacts = new List<Related_Contact__c>();
        List<Id> idsToDeactivate = new List<Id> {con.Id, con2.Id};
            
        test.startTest();
        system.runAs(user){
            ASPManageAccountContacts.deactivateContact(idsToDeactivate);
        }
        test.stopTest();
    }
    
    @isTest
    private static void deactivateContactTest3() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Contact con = [select id, Email, LastName, Primary_Contact__c, Contact_Type__c from contact where AccountId =:accountId LIMIT 1];
        con.Primary_Contact__c = true;
        con.Contact_Type__c = '';
        update con;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        List<Contact> contactsToBeDeactivated = new List<Contact>();
        
        Case caseRecord = null;
        List<Related_Contact__c> deactivatedRelatedContacts = new List<Related_Contact__c>();
        List<Id> idsToDeactivate = new List<Id> {con.Id};
            
        test.startTest();
        system.runAs(user){
            ASPManageAccountContacts.deactivateContact(idsToDeactivate);
        }
        test.stopTest();
    }
    
    //deactivate contact for exceptions
    @isTest
    private static void deactivateContactcheckExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        List<Id> idsToDeactivate = new List<Id>();
        test.startTest();
        system.runAs(user){
            ASPManageAccountContacts.deactivateContact(idsToDeactivate); 
        }
        test.stopTest();
        
        User con = [SELECT IsActive FROM User WHERE ContactId =:conId];
        system.assertEquals(true, con.IsActive);
    }
    
    //get contacts
    @isTest
    private static void getContactsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        List<Contact> contacts = new List<Contact>();
        
        Contact c = new Contact(LastName = 'Test Contact', AccountId = accountId, Description = 'contacts for testing');
        contacts.add(c);
        insert contacts;
        
        List<Contact> retrivedcontacts = new List<Contact>();
        test.startTest();
        system.runAs(user){
            retrivedcontacts =  ASPManageAccountContacts.getContacts(); 
        }
        test.stopTest();
        system.assertEquals(2, retrivedcontacts.size());
    }
    
    
    @isTest
    private static void updateContactTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account',OwnerId=ownerid);
        
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing', Is_Access_Level_DVD_Administrator__c = False);
        insert ct; 
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        ct.Is_Access_Level_DVD_Administrator__c = true;
        
               
        test.startTest();
        system.runAs(user){

        String massage;
            massage =  ASPManageAccountContacts.updateContact(ct);
             system.assertNotEquals('Contact updated successfully.', massage);
            
        }
        test.stopTest();
         //system.assertEquals('Contact updated successfully.', massage);
       
    }
    
    @isTest
    private static void updateContactTest2() {
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account',OwnerId=ownerid);
        
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing', Is_Access_Level_DVD_Administrator__c = False);
        insert ct;
        
        Contact ct2 = new Contact(LastName = 'Test Contact2', Email = 'test@gmail.com', AccountId = act.Id, Description = 'contacts for testing', Is_Access_Level_DVD_Administrator__c = False, Primary_Contact__c = true);
        insert ct2;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
               
        test.startTest();
        system.runAs(user){

        String massage;
            massage =  ASPManageAccountContacts.updateContact(ct);            
        }
        test.stopTest();
    }
    
    @isTest
    private static void updateContactTest3() {
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account',OwnerId=ownerid);
        
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing', Is_Access_Level_DVD_Administrator__c = False);
        insert ct;
        
        Contact ct2 = new Contact(LastName = 'Test Contact2', Email = 'test@gmail.com', AccountId = act.Id, Description = 'contacts for testing', Is_Access_Level_DVD_Administrator__c = False, Primary_Contact__c = true);
        insert ct2;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
               
        test.startTest();
        system.runAs(user){

        String massage;
            massage =  ASPManageAccountContacts.updateContact(ct);            
        }
        test.stopTest();
    }
    
    
    @isTest
    private static void updateContactExceptionTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account act = new Account(Name = 'Test Account', OwnerId=ownerid);
        insert act;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing');
        insert ct; 
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = ct.Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String massage;
        Contact cont = new Contact();
        test.startTest();
        system.runAs(user){
            massage =  ASPManageAccountContacts.updateContact(cont);
        }
        test.stopTest();
        system.assertEquals(null, massage);
    }
    
    @isTest
    private static void getLoggedInUserAccountTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User usr;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        system.runAs(user){
            usr = ASPManageAccountContacts.getLoggedInUserAccount();
        }
        system.assertEquals(user.LastName, usr.Name);
    }
    
    
    @isTest
    private static void isAtLeastOneContactHasNSWAddressTrueTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        List<Contact> contacts = new List<Contact>();
        Boolean flag;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conid,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = accountId, Contact_Type__c='Nominated Director/Manager', MailingState='NSW',  Description = 'contacts for testing');
        contacts.add(ct);
        insert contacts;
        
        test.startTest();
        system.runAs(user){
            flag = ASPManageAccountContacts.isAtLeastOneContactHasNSWAddress(); 
        }
        test.stopTest();
        
        List<Contact> insertedContacts = [SELECT Id, MailingState from Contact where Contact_Type__c = 'Nominated Director/Manager' AND MailingState = 'NSW'];
        System.assertEquals(insertedContacts.size() > 0, flag);
    }
    
    @isTest
    private static void isAtLeastOneContactHasNSWAddressFalseTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        List<Contact> contacts = new List<Contact>();
        Boolean flag;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conid,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Contact ct = new Contact(LastName = 'Test Contact', AccountId = accountId, Description = 'contacts for testing');
        contacts.add(ct);
        insert contacts;
        
        test.startTest();
        system.runAs(user){
            flag = ASPManageAccountContacts.isAtLeastOneContactHasNSWAddress(); 
        }
        test.stopTest();
        
        List<Contact> insertedContacts = [SELECT Id, MailingState from Contact where Contact_Type__c = 'Nominated Director/Manager' AND MailingState = 'NSW'];
        System.assertEquals(insertedContacts.size() > 0, flag);
    }
    
    
    @isTest
    private static void getContactForEditTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        String strIds = conId;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        test.startTest();
        system.runAs(user){
            Contact con = ASPManageAccountContacts.getContactForEdit(strIds);
            System.assertEquals('testCon', con.LastName);
        }
        test.stopTest();
    }
    
    
    
    
    /*@isTest
private static void getNominatedDirectorsCountTest(){
List<Contact> contacts = new List<Contact>{};
AggregateResult re;
Account act = new Account(Name = 'Test Account');
insert act;

Contact c = new Contact(LastName = 'Test Contact', AccountId = act.Id, Description = 'contacts for testing', Contact_Type__c = 'Nominated Director/Manager');
contacts.add(c);
insert contacts;

Id p = GlobalUtility.getASPProfile().id;

User user = new User(alias = 'test123', email='test123@noemail.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_US', profileid = p, country='United States', IsActive =true,
contactId = contacts[0].id,
timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

insert user;

test.startTest();
system.runAs(user){
re = ASPManageAccountContacts.getNominatedDirectorsCount();            
}
test.stopTest();
system.assertEquals(1, re.get('expr0'));
}*/
    
    @isTest
    private static void submitHelpRequestTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        String str;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Case caseRec = new case(AccountId = accountId, ContactId = conId, Status = 'New');
        
        test.startTest();
        system.runAs(user){                    
            str = ASPManageAccountContacts.submitHelpRequest(caseRec);
        }
        test.stopTest();
        Case caseRecdetails = [SELECT Id, CaseNumber from Case where AccountId =:accountId];
        system.assertEquals(caseRecdetails.CaseNumber, str);
        
    }
    
    
    @isTest
    private static void submitHelpRequestExceptionTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        String str;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        Case caseRec;
        
        test.startTest();
        system.runAs(user){                    
            str = ASPManageAccountContacts.submitHelpRequest(caseRec);
        }
        test.stopTest();
        
        system.assertEquals(null, str);
        
    }
    
    @isTest
    private static void getAccountDataForAgentsTest() {
        
        Test.startTest();
        ASPManageAccountContacts.getAccountDataForAgents('123456');
        Test.stopTest();
    }
    
    @isTest
    private static void getAccountDataForAgentsTest2() {
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
        ASPManageAccountContacts.getAccountDataForAgents(accId);
        Test.stopTest();
    }
    
    @isTest
    private static void getContactsForAgentsTest() {
        
        Test.startTest();
        ASPManageAccountContacts.getContactsForAgents('123456');
        Test.stopTest();
    }
    
    @isTest
    private static void getContactsForAgentsTest2() {
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
        ASPManageAccountContacts.getContactsForAgents(accId);
        Test.stopTest();
    }
    
    
    
}