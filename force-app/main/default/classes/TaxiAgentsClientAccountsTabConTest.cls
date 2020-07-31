@isTest
public class TaxiAgentsClientAccountsTabConTest {
    
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
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Account agentAcc = new Account(Name ='AgentAccount', BillingStreet='Agent Street', BillingCity='Sydney',
                                       BillingState='MAH', BillingPostalCode='1000',OwnerId=ownerid);
        insert agentAcc;
        
        Authorisation__c spAuth = new Authorisation__c(Agency__c = agentAcc.id, Agreement_Type__c = 'Full Access', Service_Provider__c = ac.Id,
                                                       Contact__c = con.Id, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS,
                                                       Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        insert spAuth;
        
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforTaxiCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        
        Case c = new Case(AccountId = ac.Id, Service_Type__c = 'Taxi', Status = 'Draft' , RecordTypeId = rtIdforIndividual, Authorisation__c = spAuth.id);
        //c.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION;
        insert c;

        
        Authorisation_Agent__c aaRecord = new Authorisation_Agent__c(Status__c = 'Active', Authorisation__c = spAuth.Id,
                                                                     Account__c = ac.Id, Expiry_Date__c = System.today()+5,
                                                                     Approved_Date__c = System.today(), Agreement_Type__c = 'Full Access');
        
        insert aaRecord;
    }
    
    @isTest
    private static void getAccountDetailsTest() {
        String conId = [SELECT Id FROM Contact].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME];
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester62@noemail.com', contactId = conId);
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            TaxiAgentsClientAccountsTabController.getAccountDetails();
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getAgentAccountsTest() {
        String conId = [SELECT Id FROM Contact].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME];
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester63@noemail.com', contactId = conId);
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            TaxiAgentsClientAccountsTabController.getAgentAccounts();
        }
        Test.stopTest();
    }

}