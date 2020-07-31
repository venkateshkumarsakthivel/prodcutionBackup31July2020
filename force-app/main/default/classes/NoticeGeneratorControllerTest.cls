@isTest
private class NoticeGeneratorControllerTest {
    @testSetup static void setup() {
        
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        List<Legislation__c> letList = new List<Legislation__c>();
        List<Case_Legislative_Reference__c> caseLegRefList = new List<Case_Legislative_Reference__c>();
        
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId,Notice_Email__c='test@nomail.com',Document_Delivery_Preference__c='Email');
        insert acc;
        
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        
        Id InspectionCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId=InspectionCaseRecordTypeId,Status='New',Subject='Test Case Subject Inspection',Description='Test Case Description',
                                AccountId = acc.Id,ContactId=con.Id);
        insert caseRec;
        
        Id AuditCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
        Case caseRec1 = new Case(RecordTypeId=AuditCaseRecordTypeId,Status='New',Subject='Test Case Subject Audit',Description='Test Case Description Audit',
                                AccountId = acc.Id,ContactId=con.Id);
        insert caseRec1;
        
        Id FailureforLevyCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Failure to Register for Levy').getRecordTypeId();
        Case caseRec2 = new Case(RecordTypeId=FailureforLevyCaseRecordTypeId,Status='New',Subject='Test Case Subject Failure to Register for Levy',Description='Test Case Description Failure to Register for Levy',
                                 AccountId = acc.Id,ContactId=con.Id);
        insert caseRec2;
        
        Legislation__c leg = new Legislation__c(Legislation_Name__c='Test Legislation 1', Description__c='Test Legislation Description 1',
                                                Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='123', Sub_Section_Clause__c='123A');
        letList.add(leg);
        
        Legislation__c leg1 = new Legislation__c(Legislation_Name__c='Test Legislation 2', Description__c='Test Legislation Description 2',
                                                 Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='232', Sub_Section_Clause__c='232A');
        letList.add(leg1);
        Legislation__c leg2 = new Legislation__c(Legislation_Name__c='Test Legislation 3', Description__c='Test Legislation Description 3',
                                                 Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='234', Sub_Section_Clause__c='234B');
        letList.add(leg2);
        insert letList;
        
        Case_Legislative_Reference__c caseLegRef1 = new Case_Legislative_Reference__c(Legislation__c=leg.Id,Case__c=caseRec.Id,Status__c='Active');
        caseLegRefList.add(caseLegRef1);
        Case_Legislative_Reference__c caseLegRef2 = new Case_Legislative_Reference__c(Legislation__c=leg1.Id,Case__c=caseRec1.Id,Status__c='Active');
        caseLegRefList.add(caseLegRef2);
        Case_Legislative_Reference__c caseLegRef3 = new Case_Legislative_Reference__c(Legislation__c=leg2.Id,Case__c=caseRec2.Id,Status__c='Active');
        caseLegRefList.add(caseLegRef3);
        insert caseLegRefList;
    }
    
    @isTest
    private static void testMethod1(){
        String objectName = 'Notice_Record__c';
        List<Id> recordTypeIds = new List<Id>();
        List<Case> cases = [SELECT Id, Subject, Description, Status,RecordType.Name  FROM Case LIMIT 1];
        
        Test.startTest();
        
        Map<Id, String> recordtypemap = NoticeGeneratorController.fetchRecordTypeValues(objectName, cases[0].RecordType.Name);
        recordTypeIds.addAll(recordtypemap.keySet());
        System.debug(recordTypeIds);
        
        List<Case_Legislative_Reference__c>caseLegRef = NoticeGeneratorController.getLegislativeReferences(cases[0].Id, recordTypeIds[0]);
        //System.debug('caseLegRef size:'+caseLegRef.size());
        
        System.assertEquals(1, caseLegRef.size());
        Test.stopTest();
    }
    
    @isTest
    private static void testMethod2(){
        String objectName = 'Notice_Record__c';
        List<Id> recordTypeIds = new List<Id>();
        
        List<Case> cases = [SELECT Id, Subject, Description, Status ,RecordType.Name FROM Case LIMIT 1];
        
        Map<Id, String> recordtypemap = NoticeGeneratorController.fetchRecordTypeValues(objectName, cases[0].RecordType.Name);
        recordTypeIds.addAll(recordtypemap.keySet());
        System.debug(recordTypeIds);
        
        List<Case_Legislative_Reference__c>caseLegRef = NoticeGeneratorController.getLegislativeReferences(cases[0].Id, recordTypeIds[0]);
        System.debug('caseLegRef[0]:'+caseLegRef[0]);
        System.debug('caseLegRef size:'+caseLegRef.size());
        
        String noticeRec = '{\"recordTypeId\":"'+recordTypeIds[0]+'",\"Case__c\":"'+cases[0].Id+'",\"Show_On_Industry_Portal__c\":\"No\"}';
        
        Test.startTest();
        Map<String,String> noticeMetadataSetting =  NoticeGeneratorController.getNoticeMataDataSetting();
        System.assertNotEquals(Null, noticeMetadataSetting.size());
        
        Notice_Record__c noticeRecd = NoticeGeneratorController.createNewNoticeRecord(noticeRec);
        System.debug('noticeRecId: '+noticeRecd);
        System.assert(String.isNotEmpty(noticeRecd.Id));
        
        Notice_Record__c noticeRecdQuery = NoticeGeneratorController.getNoticeRecord(noticeRecd.Id);
        System.assertNotEquals(Null,noticeRecdQuery);
        
        String selectedCaseLeg = '[{\"Legislation__c\":"'+caseLegRef[0].Legislation__c+'",\"Case__c\":"'+caseLegRef[0].Case__c+'",\"Id\":\"'+caseLegRef[0].Id+'\"}]';
        System.debug('selectedCaseLeg: '+selectedCaseLeg);
        NoticeGeneratorController.createNoticeLegislationRecord(selectedCaseLeg, noticeRecd.Id);
        
        List<Notice_Legislative_Reference__c> noticeLeg = ([SELECT Status__c, Notice_Status__c, Case_Legislative_Reference__c, Legislation__c, Id FROM Notice_Legislative_Reference__c LIMIT 1]);
        
        System.assertEquals(caseLegRef[0].Legislation__c, noticeLeg[0].Legislation__c);
        Test.stopTest();
    }
    
    
    @isTest
    private static void testMethod3(){
        Profile p = [SELECT Id FROM Profile WHERE Name='P2P Compliance'];
        
        User u = new User(Alias = 'P2PUsr', Email='P2P@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, TimeZoneSidKey='Australia/Sydney', UserName='P2P@testorg.com',Authorisation_Officer_Number__c='123456789' );
        
        Test.startTest();
        System.runAs(u){
            String authorisedUserId = NoticeGeneratorController.getAuthorisedUser();
            System.assertEquals(u.Id, authorisedUserId);
        }
        Test.stopTest();
    }

    
    @isTest
    private static void testMethod4(){
        Case cases = [SELECT Id, Subject, Description, Status  FROM Case LIMIT 1];
        
        Test.startTest();
        Case CaseRel = NoticeGeneratorController.getCaseRelatedRecords(cases.Id);
        System.assertEquals('Email', CaseRel.Account.Document_Delivery_Preference__c);
        Test.stopTest();
    }
    
    @istest
    public static void getFieldsByRecordIdTest(){
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId, BillingStreet='Castlereagh Street', BillingCity='Sydney', 
                                  BillingState='NSW', BillingPostalCode='2000');
        insert acc;
        
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        system.debug('con Id:'+con.Id);
        
        RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
        RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
        RecordType caseAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit' AND SobjectType = 'Case'];  
        
        Account ac = new Account(name ='testAuditor', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        ac.RecordTypeId = accountAuditRecordType.Id;
        ac.Auditor_Type__c = 'Internal';
        ac.Auditor_Status__c = 'Active';
        ac.Equip_Vendor_Number__c = 'EVP1234';
        ac.Purchase_Order_Number__c = 'PO1234';
        ac.Notice_Email__c = 'test@test.com';
        insert ac;
        
        Case auditCase = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
        auditCase.Audit_Vendor__c = ac.Id;
        auditCase.AccountId = acc.Id;
        auditCase.ContactId = Con.Id;
        //auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
        auditCase.Status = 'In Progress';
        auditCase.Sub_Status__c = 'Planning';
        auditCase.Audit_Target_Start_Date__c = System.Today();
        auditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        auditCase.Audit_Target_End_Date__c = System.Today()+3;
        insert auditCase;
        
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
            //Notice_Sub_Type__c = 'S87 - Prohibition Notice'
        );
        
        insert noticeRecord;
        
        NoticeGeneratorController.getForm(noticeRecord.Id,'Notice_Record__c','WAT_First_Round');
    } 
    
    @isTest
    private static void testMethod5(){
        String objectName = 'Notice_Record__c';
        List<Id> recordTypeIds = new List<Id>();
        
        List<Case> cases = [SELECT Id, Subject, Description, Status ,RecordType.Name FROM Case WHERE Subject = 'Test Case Subject Audit'];
        
		Test.startTest();
        Map<Id, String> recordtypemap = NoticeGeneratorController.fetchRecordTypeValues(objectName, cases[0].RecordType.Name);
        System.assertNotEquals(Null, recordtypemap);
        Test.stopTest();
    }
    
        @isTest
    private static void testMethod6(){
        String objectName = 'Notice_Record__c';
        List<Id> recordTypeIds = new List<Id>();
        String noticeRecordType = null;
        
        List<Case> cases = [SELECT Id, Subject, Description, Status ,RecordType.Name FROM Case 
                            WHERE Subject = 'Test Case Subject Failure to Register for Levy' LIMIT 1];
        
        Map<Id, String> recordtypemap = NoticeGeneratorController.fetchRecordTypeValues(objectName, cases[0].RecordType.Name);
        recordTypeIds.addAll(recordtypemap.keySet());
        System.debug(recordTypeIds);
        
        Id Show_CauseRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Show Cause').getRecordTypeId();
        
        if(recordTypeIds.contains(Show_CauseRecordTypeId)){
            noticeRecordType = Show_CauseRecordTypeId;
        } else {
            noticeRecordType = recordTypeIds[0];
        }
        
        List<Case_Legislative_Reference__c>caseLegRef = NoticeGeneratorController.getLegislativeReferences(cases[0].Id, recordTypeIds[0]);
        System.debug('caseLegRef[0]:'+caseLegRef[0]);
        System.debug('caseLegRef size:'+caseLegRef.size());
        
        String noticeRec = '{\"recordTypeId\":"'+noticeRecordType+'",\"Case__c\":"'+cases[0].Id+'",\"Show_On_Industry_Portal__c\":\"No\"}';
        
        Test.startTest();
        Map<String,String> noticeMetadataSetting =  NoticeGeneratorController.getNoticeMataDataSetting();
        System.assertNotEquals(Null, noticeMetadataSetting.size());
        
        Notice_Record__c noticeRecd = NoticeGeneratorController.createNewNoticeRecord(noticeRec);
        System.debug('noticeRecId: '+noticeRecd);
        System.assert(String.isNotEmpty(noticeRecd.Id));
        
        Notice_Record__c noticeRecdQuery = NoticeGeneratorController.getNoticeRecord(noticeRecd.Id);
        System.assertNotEquals(Null,noticeRecdQuery);
        
        String selectedCaseLeg = '[{\"Legislation__c\":"'+caseLegRef[0].Legislation__c+'",\"Case__c\":"'+caseLegRef[0].Case__c+'",\"Id\":\"'+caseLegRef[0].Id+'\"}]';
        System.debug('selectedCaseLeg: '+selectedCaseLeg);
        NoticeGeneratorController.createNoticeLegislationRecord(selectedCaseLeg, noticeRecd.Id);
        
        List<Notice_Legislative_Reference__c> noticeLeg = ([SELECT Status__c, Notice_Status__c, Case_Legislative_Reference__c, Legislation__c, Id FROM Notice_Legislative_Reference__c LIMIT 1]);
        
        System.assertEquals(caseLegRef[0].Legislation__c, noticeLeg[0].Legislation__c);
        Test.stopTest();
    }
    
}