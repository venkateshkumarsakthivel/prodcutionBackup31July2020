@isTest
public class NoticeRecordAuditActionCaseTest{

@testSetup
 static void setup(){
 
        Id ownerId = GlobalUtility.getOwnerId();
        
        Profile auditUserProfile = [SELECT Name FROM Profile WHERE Name = 'P2P Compliance'];
        Account aspAcc = new Account(name ='testASP', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
        insert aspAcc;
        
        Contact aspCon = new Contact(LastName ='testASPCon', firstName= 'test', AccountId = aspAcc.Id, Email='test@contest.com');
        insert aspCon;
        
        
        User externalAuditorUser = new User(alias = 'test123', email='test123@noemail.com',
                                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                            localesidkey='en_US', profileid = auditUserProfile.Id, country='United States', IsActive =true,
                                            timezonesidkey='Australia/Sydney', username='tester99@noemail.com');
        insert externalAuditorUser;
        
        
        RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
        RecordType accountCompanyRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Company' AND SobjectType = 'Account'];
        RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
        RecordType noticeInspectRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Notice_to_Inspect' AND SobjectType = 'Notice_Record__c'];
        RecordType caseRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Action_Case' AND SobjectType = 'Case'];

        Account ac = new Account(name ='Internal Audit test account',OwnerId=ownerId);
        ac.RecordTypeId = accountAuditRecordType.Id;
        ac.Auditor_Type__c = 'Internal';
        ac.Auditor_Status__c = 'Active';
        insert ac;
        
        Account IssuedTo = new Account(name ='P2P TRANSPORT PTY LTD',OwnerId=ownerId,Notice_Email__c='vp@gmail.com'); 
        IssuedTo.RecordTypeId = accountCompanyRecordType.Id; 
        IssuedTo.ACN__c='617760 899';
        IssuedTo.Notice_Address_Street__c='Abc';
        IssuedTo.Notice_Address_State__c='Other';
        IssuedTo.Notice_Address_Postal_Code__c='4211';
        IssuedTo.Notice_Address_Country__c='Australia';
        IssuedTo.Notice_Address_City__c='Sydney';
        insert IssuedTo;  
        
     /*
        Contact Auhorized_officer = new Contact(LastName ='Mr. Internal Audit', firstName= 'test contact', AccountId = ac.Id,Role__c='Auditor');
        Auhorized_officer.RecordTypeId = contactAuditRecordType.Id;
        Auhorized_officer.Status__c = 'Active';
        Auhorized_officer.Audit_User__c=externalAuditorUser.Id;
        Auhorized_officer.Authorisation_Officer_number__c   ='123421';
        insert Auhorized_officer; */
        
        Contact Lead_auditor = new Contact(LastName ='Mr. Internal Lead Auditor', firstName= 'test contact', AccountId = ac.Id,Role__c='Auditor');
        Lead_auditor.RecordTypeId = contactAuditRecordType.Id;
        Lead_auditor.Status__c = 'Active';
        Lead_auditor.Audit_User__c=externalAuditorUser.Id;
        Lead_auditor.Authorisation_Officer_number__c    ='432';
        Lead_auditor.Safety_Accredit__c=true;
        Lead_auditor.Levy_Accredit__c=true; 
        insert Lead_auditor;
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = IssuedTo.Id);        
        insert authRec;
        Case c=new Case(status='New',sub_status__c='Preparation');
        c.RecordTypeId=caseRecordType.Id;
        insert c;
        Notice_Record__c notice=new Notice_Record__c(Issued_To__c=IssuedTo.Id,Served_to__c=Lead_auditor.Id,Description_Text_Block_1__c='abc',
                                                     Directions_Text_Block_1__c='abc',Directions_Text_Block_2__c='abc',Compliance_Date__c=System.Today()
                                                     ,Status__c='Draft');
        notice.RecordTypeId=noticeInspectRecordType.Id;
        notice.Case__c=c.Id;
        insert notice;
     
       /* Case c1=new Case(status='New',sub_status__c='Preparation');
        c1.RecordTypeId=caseRecordType.Id;
        insert c1;
        Notice_Record__c notice1=new Notice_Record__c(Authorised_Officer__c=Auhorized_officer.Id,Issued_To__c=IssuedTo.Id,Served_to__c=Lead_auditor.Id,Description_Text_Block_1__c='abc',
                                                     Directions_Text_Block_1__c='abc',Directions_Text_Block_2__c='abc',Compliance_Date__c=Date.parse('06/11/2018')
                                                     ,Status__c='Sent');
        notice1.RecordTypeId=noticeInspectRecordType.Id;
        notice1.Case__c=c1.Id;
        insert notice1;*/
            
 }
    
    @isTest
    static void checkIsRelatedCaseApprovedOnNCRecordTest(){
         
      Case auditactionCase = [SELECT CaseNumber FROM Case];
      Profile systemUserProfile = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
      
      User systemUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid = systemUserProfile.Id, country='United States', IsActive =true,
                                      timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
      insert systemUser;
      System.runAs(systemUser) {
       auditactionCase.Status = 'In Progress';
       update auditactionCase;  
      }
    }
}