@isTest
public class NoticeRecordIssuedToEmailUpdatorTest {
    
    @testSetup 
    static void setup() {
        
        Id ownerId = GlobalUtility.getOwnerId();
        
        Account aspAcc = new Account(Notice_Email__c='notice.email@test.com', name ='testASP', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
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
        
        Authorisation__c bspAuth = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = aspAcc.Id);
        Authorisation__c tspAuth = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = aspAcc.Id);
        insert bspAuth;
        insert tspAuth;
    }
    
    @isTest
    public static void updateEmailOnCreateanUpdateTest() {
        
        Case auditCase = [SELECT Id, AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                        Audit_Vendor__c, // Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c,
                        Account.Notice_Email__c, Record_Type_Dev_Name__c FROM Case];
        
        Id noticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        
        Notice_Record__c noticeRecord = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
            //Notice_Sub_Type__c = 'S87 - Prohibition Notice',   
        /*    Description_Text_Block_1__c = 'Instructions',
            Description_Text_Block_2__c = 'Instructions',
            Description_Text_Block_3__c = 'Instructions',
            Legislation_Text_Block_1__c = 'Instructions',
            Directions_Text_Block_1__c =  'Instructions',
            Directions_Text_Block_2__c = 'Instructions',
            Recommendations_Text_Block_1__c = 'Instructions' */
        );
        
        Notice_Record__c noticeRecord1 = new Notice_Record__c(
            RecordTypeId = noticeRecordTypeId,
            Status__c= 'Draft',
            Show_On_Industry_Portal__c= 'No',
            Issued_To__c= auditCase.AccountId,
            Served_to__c= auditCase.ContactId,
            Case__c= auditCase.Id,
            Notice_Type__c = 'S87 - Prohibition Notice'
            //Notice_Sub_Type__c = 'S87 - Prohibition Notice',   
        /*    Description_Text_Block_1__c = 'Instructions',
            Description_Text_Block_2__c = 'Instructions',
            Description_Text_Block_3__c = 'Instructions',
            Legislation_Text_Block_1__c = 'Instructions',
            Directions_Text_Block_1__c =  'Instructions',
            Directions_Text_Block_2__c = 'Instructions',
            Recommendations_Text_Block_1__c = 'Instructions',
            Method_of_Service__c = 'In Person' */
        );
        
        Test.startTest();
        
        insert noticeRecord;
        
        insert noticeRecord1;
        
        Account acc = [select Id, Notice_Email__c from Account where name ='testASP'];
        
        Notice_Record__c insertedNoticeRecord = [SELECT Id, Issued_to_Email__c FROM Notice_Record__c 
                       WHERE Id =: noticeRecord.Id];
        
        System.assertEquals(acc.Notice_Email__c, insertedNoticeRecord.Issued_to_Email__c);
        
        insertedNoticeRecord.Method_of_Service__c = 'Email';
        
        update insertedNoticeRecord;
       
        Notice_Record__c updatedNoticeRecord = [SELECT Id, Issued_to_Email__c FROM Notice_Record__c 
                       WHERE Id =: noticeRecord.Id];
        
        System.assertEquals(acc.Notice_Email__c, updatedNoticeRecord.Issued_to_Email__c);
        
        Profile complianceUserProfile = [SELECT Name FROM Profile WHERE Name = 'P2P Compliance'];
        User complianceUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                       emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                       localesidkey='en_US', profileid = complianceUserProfile.Id, country='United States', IsActive =true,
                                       timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
        
        insert complianceUser; 
        
        System.runAs(complianceUser) {
            updatedNoticeRecord.Method_of_Service__c = 'In Person';
            
            update updatedNoticeRecord;
            
            updatedNoticeRecord = [SELECT Id, Issued_to_Email__c FROM Notice_Record__c 
                                   WHERE Id =: noticeRecord.Id];
            
            System.assertEquals(complianceUser.email, updatedNoticeRecord.Issued_to_Email__c);
        }
        Test.stopTest();
    }
    
}