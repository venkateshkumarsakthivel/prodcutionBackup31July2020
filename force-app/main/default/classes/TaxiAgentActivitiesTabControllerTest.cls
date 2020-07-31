@isTest
public class TaxiAgentActivitiesTabControllerTest {
    
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
    }
    
    @isTest
    private static void getAccountDetailsTest() {
        String conId = [SELECT Id FROM Contact].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME];
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester52@noemail.com', contactId = conId);
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            TaxiAgentActivitiesTabController.getAccountDetails();
        }
        Test.stopTest();
    }
    
    @isTest
    private static void getAgentCasesTest() {
        String conId = [SELECT Id FROM Contact].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.TAXI_AGENT_USER_PROFILE_NAME];
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester53@noemail.com', contactId = conId);
        
        insert user;
        
        Test.startTest();
        System.runAs(user) {
            TaxiAgentActivitiesTabController.getAgentCases();
        }
        Test.stopTest();
    }

}