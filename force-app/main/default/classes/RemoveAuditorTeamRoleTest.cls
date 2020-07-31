@isTest
private class RemoveAuditorTeamRoleTest {
    
     static testMethod void ActiveTestMethod(){
    RemoveAuditorTeamRole act = new RemoveAuditorTeamRole();
  }
    /*
    @testSetup 
    static void setup() {
       
      Id ownerId = GlobalUtility.getOwnerId();
      Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
      
      RecordType accountAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Account'];
      RecordType contactAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit_Vendor' AND SobjectType = 'Contact'];
      RecordType caseAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit' AND SobjectType = 'Case'];  
        
      ac.RecordTypeId = accountAuditRecordType.Id;
      ac.Auditor_Type__c = 'External';
      ac.Auditor_Status__c = 'Active';
      ac.Equip_Vendor_Number__c = 'EVP1234';
      ac.Purchase_Order_Number__c = 'PO1234';
      insert ac;
      
      Contact con = new Contact(LastName ='testCon', firstName= 'test', AccountId = ac.Id, Email='test@contest.com');
      con.RecordTypeId = contactAuditRecordType.Id;
      con.Status__c = 'Active';
      
      insert con;
      
      ArxxusRFMv1__FYSettings__c tempSetting = new ArxxusRFMv1__FYSettings__c();
      tempSetting.Name = 'FYSM';
      tempSetting.ArxxusRFMv1__Fiscal_Year_Start_Month__c = 1;
      
      insert tempSetting;
      
      Case auditCase = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
      insert auditCase;
    }
    
    @isTest
    private static void removeAccountTeamMemberTest() {
      
      Account tempAcc = [SELECT Name FROM Account];
      Contact tempCon = [SELECT Audit_User__c FROM Contact];
      
      Profile auditUserProfile = [SELECT Name FROM Profile WHERE Name = :Label.External_Audit_User_Profile_Name];
      
      User externalAuditorUser = new User(alias = 'test123', email='test123@noemail.com',
                                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                           localesidkey='en_US', profileid = auditUserProfile.Id, country='United States', IsActive =true,
                                           Audit_Contact_Id__c = tempCon.Id, timezonesidkey='America/Los_Angeles', username='tester99@noemail.com');
                             
      insert externalAuditorUser;
      
      Test.startTest();
        
      AccountTeamMember tempAccountMember = new AccountTeamMember();
      tempAccountMember.AccountId = tempAcc.Id;
      tempAccountMember.UserId = externalAuditorUser.Id;
      tempAccountMember.AccountAccessLevel = 'Edit';
      tempAccountMember.TeamMemberRole = GlobalConstants.TEAM_ACCOUNT_AUDITOR_ROLE_NAME;
        
      insert tempAccountMember;
      
      AccountShare tempManualSharing = new AccountShare();
      tempManualSharing.AccountId = tempAcc.Id;
      tempManualSharing.UserOrGroupId = externalAuditorUser.Id;
      tempManualSharing.AccountAccessLevel = 'Edit';
      tempManualSharing.OpportunityAccessLevel = 'Edit';
      
      insert tempManualSharing;
      
      List<AccountTeamMember> accountTeamMember = [SELECT AccountId, UserId 
                                                   FROM AccountTeamMember
                                                   WHERE UserId = :externalAuditorUser.Id];
                                               
      System.assertEquals(1, accountTeamMember.size());                                         
      
      Case auditCase = [SELECT CaseNumber FROM Case];
      //auditCase.Lead_Auditor__c = tempCon.Id;
      auditCase.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
      auditCase.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_REPORT_APPROVAL;
      update auditCase;
      //
      Case auditCase1 = [SELECT CaseNumber FROM Case];
      //  
      auditCase1.Status = GlobalConstants.CLOSED_CASE_STATUS;
      auditCase1.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
      auditCase1.Audit_Vendor_Work_Estimate_Hours__c = 8;
      auditCase1.Audit_Vendor_Cost_Estimate__c = 1200;
      update auditCase1;
      
      accountTeamMember = [SELECT AccountId, UserId 
                                                   FROM AccountTeamMember
                                                   WHERE UserId = :externalAuditorUser.Id];
      Test.stopTest();
      System.assertEquals(0, accountTeamMember.size());
    }
*/
}