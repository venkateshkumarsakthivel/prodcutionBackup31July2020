@isTest
public class AuditNewNoticeControllerTest {
    
    @testSetup 
    static void setup() {
        Id ownerId = GlobalUtility.getOwnerId();
        
        Account aspAcc = new Account(name ='testASP', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        insert aspAcc;
        
        Contact aspCon = new Contact(LastName ='testASPCon', firstName= 'test', AccountId = aspAcc.Id, Email='test@contest.com');
        insert aspCon;
        
        RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
        RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
        RecordType caseAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit' AND SobjectType = 'Case'];  
        
        Account ac = new Account(name ='testAuditor', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        ac.RecordTypeId = accountAuditRecordType.Id;
        ac.Auditor_Type__c = 'External';
        ac.Auditor_Status__c = 'Active';
        ac.Equip_Vendor_Number__c = 'EVP1234';
        ac.Purchase_Order_Number__c = 'PO1234';
        insert ac;
        
        Case auditCase = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
        auditCase.Subject = 'Audit Case';
        auditCase.Audit_Vendor__c = ac.Id;
        auditCase.AccountId = aspAcc.Id;
        auditCase.ContactId = aspCon.Id;
        auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
        auditCase.Status = 'In Progress';
        auditCase.Sub_Status__c = 'Planning';
        auditCase.Audit_Target_Start_Date__c = System.Today();
        auditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        auditCase.Audit_Target_End_Date__c = System.Today()+3;
        insert auditCase;
        
        Profile systemUserProfile = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
        User systemUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', profileid = systemUserProfile.Id, country='United States', IsActive =true,
                                   timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
        
        insert systemUser;  
        
        /*--*/
        
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId);
        insert acc;
        
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        
        Id InspectionCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId=InspectionCaseRecordTypeId,Status='New',Subject='Test Case Subject',Description='Test Case Description',
                                AccountId = acc.Id,ContactId=con.Id);
        insert caseRec;
        
        Legislation__c leg = new Legislation__c(Legislation_Name__c='Test Legislation 1', Description__c='Test Legislation Description 1',
                                                Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='123', Sub_Section_Clause__c='123A');
        insert leg;
        
        Case_Legislative_Reference__c caseLegRef = new Case_Legislative_Reference__c(Legislation__c=leg.Id,Case__c=caseRec.Id,Status__c='Active');
        insert caseLegRef;
    }
    
    @isTest
    public static void getAuditCaseDetailsTest() {
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case WHERE Subject = 'Audit Case'];
        
        
        String a_id=auditCase.Id;
        Test.startTest();
        System.assertNotEquals(null,AuditNewNoticeController.getAuditCaseDetails(a_id));
        Test.stopTest();
    }
    
    @isTest
    public static void getLoggedinUsersDetailsTest() {
        User usrs = [SELECT Id FROM User where lastname='Testing' LIMIT 1];
        Test.startTest();
        System.assertNotEquals(null,AuditNewNoticeController.getLoggedinUsersDetails());
        Test.stopTest();
    }
    
    @isTest
    public static void getNoticeSubTypesTest() {
        Test.startTest();
        System.assertNotEquals(null,AuditNewNoticeController.getNoticeSubTypes('Audit Notice'));
        Test.stopTest();
    }
    
    @isTest
    public static void getRecordTypeAndDefaultValuesTest() {
        Test.startTest();
        System.assertNotEquals(null,AuditNewNoticeController.getRecordTypeAndDefaultValues('Audit Notice', 'Levy Investigation'));
        Test.stopTest();
    }
    
    @isTest
    public static void getCaseLegislationTest() {
        Case testCaseId = [SELECT Id FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1];
        
        Test.startTest();
        List<Case_Legislative_Reference__c> caseLeg = AuditNewNoticeController.loadCaseNoticeLegislation(testCaseId.Id);
        System.assertEquals('Test Legislation 1', caseLeg[0].Legislation__r.Legislation_Name__c);
        Test.stopTest();
    }
    
    @isTest
    public static void getNewNoticeRecordTest(){
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case WHERE Subject = 'Audit Case'];        
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
           // Notice_Sub_Type__c = 'S87 - Prohibition Notice'
        );
        String noticeString = JSON.serialize(noticeRecord);
        
        System.debug('Notice String value : '+noticeString);
        
        Test.startTest();
        String noticeId = AuditNewNoticeController.createNewNoticeRecord(noticeString);
        System.assertNotEquals(null, noticeId);
        Test.stopTest();
    }
    
    @isTest
    private static void createNoticeLegislationTest(){
        Case cases = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'Test Case Subject' LIMIT 1]; 
        
        List<Case_Legislative_Reference__c> caseLegist = ([SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                                   LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, 
                                                                   Case__c, Legislation__c, Primary__c, Comment__c, Status__c, Case_Status__c, 
                                                                   Reason_for_Change__c 
                                                                   FROM Case_Legislative_Reference__c
                                                                   WHERE Case__c = :cases.Id]);
        System.debug('caseLegist :'+caseLegist.size());
        
        String selectedCaseLeg = JSON.serialize(caseLegist);
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= cases.AccountId,
            Served_to__c= cases.ContactId,
            Case__c= cases.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
           // Notice_Sub_Type__c = 'S87 - Prohibition Notice'
        );
        String noticeString = JSON.serialize(noticeRecord);
        String noticeId = AuditNewNoticeController.createNewNoticeRecord(noticeString);
        
        Test.startTest();
        List<Notice_Legislative_Reference__c> noticeLegRef = new List<Notice_Legislative_Reference__c>();
        noticeLegRef = ([SELECT Id, Notice_Record__c, Notice_Status__c FROM Notice_Legislative_Reference__c WHERE Notice_Record__c = :noticeId]);
       	System.assertEquals(0, noticeLegRef.size());
        AuditNewNoticeController.createNoticeLegislationRecord(selectedCaseLeg,noticeId);
        noticeLegRef = ([SELECT Id, Notice_Record__c, Notice_Status__c FROM Notice_Legislative_Reference__c WHERE Notice_Record__c = :noticeId]);
        System.assertEquals(1, noticeLegRef.size());
        Test.stopTest();
        
    }
}