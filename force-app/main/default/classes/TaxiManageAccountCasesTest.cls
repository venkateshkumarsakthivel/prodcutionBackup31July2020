@isTest
private class TaxiManageAccountCasesTest {
    @testSetup 
    static void setup(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(Name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void getLoggedInUserAccountTest(){
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
        system.runAs(user){
            String str = TaxiManageAccountCases.getLoggedInUserAccount();
            system.assert(str != null);
        }
        test.stopTest();
        
    }
    
    
    @isTest
    private static void getNoticeDetailsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        String jsonString;
        Test.startTest();
        System.runAs(user) {
            jsonString = TaxiManageAccountCases.getNoticeDetails('');
        }
        Test.stopTest();
        List<Notice_Record__c> notices = ( List<Notice_Record__c>)JSON.deserialize(jsonString,  List<Notice_Record__c>.class);
        System.assert(notices.isEmpty());
    }
    
    @isTest
    private static void getApplicationCasesTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        String jsonString;
        List<Case> listCases = new List<Case>();
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        
        Test.startTest();
        System.runAs(user) {
            List<Case> caseList = new List<Case>();
            for(Integer i = 0; i < 5; i++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforCorporation);
                caseList.add(c);
            }
            for(Integer j = 0; j < 5; j++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforIndividual);
                caseList.add(c);
            }
            insert caseList;
            
            jsonString = TaxiManageAccountCases.getApplicationCases();
            listCases = (List<Case>)JSON.deserialize(jsonString, List<Case>.class);
            System.assertEquals(10, listCases.size());
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void cancelTaxiApplicationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforIndividual);
        c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;
        
        Authorisation__c tempAuth = new Authorisation__c();
        tempAuth.Service_Provider__c = accountId;
        tempAuth.Application__c = c.Id;
        
        insert tempAuth;
        
        System.runAs(user) {
            
            c = [SELECT Sub_Type__c FROM Case WHERE Id = :c.Id];
            Test.startTest();
            System.assertEquals(NULL, TaxiManageAccountCases.cancelTaxiApplication(NULL));
            System.assertNotEquals(NULL, TaxiManageAccountCases.cancelTaxiApplication(c));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void withdrawTaxiApplicationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforIndividual);
        c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
        insert c;
        
        Authorisation__c tempAuth = new Authorisation__c();
        tempAuth.Service_Provider__c = accountId;
        
        insert tempAuth;
        
        c.Authorisation__c = tempAuth.Id;
        
        update c;
        
        System.runAs(user) {
            
            c = [SELECT Sub_Type__c, Authorisation__c FROM Case WHERE Id = :c.Id];
            Test.startTest();
            System.assertNotEquals(NULL, TaxiManageAccountCases.cancelTaxiApplication(c));
            Test.stopTest();
        }
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
            String agentAccess = TaxiManageAccountCases.getAccountDataForAgents(spAuth.Service_Provider__c);
            System.debug('agentAccess: '+agentAccess);
            if(agentAccess.length()!=0){
                System.assert(true);
            }
            else{
                System.assert(false);
            }
        }
    }
    
    @isTest
    private static void getApplicationCasesForFullAccessAgentTest(){
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
        
        Authorisation__c spAuth2 = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Full Access', Service_Provider__c = accountId,
                                                       Contact__c = conId, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth2;
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforTransfer, Authorisation__c = spAuth.id, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER);
        //c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;
       
        Authorisation_Agent__c aaRecord = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = agentAcc.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Full Access');
        
        insert aaRecord;
        Id p = GlobalUtility.getTaxiAgentUserProfile().id;
        User user = new User(alias = 'agent', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = agentContact.Id ,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        System.runAs(user){
            Id getAuthAgentId = [SELECT Id from Authorisation_Agent__c WHERE Authorisation__r.Service_Provider__c =: accountId LIMIT 1].Id;
            System.debug('getAccountId: '+getAuthAgentId);
            String agentAccess = TaxiManageAccountCases.getApplicationCasesForAgent(spAuth.Service_Provider__c);
            System.debug('agentAccess: '+agentAccess);
            if(agentAccess.length()!=0){
                System.assert(true);
            }
            else{
                System.assert(false);
            }
        }
    }
    
    @isTest
    private static void getApplicationCasesForTransferOnlyAgentTest(){
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
        Authorisation__c spAuth = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Transfer Only', Service_Provider__c = accountId,
                                                       Contact__c = conId, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth;
        
        Authorisation__c spAuth2 = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Transfer Only', Service_Provider__c = accountId,
                                                       Contact__c = conId, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth2;
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforTransfer, Authorisation__c = spAuth.id, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER);
        //c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;
       
        Authorisation_Agent__c aaRecord = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = agentAcc.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Transfer Only');
        
        insert aaRecord;
        Id p = GlobalUtility.getTaxiAgentUserProfile().id;
        User user = new User(alias = 'agent', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = agentContact.Id ,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        System.runAs(user){
            Id getAuthAgentId = [SELECT Id from Authorisation_Agent__c WHERE Authorisation__r.Service_Provider__c =: accountId LIMIT 1].Id;
            System.debug('getAccountId: '+getAuthAgentId);
            String agentAccess = TaxiManageAccountCases.getApplicationCasesForAgent(spAuth.Service_Provider__c);
            System.debug('agentAccess: '+agentAccess);
            if(agentAccess.length()!=0){
                System.assert(true);
            }
            else{
                System.assert(false);
            }
        }
    }
    
    @isTest
    private static void cancelTaxiApplicationTest2() {
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
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c = authRecord.Id, Account__c = acc.Id, Status__c = 'Active', Agreement_Type__c = 'Full Access');
        insert authAgent;
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiManageAccountCases.cancelTaxiApplication(newTaxiCase);
        Test.stopTest();
    }
    
    @isTest
    private static void cancelTaxiApplicationTest3() {
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
                                   ACN__c = acc.ACN__c, Corporation_name__c = acc.Name, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = acc.Id);
        newTaxiCase.RecordTypeId = individualTaxiCaseRecordTypeId;
        insert newTaxiCase;
        
        Id taxiAuthRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Authorisation__c authRecord = new Authorisation__c(Plate_Number__c = '11111', Authorisation_Type__c = 'Taxi Licence', Status__c = 'Granted', Service_Provider__c = acc.Id);
        authRecord.Application__c = newTaxiCase.Id;
        insert authRecord;
        
        newTaxiCase.Authorisation__c = authRecord.Id;
        update newTaxiCase;
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c = authRecord.Id, Account__c = acc.Id, Status__c = 'Active', Agreement_Type__c = 'Full Access');
        insert authAgent;
        String accId = [SELECT Id FROM Account WHERE ACN__c = '1234567898'].Id;
        
        Test.startTest();
        TaxiManageAccountCases.cancelTaxiApplication(newTaxiCase);
        Test.stopTest();
    }
}