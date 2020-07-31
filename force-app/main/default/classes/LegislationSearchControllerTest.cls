@isTest
public class LegislationSearchControllerTest {
    public static Integer count = 50;
    public static String RTtoExculsion = Legislation__c.Case_Record_Type_Exculsion__c.getDescribe().getPicklistValues()[0].getValue();
    public static String LegStatus = GlobalConstants.LEG_STATUS_ACTIVE;
    public static Id devRecordTypeId = Schema.SObjectType.Legislation__c.getRecordTypeInfosByName().get(LegStatus).getRecordTypeId();
    
    @testSetup static void setup() { 
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        Id auditNoticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Audit Notice').getRecordTypeId();
        
        List<Notice_Record__c> noticeList = new List<Notice_Record__c>();
        
        List<Legislation__c> letList = new List<Legislation__c>();
        List<Case_Legislative_Reference__c> caseLegRefList = new List<Case_Legislative_Reference__c>();
        
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId);
        insert acc;
        
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        
        Id InspectionCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId=InspectionCaseRecordTypeId,Status='New',Subject='Test Case Subject',Description='Test Case Description',
                                AccountId = acc.Id,ContactId=con.Id);
        insert caseRec;
                
        List<Legislation__c> legList = new List<Legislation__c>();
        
        for (Integer i = 0; i<count; i++) {
            Legislation__c l = new Legislation__c(Legislation_Name__c = 'Test Legislation '+ i, Status__c=LegStatus, Description__c='Legislation Description', recordTypeId =devRecordTypeId, Schedule_Section_Clause_Rule__c='87');
            legList.add(l);
        }
        
        Legislation__c ex = new Legislation__c(Legislation_Name__c = 'Test Legislation exculsion', Status__c=LegStatus, Description__c='Legislation Description exculsion', recordTypeId =devRecordTypeId, Schedule_Section_Clause_Rule__c='87', Case_Record_Type_Exculsion__c=RTtoExculsion);
        legList.add(ex);
        
        insert legList;
        
        Case_Legislative_Reference__c caseLegRef1 = new Case_Legislative_Reference__c(Legislation__c=legList[0].Id,Case__c=caseRec.Id,Status__c='Active');
        caseLegRefList.add(caseLegRef1);
        Case_Legislative_Reference__c caseLegRef2 = new Case_Legislative_Reference__c(Legislation__c=legList[1].Id,Case__c=caseRec.Id,Status__c='Active');
        caseLegRefList.add(caseLegRef2);
        insert caseLegRefList;
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= acc.Id,
            Served_to__c= con.Id,
            Case__c= caseRec.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
        );
        noticeList.add(noticeRecord);
        
        Notice_Record__c auditNoticeRecord = new Notice_Record__c(
            RecordTypeId = auditNoticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= acc.Id,
            Served_to__c= con.Id,
            Case__c= caseRec.Id,
            Notice_Type__c = 'Levy Audit'
        );
        noticeList.add(auditNoticeRecord);
        
        insert noticeList;
    }
    
    @isTest static void testSearchForRecords(){
        List<Legislation__c> result = LegislationSearchController.searchForRecords('Legislation','87',RTtoExculsion);
        system.debug('result size:'+result.size());
        System.assertEquals(count, result.size());
    }
    
    @isTest static void testSearchForRecordsNoResult(){
        List<Legislation__c> result = LegislationSearchController.searchForRecords('abcd','99','');
        System.assertEquals(0, result.size());
    }
    
    @isTest static void testSearchForRecordsNoInput(){
        List<Legislation__c> result = LegislationSearchController.searchForRecords('','','');
        System.assertEquals(null, result);
    }
    
    @isTest static void testSearchForCaseLegislationProhibitionNotice(){
        List<Case> caseList= ([SELECT Id FROM Case LIMIT 1]);
        List<Notice_Record__c> noticeList = ([SELECT Id FROM Notice_Record__c WHERE Case__c = :caseList[0].Id AND Notice_Type__c = 'S87 - Prohibition Notice']);
        List<Case_Legislative_Reference__c> caseLegList = ([SELECT Id,Legislation__r.Section__c, Legislation__r.Recommendation__c, Legislation__r.Direction__c, Legislation__r.Remediation__c 
                                                            FROM Case_Legislative_Reference__c WHERE Case__c =: caseList[0].Id]);
        Case_Legislative_Reference__c caseLeg = caseLegList[0];
        
        Test.startTest();
        List<Case_Legislative_Reference__c> result = LegislationSearchController.loadCaseLegislation(caseList[0].Id,noticeList[0].Id);
        System.assertEquals(2, result.size());
        
        Notice_Legislative_Reference__c noticeLeg = new Notice_Legislative_Reference__c();
        noticeLeg.Case_Legislative_Reference__c = caseLeg.Id;
        noticeLeg.Legislation__c =caseLeg.Legislation__c;
        noticeLeg.Section_Description__c = caseLeg.Legislation__r.Section__c;
        noticeLeg.Recommendation__c = caseLeg.Legislation__r.Recommendation__c;
        noticeLeg.Direction__c = caseLeg.Legislation__r.Direction__c;
        noticeLeg.Remediation__c = caseLeg.Legislation__r.Remediation__c;
        noticeLeg.Notice_Record__c = noticeList[0].Id;
        noticeLeg.Status__c = 'Active';      
        insert noticeLeg;
        
        List<Case_Legislative_Reference__c> result1 = LegislationSearchController.loadCaseLegislation(caseList[0].Id,noticeList[0].Id);
        System.assertEquals(1, result1.size());
        
        Test.stopTest();
    }
    
    @isTest static void testSearchForCaseLegislationAuditNotice(){
        List<Case> caseList= ([SELECT Id FROM Case LIMIT 1]);
        List<Notice_Record__c> noticeList = ([SELECT Id FROM Notice_Record__c WHERE Case__c = :caseList[0].Id AND Notice_Type__c = 'Levy Audit']);
        List<Case_Legislative_Reference__c> caseLegList = ([SELECT Id,Legislation__r.Section__c, Legislation__r.Recommendation__c, Legislation__r.Direction__c, Legislation__r.Remediation__c 
                                                            FROM Case_Legislative_Reference__c WHERE Case__c =: caseList[0].Id]);
        Case_Legislative_Reference__c caseLeg = caseLegList[0];
        
        Test.startTest();
        List<Case_Legislative_Reference__c> result = LegislationSearchController.loadCaseLegislation(caseList[0].Id,noticeList[0].Id);
        System.assertEquals(2, result.size());
        
        Notice_Legislative_Reference__c noticeLeg = new Notice_Legislative_Reference__c();
        noticeLeg.Case_Legislative_Reference__c = caseLeg.Id;
        noticeLeg.Legislation__c =caseLeg.Legislation__c;
        noticeLeg.Section_Description__c = caseLeg.Legislation__r.Section__c;
        noticeLeg.Recommendation__c = caseLeg.Legislation__r.Recommendation__c;
        noticeLeg.Direction__c = caseLeg.Legislation__r.Direction__c;
        noticeLeg.Remediation__c = caseLeg.Legislation__r.Remediation__c;
        noticeLeg.Notice_Record__c = noticeList[0].Id;
        noticeLeg.Status__c = 'Active';      
        insert noticeLeg;
        
        List<Case_Legislative_Reference__c> result1 = LegislationSearchController.loadCaseLegislation(caseList[0].Id,noticeList[0].Id);
        System.assertEquals(2, result1.size());
        
        Test.stopTest();
    }
    
}