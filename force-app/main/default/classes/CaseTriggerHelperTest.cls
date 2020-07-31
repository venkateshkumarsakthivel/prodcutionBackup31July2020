/**
*  Description: Test class for CaseTriggerHelper class
*/
@isTest
public class CaseTriggerHelperTest {
    
    public static Integer count = 200;
    
    //Setup data
    @testSetup
    static void setup() {
        //Create ICC Escalation Cases
        Id caseICCEscRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ICC Escalation').getRecordTypeId();
        List<Case> lCases = new List<Case> ();
        
        Set<String> ignoreFieldNames = new Set<String> ();
        ignoreFieldNames.add('Name');
        ignoreFieldNames.add('BusinessHoursId');
        
        Map<String, Object> caseValues;
        for (Integer i = 0; i<count; i++) {
            caseValues = new Map<String, Object> ();
            caseValues.put('RecordTypeId', caseICCEscRecordTypeId);
            caseValues.put('Status', 'New');
            caseValues.put('Description', 'Test Case-' + i);
            
            lCases.add((Case) TestDataFactory.createSObject('Case', caseValues, ignoreFieldNames));
        }
        insert lCases;
    }
    
    private static void generateTestData()
    {   
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        Id AuditNoticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Audit Notice').getRecordTypeId();
        List<Legislation__c> letList = new List<Legislation__c>();
        List<Case_Legislative_Reference__c> caseLegRefList = new List<Case_Legislative_Reference__c>();
        
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId,Notice_Email__c='test@nomail.com',Document_Delivery_Preference__c='Email');
        insert acc;
        
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        
        Id AuditCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId=AuditCaseRecordTypeId,Status='New',Subject='Test Case Open Notice',Description='Test Case Opne Notice Description',
                                AccountId = acc.Id,ContactId=con.Id);
        insert caseRec;
        
        Case caseRec1 = new Case(RecordTypeId=AuditCaseRecordTypeId,Status='New',Subject='Test Case Closed Notice',Description='Test Case Closed Notice Description',
                                 AccountId = acc.Id,ContactId=con.Id);
        insert caseRec1;
        
        List<Notice_Record__c> noticeList = new List<Notice_Record__c>();
        Notice_Record__c notice_record1 = new Notice_Record__c(RecordTypeId = AuditNoticeRecordTypeId, Comments__c = 'Test Draft Notice',Issued_To__c = acc.Id, Issued_to_Address__c = '477 PITT STREET HAYMARKET NSW 2000',                                                             
                                                               Issued_to_Email__c = 'test@nomail.com', Notice_Type__c = 'Levy Audit', Case__c = caseRec.Id, Show_On_Industry_Portal__c = 'No', Status__c = 'Draft',
                                                               Served_to__c = con.Id, Authorisation_Numbers__c = 'BSP-415415', Notice_Sub_Type__c = 'Audit Outcome', Number_of_Days__c = 14);
        noticeList.add(notice_record1);
        
        Notice_Record__c notice_record2 = new Notice_Record__c(RecordTypeId = AuditNoticeRecordTypeId, Comments__c = 'Test Closed Notice',Issued_To__c = acc.Id, Issued_to_Address__c = '477 PITT STREET HAYMARKET NSW 2000',                                                             
                                                               Issued_to_Email__c = 'test@nomail.com', Notice_Type__c = 'Levy Audit', Case__c = caseRec.Id, Show_On_Industry_Portal__c = 'No', Status__c = 'Closed',
                                                               Served_to__c = con.Id, Authorisation_Numbers__c = 'BSP-415415', Notice_Sub_Type__c = 'Levy Audit', Number_of_Days__c = 14);
        noticeList.add(notice_record2);
        
        Notice_Record__c notice_record3 = new Notice_Record__c(RecordTypeId = AuditNoticeRecordTypeId, Comments__c = 'Test Closed Notice',Issued_To__c = acc.Id, Issued_to_Address__c = '477 PITT STREET HAYMARKET NSW 2000',                                                             
                                                               Issued_to_Email__c = 'test@nomail.com', Notice_Type__c = 'Levy Audit', Case__c = caseRec1.Id, Show_On_Industry_Portal__c = 'No', Status__c = 'Closed',
                                                               Served_to__c = con.Id, Authorisation_Numbers__c = 'BSP-415415', Notice_Sub_Type__c = 'Levy Audit', Number_of_Days__c = 14);
        noticeList.add(notice_record3);
        
        Notice_Record__c notice_record4 = new Notice_Record__c(RecordTypeId = AuditNoticeRecordTypeId, Comments__c = 'Test Cancelled Notice',Issued_To__c = acc.Id, Issued_to_Address__c = '477 PITT STREET HAYMARKET NSW 2000',                                                             
                                                               Issued_to_Email__c = 'test@nomail.com', Notice_Type__c = 'Levy Audit', Case__c = caseRec1.Id, Show_On_Industry_Portal__c = 'No', Status__c = 'Cancelled',
                                                               Served_to__c = con.Id, Authorisation_Numbers__c = 'BSP-415415', Notice_Sub_Type__c = 'Audit Outcome', Number_of_Days__c = 14);
        noticeList.add(notice_record4);
        insert noticeList;
        System.debug('noticeList:'+noticeList.size());
    }
    
    @istest
    static void change_iccescalation_case_recordtype_to_enquiry() {
        
        //Change the Owner of ICC case to Compliance Queue
        List<Case> lICCCases = [SELECT
                                OwnerId
                                FROM Case
                                WHERE Record_Type_Dev_Name__c = :CaseTriggerHelper.CASE_RECORDTYPE_DEVNAME_ICC_ESCALATION];
        System.assertEquals(count, lICCCases.size());
        
        //Get Compliance Queue Id
        Id comlianceQueueId = [SELECT
                               Id
                               FROM Group
                               WHERE Type = 'Queue'
                               AND DeveloperName = :Label.Queue_DeveloperName_Compliance LIMIT 1].Id;
        //Assign all cases to compliance queues
        for (Case c : lICCCases) {
            c.OwnerId = comlianceQueueId;
        }
        
        Test.startTest();
        //Trigger update on case
        update lICCCases;
        Test.stopTest();
        
        lICCCases = [SELECT
                     Id
                     FROM Case
                     WHERE Record_Type_Dev_Name__c = :CaseTriggerHelper.CASE_RECORDTYPE_DEVNAME_ENQUIRY];
        //Assert on number of cases updated to Enquiry record type.
        System.assertEquals(count, lICCCases.size());
    }
    
    @istest    
    static void checkAllNoticeClosedForCase_OpenNotices(){
        
        Id p = GlobalUtility.getP2POperationsLevel1Profile().Id;
        
        User user = new User(alias = 'test123', email='testusr@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testusr@nomail.com');
        
        insert user;
        
        System.runAs(user){
            generateTestData();
            test.startTest();
            Case openNoticeCase = [SELECT Id, Status, Sub_Status__c
                                   FROM case
                                   WHERE Subject='Test Case Open Notice' LIMIT 1];
            
            openNoticeCase.Status= 'Closed';
            openNoticeCase.Sub_Status__c = 'Completed';        
            try{
                update openNoticeCase;
            }
            catch(Exception ex){
                Case UpdatedCase = [SELECT Id, Status, Sub_Status__c
                                    FROM case
                                    WHERE Subject='Test Case Open Notice'];
                System.assertNotEquals('Closed', UpdatedCase.Status);
            }
            test.stopTest();
        }
    }
    @istest    
    static void checkAllNoticeClosedForCase_ClosedNotices(){
        Id p = GlobalUtility.getP2POperationsLevel1Profile().Id;
        
        User user = new User(alias = 'test123', email='testusr@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testusr@nomail.com');
        
        insert user;
        
        System.runAs(user){
            generateTestData();
            test.startTest();
            Case closedNoticeCase = [SELECT Id, Status, Sub_Status__c
                                     FROM case
                                     WHERE Subject='Test Case Closed Notice' LIMIT 1];
            
            Case modifiedCase = closedNoticeCase;
            try{
                modifiedCase.Status= 'Closed';
                modifiedCase.Sub_Status__c = 'Completed';
                modifiedCase.ASP_Risk__c ='Low';
                update modifiedCase;
            }
            catch(Exception ex){
                Case UpdatedCase = [SELECT Id, Status, Sub_Status__c
                                    FROM case
                                    WHERE Subject='Test Case Closed Notice' LIMIT 1];
                System.debug('UpdatedCase:'+UpdatedCase);
                System.assertEquals('Closed', UpdatedCase.Status);
            }
            test.stopTest();
        }
    }
    
    /*
@istest
static void persist_case_age_test() {

//Retrieve all cases
List<Case> lCases = [SELECT
Status
FROM Case
WHERE Record_Type_Dev_Name__c = :CaseTriggerHelper.CASE_RECORDTYPE_DEVNAME_ICC_ESCALATION];
System.assertEquals(count, lCases.size());
Test.startTest();
//Mark All cases as Lodged
for (Case c : lCases) {
c.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
}
update lCases;

// Update the lodged timestamp on Cases to previous date
lCases = [SELECT
Status,
Case_Lodged_TimeStamp__c
FROM Case WHERE Id IN :lCases];
for (Case c : lCases) {
//Change Case ldoge timestamp to previous date to get positive number in Case Age field
c.Case_Lodged_TimeStamp__c = c.Case_Lodged_TimeStamp__c.addDays(- 5);
}
update lCases;

// Change the status of the cases from Lodged to Draft
for (Case c : lCases) {
c.Status = GlobalConstants.APPLICATION_STATUS_DRAFT;
}
update lCases;
Test.stopTest();

//All cases should have Case_Age_Past__c updated to 5
lCases = [SELECT
Id
FROM Case WHERE Id IN :lCases AND Case_Age_Past__c = 5];

//Assert on count
System.assertEquals(count, lCases.size());


}
*/
    
}