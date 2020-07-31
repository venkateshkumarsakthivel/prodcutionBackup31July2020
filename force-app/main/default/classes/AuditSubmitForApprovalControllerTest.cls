@isTest
public class AuditSubmitForApprovalControllerTest {
    
    @testSetup
    private static void setupTestData()
    { 
        /* P2P Profile*/
        Id p = GlobalUtility.getP2PComplianceProfile().Id;
        
        Id ownerid = GlobalUtility.getOwnerId();
        /* Account created------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid );
        insert ac;
        
        Account newAcc = new Account(ACN__c = '1234567899',ABN__c = '12345678946', Name = 'testAcc1',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',OwnerId= ownerid);
        
        insert newAcc;
        
        /* Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0299881122');
        insert con;
        
        /* Audit User ---*/
        User auditReviewerUser = new User(alias = 'auditUsr', email='test123@noemail.com',
                                          emailencodingkey='UTF-8', lastname='auditReviewer', languagelocalekey='en_US',
                                          localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                          timezonesidkey='America/Los_Angeles', username='auditUser@noemail.com');
        
        insert auditReviewerUser;
        
        /* Audit User ---*/
        User leadAduitorUser = new User(alias = 'leadUsr', email='test123@noemail.com',
                                        emailencodingkey='UTF-8', lastname='leadAuditor', languagelocalekey='en_US',
                                        localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                        timezonesidkey='America/Los_Angeles', username='leadUser@noemail.com');
        
        insert leadAduitorUser;
        
        /*---Authorisation related to Account--*/
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'New', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  );
        
        insert taxiAuth;
        
        Authorisation__c tspAuth = new Authorisation__c(Service_Provider__c = newAcc.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                        Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_CONDITIONALLY , Authorisation_Type__c = 'TSP' );
        insert tspAuth;
        
