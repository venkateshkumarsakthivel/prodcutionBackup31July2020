@isTest
private class AuditDetailedFindingsReviewConTest {
    
     static testMethod void ActiveTestMethod(){
    AuditDetailedFindingsReviewController act = new AuditDetailedFindingsReviewController();
  }
   /* 
    @testSetup 
    static void setup() {
      
      Id ownerId = GlobalUtility.getOwnerId();
      
      Account aspAcc = new Account(name ='testASP', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
      insert aspAcc;
      
      Contact aspCon = new Contact(LastName ='testASPCon', firstName= 'test', AccountId = aspAcc.Id, Email='test@contest.com');
      insert aspCon;
      
      Account ac = new Account(name ='testAuditor', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000', OwnerId=ownerId);
      
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
      
      ArxxusRFMv1__Branding__c tempBrandSetting = new ArxxusRFMv1__Branding__c();
      tempBrandSetting.Name = 'Brands';
      
      insert tempBrandSetting;
      
      ArxxusRFMv1__questionDefinition__c tempQuestion = new ArxxusRFMv1__questionDefinition__c();
      tempQuestion.ArxxusRFMv1__questionDetails__c = 'Test Question 1';
      tempQuestion.ArxxusRFMv1__status__c = 'Active';
      tempQuestion.ArxxusRFMv1__fieldType__c = 'Text';
      
      insert tempQuestion;
      
      ArxxusRFMv1__Survey__c tempSurvey = new ArxxusRFMv1__Survey__c();
      tempSurvey.Name = 'Test Survey';
      tempSurvey.ArxxusRFMv1__Status__c = 'Active';
      
      insert tempSurvey;
      
      ArxxusRFMv1__surveyQuestion__c surveyQuestion = new ArxxusRFMv1__surveyQuestion__c();
      surveyQuestion.ArxxusRFMv1__questionDefinition__c = tempQuestion.Id;
      surveyQuestion.ArxxusRFMv1__survey__c = tempSurvey.Id;
      
      ArxxusRFMv1__Task_Type__c tempTaskType = new ArxxusRFMv1__Task_Type__c();
      tempTaskType.Name = 'Test Survey';
      tempTaskType.ArxxusRFMv1__Estimated_Task_Time__c = 15;
      tempTaskType.ArxxusRFMv1__Is_Active__c = TRUE;
      
      insert tempTaskType;
      
      ArxxusRFMv1__Visit_Template__c tempVisitTemplate = new ArxxusRFMv1__Visit_Template__c();
      tempVisitTemplate.ArxxusRFMv1__Template_Name__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
      insert tempVisitTemplate;
      
      ArxxusRFMv1__Visit_Template_Entry__c tempVisitTemplateEntry = new ArxxusRFMv1__Visit_Template_Entry__c();
      tempVisitTemplateEntry.ArxxusRFMv1__Survey__c = tempSurvey.Id;
      tempVisitTemplateEntry.ArxxusRFMv1__Visit_Template__c = tempVisitTemplate.Id;
      tempVisitTemplateEntry.ArxxusRFMv1__Task_Type__c = tempTaskType.Id;
      
      insert tempVisitTemplateEntry;
      
      Case auditCase = new Case(AccountId = ac.Id, RecordTypeId = caseAuditRecordType.Id);
      auditCase.Audit_Vendor__c = ac.Id;
      auditCase.AccountId = aspAcc.Id;
      auditCase.ContactId = aspCon.Id;
      auditCase.Sub_Type__c = GlobalConstants.SAFETY_FULL_AUDIT_SUB_TYPE;
      auditCase.Status = 'In Progress';
      auditCase.Sub_Status__c = 'Planning';
      auditCase.Audit_Target_Start_Date__c = System.Today();
      auditCase.Audit_Target_End_Date__c = System.Today()+3;
      insert auditCase;
     
    }
    
    @isTest
    private static void fetchAuditVisitTest() {
      
      Account tempAcc = [SELECT Name FROM Account WHERE Name = 'testAuditor'];
      Contact tempCon = [SELECT Audit_User__c FROM Contact WHERE LastName ='testASPCon'];
      Case auditCase = [SELECT CaseNumber FROM Case];
      
      Profile auditUserProfile = [SELECT Name FROM Profile WHERE Name = :Label.External_Audit_User_Profile_Name];
      
      User externalAuditorUser = new User(alias = 'test123', email='test123@noemail.com',
                                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                           localesidkey='en_US', profileid = auditUserProfile.Id, country='United States', IsActive =true,
                                           Audit_Contact_Id__c = tempCon.Id, timezonesidkey='Australia/Sydney', username='tester99@noemail.com');
                             
      insert externalAuditorUser;
      
      Profile systemUserProfile = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
      
      User systemUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid = systemUserProfile.Id, country='United States', IsActive =true,
                                      timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
                             
      insert systemUser;
      
      Test.startTest();
      AuditCallCycleCreationBatch batch = new AuditCallCycleCreationBatch(); 
      database.executebatch(batch);
      Test.stopTest();
      
      System.runAs(systemUser) {
        
       auditCase.Lead_Auditor__c = tempCon.Id;
       auditCase.Status = 'In Progress';
       auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING;
       auditCase.Notice_Email_Sent__c = TRUE;
       update auditCase;
        
      }
     
          
      ArxxusRFMv1__Visit__c auditVisit = [SELECT Audit_Case__c, ArxxusRFMv1__Status__c 
                                          FROM ArxxusRFMv1__Visit__c
                                          WHERE Audit_Case__c = :auditCase.Id];
                                          
      ArxxusRFMv1__Visit__c returnedAudit = AuditDetailedFindingsReviewController.fetchAuditVisit(auditVisit.Id);
      System.assertNotEquals(NULL, returnedAudit);

     
    }
    
    @isTest
    private static void saveAuditCaseTest() {
      
      Account tempAcc = [SELECT Name FROM Account WHERE Name = 'testAuditor'];
      Contact tempCon = [SELECT Audit_User__c FROM Contact WHERE LastName ='testASPCon'];
      Case auditCase = [SELECT CaseNumber FROM Case];
      
      Test.startTest();
      System.assertEquals(TRUE, AuditDetailedFindingsReviewController.saveAuditCase(auditCase.Id));
      Test.stopTest();
    }
    
    @isTest
    private static void returnCaseForDetailedFindingsTest() {
      
      Account tempAcc = [SELECT Name FROM Account WHERE Name = 'testAuditor'];
      Contact tempCon = [SELECT Audit_User__c FROM Contact WHERE LastName ='testASPCon'];
      Case auditCase = [SELECT CaseNumber FROM Case];
      
      Test.startTest();
      System.assertNotEquals(NULL, AuditDetailedFindingsReviewController.returnCaseForDetailedFindings(auditCase.Id));
      Test.stopTest();
    }
    
    @isTest
    private static void getAuditDetailsTest() {
      
      Account tempAcc = [SELECT Name FROM Account WHERE Name = 'testAuditor'];
      Contact tempCon = [SELECT Audit_User__c FROM Contact WHERE LastName ='testASPCon'];
      Case auditCase = [SELECT CaseNumber FROM Case];
      
      Profile auditUserProfile = [SELECT Name FROM Profile WHERE Name = :Label.External_Audit_User_Profile_Name];
      
      User externalAuditorUser = new User(alias = 'test123', email='test123@noemail.com',
                                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                           localesidkey='en_US', profileid = auditUserProfile.Id, country='United States', IsActive =true,
                                           Audit_Contact_Id__c = tempCon.Id, timezonesidkey='Australia/Sydney', username='tester99@noemail.com');
                             
      insert externalAuditorUser;
      
      Profile systemUserProfile = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
      
      User systemUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid = systemUserProfile.Id, country='United States', IsActive =true,
                                      timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
                             
      insert systemUser;
      
      Test.startTest();
      AuditCallCycleCreationBatch batch = new AuditCallCycleCreationBatch(); 
      database.executebatch(batch);
      Test.stopTest();
      
      System.runAs(systemUser) {
        
       auditCase.Lead_Auditor__c = tempCon.Id;
       auditCase.Status = 'In Progress';
       auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING;
       auditCase.Notice_Email_Sent__c = TRUE;
       update auditCase;
        
      }
      
          
      ArxxusRFMv1__Visit__c auditVisit = [SELECT Audit_Case__c, ArxxusRFMv1__Status__c 
                                          FROM ArxxusRFMv1__Visit__c
                                          WHERE Audit_Case__c = :auditCase.Id];
                                          
      auditVisit.ArxxusRFMv1__Status__c  = GlobalConstants.VISIT_STATUS_COMPLETED;
      auditVisit.ArxxusRFMv1__Actual_Start__c = System.Now();
      auditVisit.ArxxusRFMv1__Actual_End__c = System.Now();
      
      update auditVisit;
      
      ArxxusRFMv1__questionDefinition__c tempQuestion = [SELECT Id FROM ArxxusRFMv1__questionDefinition__c];
      ArxxusRFMv1__taskSurvey__c tempTaskSurvey = [SELECT Id FROM ArxxusRFMv1__taskSurvey__c];
                               
      ArxxusRFMv1__taskSurveyAnswer__c tempAnswer = new ArxxusRFMv1__taskSurveyAnswer__c();
      tempAnswer.ArxxusRFMv1__questionDefinition__c = tempQuestion.Id; 
      tempAnswer.ArxxusRFMv1__answer__c = 'Test Answer';   
      tempAnswer.ArxxusRFMv1__taskSurvey__c = tempTaskSurvey.Id;
      
      insert tempAnswer;
      
      Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>> surveyAnsMap = new Map<String, List<ArxxusRFMv1__taskSurveyAnswer__c>>();
      surveyAnsMap = AuditDetailedFindingsReviewController.getAuditDetails(auditVisit.Id); 
      System.assertNotEquals(0, surveyAnsMap.size());

      
    }
    
    @isTest
    private static void saveAuditReviewCommentsTest() {
      
      Account tempAcc = [SELECT Name FROM Account WHERE Name = 'testAuditor'];
      Contact tempCon = [SELECT Audit_User__c FROM Contact WHERE LastName ='testASPCon'];
      Case auditCase = [SELECT CaseNumber FROM Case];
      
      Profile auditUserProfile = [SELECT Name FROM Profile WHERE Name = :Label.External_Audit_User_Profile_Name];
      
      User externalAuditorUser = new User(alias = 'test123', email='test123@noemail.com',
                                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                           localesidkey='en_US', profileid = auditUserProfile.Id, country='United States', IsActive =true,
                                           Audit_Contact_Id__c = tempCon.Id, timezonesidkey='Australia/Sydney', username='tester99@noemail.com');
                             
      insert externalAuditorUser;
      
      Profile systemUserProfile = [SELECT Name FROM Profile WHERE Name = 'System Administrator'];
      
      User systemUser = new User(alias = 'test1234', email='test1234@noemail.com',
                                      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid = systemUserProfile.Id, country='United States', IsActive =true,
                                      timezonesidkey='Australia/Sydney', username='tester89@noemail.com');
                             
      insert systemUser;
      
      Test.startTest();
      AuditCallCycleCreationBatch batch = new AuditCallCycleCreationBatch(); 
      database.executebatch(batch);
      Test.stopTest();
      
      System.runAs(systemUser) {
        
       auditCase.Lead_Auditor__c = tempCon.Id;
       auditCase.Status = 'In Progress';
       auditCase.Sub_Status__c = GlobalConstants.CASE_SUBSTATUS_AUDIT_PENDING;
       auditCase.Notice_Email_Sent__c = TRUE;
       update auditCase;
        
      }
     
          
      ArxxusRFMv1__Visit__c auditVisit = [SELECT Audit_Case__c, ArxxusRFMv1__Status__c 
                                          FROM ArxxusRFMv1__Visit__c
                                          WHERE Audit_Case__c = :auditCase.Id];
                                          
      auditVisit.ArxxusRFMv1__Status__c  = GlobalConstants.VISIT_STATUS_COMPLETED;
      auditVisit.ArxxusRFMv1__Actual_Start__c = System.Now();
      auditVisit.ArxxusRFMv1__Actual_End__c = System.Now();
      
      update auditVisit;
      
      ArxxusRFMv1__questionDefinition__c tempQuestion = [SELECT Id FROM ArxxusRFMv1__questionDefinition__c];
      ArxxusRFMv1__taskSurvey__c tempTaskSurvey = [SELECT Id FROM ArxxusRFMv1__taskSurvey__c];
                               
      ArxxusRFMv1__taskSurveyAnswer__c tempAnswer = new ArxxusRFMv1__taskSurveyAnswer__c();
      tempAnswer.ArxxusRFMv1__questionDefinition__c = tempQuestion.Id; 
      tempAnswer.ArxxusRFMv1__answer__c = 'Test Answer';   
      tempAnswer.ArxxusRFMv1__taskSurvey__c = tempTaskSurvey.Id;
      
      insert tempAnswer;
      
      List<ArxxusRFMv1__taskSurveyAnswer__c> tempAnswerList = new List<ArxxusRFMv1__taskSurveyAnswer__c>();
      tempAnswerList.add(tempAnswer);
      
      System.assertEquals(TRUE, AuditDetailedFindingsReviewController.saveAuditReviewComments(tempAnswerList, auditVisit.Id));

      
    }
*/
}