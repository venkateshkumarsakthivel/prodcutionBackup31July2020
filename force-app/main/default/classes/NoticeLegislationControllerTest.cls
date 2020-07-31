@isTest
public class NoticeLegislationControllerTest {
    
    @testSetup static void setup() {
                
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
        auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
        auditCase.Status = 'In Progress';
        auditCase.Sub_Status__c = 'Planning';
        auditCase.Audit_Target_Start_Date__c = System.Today();
        auditCase.Audit_Notice_First_Sent_Date__c = System.Today()-2;
        auditCase.Audit_Target_End_Date__c = System.Today()+3;
        insert auditCase;
        
        Contact authoriseOffice = new Contact(FirstName='Test',LastName='Officer',Status__c = ActiveStatus,Email='testofficer@nomail.com',AccountId=acc.Id);
        insert authoriseOffice;
        system.debug('authoriseOffice Id:'+authoriseOffice.Id);
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice',
            //Notice_Sub_Type__c = 'S87 - Prohibition Notice',   
            Description_Text_Block_1__c = '%% Instructions %%',
            Description_Text_Block_2__c = '%% Instructions %%',
            Description_Text_Block_3__c = '%% Instructions %%',
            Legislation_Text_Block_1__c = '%% Instructions %%',
            Directions_Text_Block_1__c =  '%% Instructions %%',
            Directions_Text_Block_2__c = '%% Instructions %%',
            Recommendations_Text_Block_1__c = '%% Instructions %%'
        );
        
        insert noticeRecord;
        Legislation__c leg = new Legislation__c(Legislation_Name__c='Test Legislation 1',Description__c='Test Legislation Description 1',
                                                Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='123', Sub_Section_Clause__c='123A');
        insert leg;
        
        Notice_Legislative_Reference__c noticeLegRef = new Notice_Legislative_Reference__c(Legislation__c=leg.Id,Notice_Record__c=noticeRecord.Id,Status__c='Active');
        insert noticeLegRef;
    }
    
    @isTest
    private static void testMethod1(){
        Notice_Legislative_Reference__c noticeLegRef1 = [SELECT Id, Name, Notice_Record__c, Legislation__c, Comment__c, Status__c, 
                                                      Reason_for_Change__c FROM Notice_Legislative_Reference__c];
        System.debug('noticeLegRef1:'+noticeLegRef1.Notice_Record__c);
        
        Test.startTest();
        List<Notice_Legislative_Reference__c> noticeLegRef = NoticeLegislationController.loadNoticeLegislation(noticeLegRef1.Notice_Record__c);
        
        System.debug('noticeLegRef:'+noticeLegRef);
        
        System.assertEquals(noticeLegRef1.Id, noticeLegRef[0].Id);
        
        List<String> ReasonForChange = NoticeLegislationController.getPickListValuesIntoList();
        System.debug('ReasonForChange:'+ReasonForChange);
        
        noticeLegRef[0].Reason_for_Change__c = ReasonForChange[0];
        
        List<Notice_Legislative_Reference__c> caseLegRefList = new List<Notice_Legislative_Reference__c>();
        caseLegRefList.add(noticeLegRef[0]);
        
        String caseLegRefString = JSON.serialize(caseLegRefList);
        System.debug('caseLegRefString:'+caseLegRefString);
        
        NoticeLegislationController.saveNoticeLegislation(caseLegRefString);
        
        noticeLegRef1 = [SELECT Id, Name, Notice_Record__c, Legislation__c, Comment__c, Status__c, 
                       Reason_for_Change__c FROM Notice_Legislative_Reference__c];
        
        System.assertEquals(noticeLegRef1.Reason_for_Change__c, ReasonForChange[0]);
        Test.stopTest();
    }
    
    @isTest
    private static void testDeleteLegislativeReference(){
        Notice_Legislative_Reference__c noticeLegRef1 = [SELECT Id, Name, Notice_Record__c, Legislation__c, Comment__c, Status__c, 
                                                      Reason_for_Change__c FROM Notice_Legislative_Reference__c];
        
        Test.startTest();
        List<Notice_Legislative_Reference__c> noticeLegRef = NoticeLegislationController.loadNoticeLegislation(noticeLegRef1.Notice_Record__c);
        
        List<Notice_Legislative_Reference__c> noticeLegRefList = new List<Notice_Legislative_Reference__c>();
        noticeLegRefList.add(noticeLegRef[0]);
        
        String noticeLegRefString = JSON.serialize(noticeLegRefList);
        NoticeLegislationController.deleteNoticeLegislation(noticeLegRefString);
        Test.stopTest();
    }
}