        /*--- inserting Case --*/
        Id devCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT).getRecordTypeId();
        Case auditCase = new Case(AccountId = ac.Id , RecordTypeId = devCaseRecordTypeId);
        // auditCase.Audit_Vendor__c = ac.Id ;
        auditCase.AccountId =  ac.Id ;
        auditCase.Audit_Reviewer__c = auditReviewerUser.Id;
        auditCase.Lead_Auditor_User__c = leadAduitorUser.Id  ;
        auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
        auditCase.Status = 'In Progress';
        auditCase.Sub_Status__c = 'Planning';
        auditCase.Audit_Target_Start_Date__c = System.Today();
        auditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        auditCase.Audit_Completion_Date__c = System.today()+10;
        // auditCase.Audit_Target_End_Date__c = System.Today();
        insert auditCase;
        
        Case newAuditCase = new Case(AccountId = newAcc.Id , RecordTypeId = devCaseRecordTypeId);
        // auditCase.Audit_Vendor__c = newAcc.Id ;
        newAuditCase.AccountId =  newAcc.Id ;
        newAuditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
        newAuditCase.Status = 'In Progress';
        newAuditCase.Sub_Status__c = 'Planning';
        newAuditCase.Audit_Target_Start_Date__c = System.Today();
        newAuditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        newAuditCase.Audit_Completion_Date__c = System.today()+10;
        
        insert newAuditCase;
        
        
    }
    
    @isTest
    private static void fetchCaseDetailsTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        string auditCaseId = [select Id from Case where AccountId = :accountId limit 1].Id;
        system.debug('Case Id is'+ auditCaseId);
        Test.startTest();
        Case caseRec = AuditCustomSubmitForApprovalController.fetchCaseDetails(auditCaseId);
        System.debug('fetched case record is'+ caseRec);
        System.assertNotEquals(null,caseRec);
        Test.stopTest();
        
    }
    
    @isTest
    private static void isValidCaseRecordTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id newAccountId = [select id from Account where name = 'testAcc1' LIMIT 1].id;
        
        Boolean response;
        String caseId = [select Id from Case where AccountId = :accountId limit 1].ID;
        String newCaseId = [select Id from Case where AccountId = :newAccountId limit 1].ID;
        
        Test.startTest();
        /* Assertion for failure ------*/
        response = AuditCustomSubmitForApprovalController.isValidCaseRecord(caseId);
        System.debug('Case Record is '+ response);
        System.assertEquals(false,response);
        
        /* Assertion for true --------*/
        response = AuditCustomSubmitForApprovalController.isValidCaseRecord(newCaseId);
        System.debug('Case Record is '+ response);
        System.assertEquals(true,response);
        Test.stopTest();
        
    }
    
    @isTest
    private static void callSubmitForApprovalTestToPass()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id newAccountId = [select id from Account where name = 'testAcc1' LIMIT 1].id;
        
        string caseId = [select Id from Case where AccountId = :accountId limit 1].ID;
        Id auditReviewId = [SELECT Id FROM User WHERE username='auditUser@noemail.com' LIMIT 1].Id;
        Id leadAuditorId = [SELECT Id FROM User WHERE username='leadUser@noemail.com' LIMIT 1].Id;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_NAME_AUDIT_VENDOR).getRecordTypeId();
        Account ac1 = new Account(name ='testAcc1', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', RecordTypeId= devRecordTypeId, Equip_Vendor_Number__c = 'EVN0927', Purchase_Order_Number__c = 'PO4223',Auditor_Status__c = GlobalConstants.AUDITOR_STATUS_ACTIVE, Auditor_Type__c = GlobalConstants.AUDITOR_TYPE_EXTERNAL) ;
        insert ac1;
        
        Id devCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT).getRecordTypeId();
        Case newAuditCase = new Case(AccountId = newAccountId  , RecordTypeId = devCaseRecordTypeId);
        //newAuditCase.Audit_Vendor__c = newAccountId ;
        //newAuditCase.Audit_Vendor__c = ac1.Id ;
        //newAuditCase.Lead_Auditor__c = conId;
        newAuditCase.Audit_Reviewer__c = auditReviewId;
        newAuditCase.Lead_Auditor_User__c = leadAuditorId;
        newAuditCase.Status = 'In Progress';
        newAuditCase.Sub_Status__c = 'Planning';
        newAuditCase.Audit_Target_Start_Date__c = System.Today();
       	newAuditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        newAuditCase.Audit_Objectives__c ='testing ';
        newAuditCase.Audit_Scope__c = 'Testing Approval';
        
        insert newAuditCase;
        String response;
        String responseApproval;
        
        Test.startTest();
        response = AuditCustomSubmitForApprovalController.callSubmitForApproval(caseId);
        responseApproval = AuditCustomSubmitForApprovalController.callSubmitForApproval(newAuditCase.Id);
        System.debug('Response for no approval process '+ response);
        System.debug('Response  for approval '+ responseApproval);
        System.assertEquals('SUBMITTED', responseApproval);
        Test.stopTest();
    }
    
    @isTest
    private static void callSubmitForApprovalTestToFail()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id newAccountId = [select id from Account where name = 'testAcc1' LIMIT 1].id;
        
        string caseId = [select Id from Case where AccountId = :accountId limit 1].ID;
        Id auditReviewId = [SELECT Id FROM User WHERE username='auditUser@noemail.com' LIMIT 1].Id;
        Id leadAuditorId = [SELECT Id FROM User WHERE username='leadUser@noemail.com' LIMIT 1].Id;
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_NAME_AUDIT_VENDOR).getRecordTypeId();
        Account ac1 = new Account(name ='testAcc1', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', RecordTypeId= devRecordTypeId, Equip_Vendor_Number__c = 'EVN0927', Purchase_Order_Number__c = 'PO4223',Auditor_Status__c = GlobalConstants.AUDITOR_STATUS_ACTIVE, Auditor_Type__c = GlobalConstants.AUDITOR_TYPE_EXTERNAL) ;
        insert ac1;
        
        Id devCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT).getRecordTypeId();
        Case newAuditCase = new Case(AccountId = newAccountId  , RecordTypeId = devCaseRecordTypeId);
        //newAuditCase.Audit_Vendor__c = newAccountId ;
        newAuditCase.Audit_Reviewer__c = auditReviewId;
        newAuditCase.Lead_Auditor_User__c = null;//Test to fail if no Lead Auditor is Provided
        newAuditCase.Status = 'In Progress';
        newAuditCase.Sub_Status__c = 'Planning';
        newAuditCase.Audit_Target_Start_Date__c = System.Today();
        newAuditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        newAuditCase.Audit_Objectives__c ='testing ';
        newAuditCase.Audit_Scope__c = 'Testing Approval';
        
        insert newAuditCase;
        String response;
        String responseApproval;
        
        Test.startTest();
        response = AuditCustomSubmitForApprovalController.callSubmitForApproval(caseId);
        responseApproval = AuditCustomSubmitForApprovalController.callSubmitForApproval(newAuditCase.Id);
        System.debug('Response for no approval process '+ response);
        System.debug('Response  for approval '+ responseApproval);
        System.assertEquals('NO APPLICABLE PROCESS', responseApproval);
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void validateAuditStartDateLesserTest(){
    Test.startTest();
    Boolean valid=AuditCustomSubmitForApprovalController.validateAuditStartDate('2018-01-01 12:20:20','2018-02-01 12:20:20');
    System.assertEquals(true,valid);
    Test.stopTest();
    }
    
    @isTest
    public static void validateAuditStartDateGreaterTest(){
    Test.startTest();
    Boolean valid=AuditCustomSubmitForApprovalController.validateAuditStartDate('2018-02-01 12:20:20','2018-01-01 12:20:20');
    System.assertEquals(false,valid);
    Test.stopTest();
    } */
}