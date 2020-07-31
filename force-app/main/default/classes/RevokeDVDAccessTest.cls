@isTest
public class RevokeDVDAccessTest {
    
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
        
        Contact con1 = new Contact(Title='Mr.', LastName ='testCon 1',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con1;
        
        Contact con2 = new Contact(Title='Mr.', LastName ='testCon 2',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con2;
        
        Id rtIdForCancelSuspend = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vary/Suspend/Cancel Licence').getRecordTypeId();
        
        Case newASPCase = new Case(Title__c = con1.Title, Family_name__c = con1.LastName, First_given_name__c = con1.FirstName, Birthdate__c = con1.Birthdate, Email__c = con1.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.EXPIRY_CASE_SUB_TYPE,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        
        newASPCase.RecordTypeId = rtIdForCancelSuspend;
        insert newASPCase;
        
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con1.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        
        newASPCase.Authorisation__c = auth.Id;
        update newASPCase;
    }
    
    @isTest
    private static void revokeAccessTest(){
        
        Id accountId = [select Id from Account WHERE Name = 'testAcc' LIMIT 1].id; 

        Id con1Id = [Select Id FROM contact WHERE AccountId =:accountId AND LastName = 'testCon 1' LIMIT 1].Id;
        Id con2Id = [Select Id FROM contact WHERE AccountId =:accountId AND LastName = 'testCon 2' LIMIT 1].Id;
        
        Id p1 = [Select Id FROM Profile WHERE Name='Authorised Service Provider'].Id;
        
        String usr;
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p1, country='United States', IsActive =true,
                             contactId = con1Id,
                             timezonesidkey='America/Los_Angeles', username='tester1@noemail.com');
        
        insert user1;
        
        Id p2 = [Select Id FROM Profile WHERE Name='DVD User'].Id;
        
        User user2 = new User(alias = 'test123', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p2, country='United States', IsActive =true,
                             contactId = con2Id,
                             timezonesidkey='America/Los_Angeles', username='tester27@noemail.com');
        
        insert user2;
        
        Case cancelSuspendCase = [SELECT Record_Type_Dev_Name__c, Type, Sub_Type__c, Status, Sub_Status__c,
                                  Authorisation__c, AccountId
                                  FROM Case];
        
        cancelSuspendCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        
        update cancelSuspendCase;
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        caseMap.put(cancelSuspendCase.Id, cancelSuspendCase);
        
        Test.startTest();
        RevokeDVDAccess revokeAccess = new RevokeDVDAccess(caseMap, caseMap);
        revokeAccess.revokeDVDAccess();
        Test.stopTest();
        
        Contact con1 = [SELECT Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c
                        FROM Contact WHERE LastName = 'testCon 1'];
        
        Contact con2 = [SELECT Is_Access_Level_DVD_Administrator__c, Is_Access_Level_Account_Administrator__c,
                        Deactivated__c, Deactivation_Date__c, Status__c
                        FROM Contact WHERE LastName = 'testCon 2'];
        
        System.assertEquals(FALSE, con1.Is_Access_Level_DVD_Administrator__c);
        System.assertEquals(TRUE, con1.Is_Access_Level_Account_Administrator__c);
        
        System.assertEquals(TRUE, con2.Deactivated__c);
        System.assertEquals(TRUE, con2.Deactivated__c);
        System.assertEquals(GlobalConstants.INACTIVE_CONTACT_STATUS, con2.Status__c);
    }
}