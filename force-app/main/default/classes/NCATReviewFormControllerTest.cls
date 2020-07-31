@isTest
public class NCATReviewFormControllerTest {
    
    @testSetup
    private static void setupTestData()
    {
        
        Id ownerid = GlobalUtility.getOwnerId();
        
        /* Account created------ */
        Account acc = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                  Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                  Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                  BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                  ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert acc;
        
        
        /* Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = acc.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        
        /*---Authorisation related to Account--*/
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = acc.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        
        insert taxiAuth;
        
        
    }
    
    @isTest
    private static void isValidateUserTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        String userName = 'testpermissionsetuser12'+Datetime.Now().Millisecond()+'@testorg.com';
        
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',   UserName=userName);
        
        
        insert user;
        
        Id userId = [Select id , Name from User where UserName=:userName].id;
        PermissionSet ps = [select Id from PermissionSet where Name ='Sanctions_Operations_Staff_level_2_level_3'];
        
        
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        
        boolean result;   
        Test.startTest();
        System.runAs(user){
            
            result =  NCATReviewFormController.isValidateUser();
            System.assertEquals(true, result);
            
        }
        
        result = NCATReviewFormController.isValidateUser();
        System.assertNotEquals(true, result);
        System.debug('result is '+ result);
        Test.stopTest();
        
    }
    
    @isTest
    private static void getAccountDetailsTest()  
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;  
        System.debug('account Id is '+ accountId);
        
        string result;
        
        /*-----Assertion - pass---*/
        Test.startTest();
        Account newRec = (Account) JSON.deserialize(NCATReviewFormController.getAccountDetails(accountId), Account.class);
        System.debug('fetched record is '+ newRec);
        
        Id newRecAccountId = newRec.Id;
        System.assertEquals(accountId, newRecAccountId);
        Test.stopTest();
        
    }
    
    @isTest
    private static void createNcatReviewCaseTest()     
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id authId =[select id from Authorisation__c where Service_Provider__c = :accountId LIMIT 1].id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        String userName = 'testpermissionsetuser12'+Datetime.Now().Millisecond()+'@testorg.com';
        
        User user = new User(Alias = 'standt', Email='standarduser@testorg.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p.Id,
                             TimeZoneSidKey='America/Los_Angeles',   UserName=userName);
        
        
        insert user;
        
        Id userId = [Select id , Name from User where UserName=:userName].id;
        
        PermissionSet ps = [select Id from PermissionSet where Name ='Sanctions_Operations_Staff_level_2_level_3'];
        
        
        /* ----Attachment  to parent Account-------------*/
        Attachment attach=new Attachment();     
        attach.Name='NCAT - Unit';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=accountId;
        insert attach;
        
        Case caseRecord = new Case();
        caseRecord.AccountId = accountId;
        caseRecord.Has_there_been_an_internal_review__c  = true;
        caseRecord.ContactId = conId ;
        caseRecord.Authorisation__c = authId;
        caseRecord.NCAT_file_number__c = 'TEST12345';
        caseRecord.Decision_Made_By__c = userId;
        caseRecord.Date_of_decision_being_reviewed_at_NCAT__c =  Date.newInstance(2018, 1, 6);
        caseRecord.Date_of_Internal_Review_Decision__c =  Date.newInstance(2018, 1, 5);
        
        System.debug('case data is'+ caserecord);
        String jsoncaseData = json.serialize(caserecord);
        System.debug('json form case data '+ jsoncaseData);
        
        Test.startTest();
        String resultCaseId = NCATReviewFormController.createNcatReviewCase(jsoncaseData);
        System.debug('result of new case data is '+ resultCaseId);
        System.assertNotEquals(resultCaseId,null);
        
    }
}