@istest
public class FieldSetUtilTest {
    
    @istest
    public static void getFieldsTest(){
        FieldSetUtil.getFields('Notice_Record__c','WAT_First_Round');
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
        auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
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
        
        FieldSetUtil.getFields(noticeRecord.Id,'Notice_Record__c','WAT_First_Round');
    }   

}