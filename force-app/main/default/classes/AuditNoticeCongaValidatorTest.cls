@isTest
public class AuditNoticeCongaValidatorTest {
    
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
        ac.Auditor_Type__c = 'Internal';
        ac.Auditor_Status__c = 'Active';
        ac.Equip_Vendor_Number__c = 'EVP1234';
        ac.Purchase_Order_Number__c = 'PO1234';
        ac.Notice_Email__c = 'test@test.com';
        insert ac;
        
        Case auditCase = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
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
        
        Profile complianceUserProfile = [SELECT Name FROM Profile WHERE Name = 'P2P Compliance'];
        User complianceUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                       emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                       localesidkey='en_US', profileid = complianceUserProfile.Id, country='United States', IsActive =true,
                                       timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
        
        insert complianceUser; 
    }
    
    @isTest
    public static void validateNoticeRecordProhibition() {
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice',
            Notice_Sub_Type__c = 'Driver Eligibility'   
           // Description_Text_Block_1__c = '%% Instructions %%',
           // Description_Text_Block_2__c = '%% Instructions %%',
           // Description_Text_Block_3__c = '%% Instructions %%',
           // Legislation_Text_Block_1__c = '%% Instructions %%',
           // Directions_Text_Block_1__c =  '%% Instructions %%',
           // Directions_Text_Block_2__c = '%% Instructions %%',
            // Recommendations_Text_Block_1__c = '%% Instructions %%'
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                 WHERE Id =: noticeRecord.Id];
        System.assertNotEquals(true, insertedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, insertedNoticeRecord.Conga_Error_Message__c);
        
   /*     insertedNoticeRecord.Description_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_3__c = 'Instructions';
        insertedNoticeRecord.Legislation_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Directions_Text_Block_1__c =  'Instructions';
        insertedNoticeRecord.Directions_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Recommendations_Text_Block_1__c = 'Instructions';
        
        update insertedNoticeRecord;
        
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                WHERE Id =: noticeRecord.Id];
        System.assertEquals(false, updatedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, updatedNoticeRecord.Conga_Error_Message__c); */
        
        Test.stopTest();
    }
    
    @isTest
    public static void validateNoticeRecordNoticeToInspect() {
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Notice to Inspect').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S118 - Notice to inspect',
            Notice_Sub_Type__c = 'S118 - Notice to Inspect'   
        /*    Description_Text_Block_1__c = '%% Instructions %%',
            Description_Text_Block_2__c = '%% Instructions %%',
            Description_Text_Block_3__c = '%% Instructions %%',
            Legislation_Text_Block_1__c = '%% Instructions %%',
            Directions_Text_Block_1__c =  '%% Instructions %%',
            Directions_Text_Block_2__c = '%% Instructions %%',
            Recommendations_Text_Block_1__c = '%% Instructions %%' */
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                 WHERE Id =: noticeRecord.Id];
        System.assertNotEquals(true, insertedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, insertedNoticeRecord.Conga_Error_Message__c);
        
   /*     insertedNoticeRecord.Description_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_3__c = 'Instructions';
        insertedNoticeRecord.Legislation_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Directions_Text_Block_1__c =  'Instructions';
        insertedNoticeRecord.Directions_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Recommendations_Text_Block_1__c = 'Instructions';
        
        update insertedNoticeRecord;
        
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                WHERE Id =: noticeRecord.Id];
        System.assertEquals(false, updatedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, updatedNoticeRecord.Conga_Error_Message__c); */
        
        Test.stopTest();
    }
    
    @isTest
    public static void validateNoticeRecordNoticeToProduce() {
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Notice to Produce').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S121 - Notice to produce',
            Notice_Sub_Type__c = 'S121 - Notice to Produce'   
/*            Description_Text_Block_1__c = '%% Instructions %%',
            Description_Text_Block_2__c = '%% Instructions %%',
            Description_Text_Block_3__c = '%% Instructions %%',
            Legislation_Text_Block_1__c = '%% Instructions %%',
            Directions_Text_Block_1__c =  '%% Instructions %%',
            Directions_Text_Block_2__c = '%% Instructions %%',
            Recommendations_Text_Block_1__c = '%% Instructions %%' */
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                 WHERE Id =: noticeRecord.Id];
        System.assertNotEquals(true, insertedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, insertedNoticeRecord.Conga_Error_Message__c);
        /*
        insertedNoticeRecord.Description_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_3__c = 'Instructions';
        insertedNoticeRecord.Legislation_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Directions_Text_Block_1__c =  'Instructions';
        insertedNoticeRecord.Directions_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Recommendations_Text_Block_1__c = 'Instructions';
        
        update insertedNoticeRecord;
        
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                WHERE Id =: noticeRecord.Id];
        System.assertEquals(false, updatedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, updatedNoticeRecord.Conga_Error_Message__c); */
        
        Test.stopTest();
    }
    
    @isTest
    public static void validateNoticeRecordRequireInfo() {
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Require information (Tax)').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S72 - Require information (Tax)',
            Notice_Sub_Type__c = 'S72 - Require information (Tax)'   
/*            Description_Text_Block_1__c = '%% Instructions %%',
            Description_Text_Block_2__c = '%% Instructions %%',
            Description_Text_Block_3__c = '%% Instructions %%',
            Legislation_Text_Block_1__c = '%% Instructions %%',
            Directions_Text_Block_1__c =  '%% Instructions %%',
            Directions_Text_Block_2__c = '%% Instructions %%',
            Recommendations_Text_Block_1__c = '%% Instructions %%' */
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                 WHERE Id =: noticeRecord.Id];
        System.assertNotEquals(true, insertedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, insertedNoticeRecord.Conga_Error_Message__c);
       /* 
        insertedNoticeRecord.Description_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_3__c = 'Instructions';
        insertedNoticeRecord.Legislation_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Directions_Text_Block_1__c =  'Instructions';
        insertedNoticeRecord.Directions_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Recommendations_Text_Block_1__c = 'Instructions';
        
        update insertedNoticeRecord;
        
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c FROM Notice_Record__c 
                                                WHERE Id =: noticeRecord.Id];
        System.assertEquals(false, updatedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, updatedNoticeRecord.Conga_Error_Message__c);	*/
        
        Test.stopTest();
    }
    
    @isTest
    public static void validateNoticeRecordImprovementNotice() {
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c
                          ,Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Improvement Notice').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S83 - Improvement Notice'
/*                      Notice_Sub_Type__c = 'S83 - Improvement Notice'   
  Description_Text_Block_1__c = '%% Instructions %%',
            Description_Text_Block_2__c = '%% Instructions %%',
            Description_Text_Block_3__c = '%% Instructions %%',
            Legislation_Text_Block_1__c = '%% Instructions %%',
            Directions_Text_Block_1__c =  '%% Instructions %%',
            Directions_Text_Block_2__c = '%% Instructions %%',
            Recommendations_Text_Block_1__c = '%% Instructions %%' */
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c 
                                                 FROM Notice_Record__c 
                                                 WHERE Id =: noticeRecord.Id];
        System.assertNotEquals(true, insertedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, insertedNoticeRecord.Conga_Error_Message__c);
/*        
        insertedNoticeRecord.Description_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Description_Text_Block_3__c = 'Instructions';
        insertedNoticeRecord.Legislation_Text_Block_1__c = 'Instructions';
        insertedNoticeRecord.Directions_Text_Block_1__c =  'Instructions';
        insertedNoticeRecord.Directions_Text_Block_2__c = 'Instructions';
        insertedNoticeRecord.Recommendations_Text_Block_1__c = 'Instructions';
        
        update insertedNoticeRecord;
        
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Display_Conga_Error_Message__c, Conga_Error_Message__c 
                                                FROM Notice_Record__c 
                                                WHERE Id =: noticeRecord.Id];
        System.assertEquals(false, updatedNoticeRecord.Display_Conga_Error_Message__c);
        System.assertEquals(null, updatedNoticeRecord.Conga_Error_Message__c); */
        
        Test.stopTest();
    }
    
}