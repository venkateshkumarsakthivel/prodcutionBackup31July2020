@isTest
private class NoticeWATComplianceCloneControllerTest {
    
    @testSetup 
    static void setup() {
        Id ownerId = GlobalUtility.getOwnerId();
        
        Account aspAcc = new Account(name ='testASP', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        insert aspAcc;
        
        Contact aspCon = new Contact(LastName ='testASPCon', firstName= 'test', AccountId = aspAcc.Id, Email='test@contest.com');
        insert aspCon;
        
        RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
        RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
        RecordType caseAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Vary_Suspend_Cancel_Licence' AND SobjectType = 'Case'];  
        RecordType noticeRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Show_Cause' AND SobjectType = 'Notice_Record__c'];  
        
        Account ac = new Account(name ='testAuditor', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        ac.RecordTypeId = accountAuditRecordType.Id;
        ac.Auditor_Type__c = 'External';
        ac.Auditor_Status__c = 'Active';
        ac.Equip_Vendor_Number__c = 'EVP1234';
        ac.Purchase_Order_Number__c = 'PO1234';
        insert ac;
        
        Case cases = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
        cases.Audit_Vendor__c = ac.Id;
        cases.AccountId = aspAcc.Id;
        cases.ContactId = aspCon.Id;
        cases.Status = GlobalConstants.CASE_STATUS_NEW;
        cases.Subject = 'Test Case Subject';
        insert cases;
        
        Notice_Record__c noticeRec = new Notice_Record__c(RecordTypeId = noticeRecordType.Id, Case__c = cases.Id, Status__c ='Draft',Date_Issued__c=System.today(),Notice_Type__c='WAT compliance - preferential hiring',Notice_Sub_Type__c='Warning Letter WAT');
        insert noticeRec;
    }
    
    @isTest
    public static void getAuditCaseDetailsTest() {
        Notice_Record__c noticeRec = [SELECT Id FROM Notice_Record__c LIMIT 1];
        
        Test.startTest();
        System.assertNotEquals(null,NoticeWATComplianceCloneController.getNoticeRecord(noticeRec.Id));
        Test.stopTest();
    }
}