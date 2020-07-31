@isTest
public class LevyAdminCaseClosedProcessorTest {

    @testSetup 
    static void setup() {
    
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Authorisation__c tempAuth = new Authorisation__c();
        tempAuth.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        tempAuth.Service_Provider__c = ac.Id;
        insert tempAuth;
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, Levy_Contact__c = con.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayerData;
            
        Assessment__c tempRelatedAssessment = new Assessment__c();
        tempRelatedAssessment.Account__c = ac.Id;
        tempRelatedAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_OPEN;
        tempRelatedAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT;
        tempRelatedAssessment.Period_Start_Date__c = System.Today().addMonths(-2);
        tempRelatedAssessment.Taxpayer_Registration__c = taxPayerData.Id;
        insert tempRelatedAssessment;
    }
  
    @isTest
    private static void processClosedLevyCases() {
        
        Tax_Payer_Registration__c taxPayerData = [SELECT Id, Service_Provider_Name__c,
                                                  Levy_Contact__c FROM Tax_Payer_Registration__c];
        
        
        Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
        
        Case caseRecOne = new Case();
        Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME).getRecordTypeId();
       
        caseRecOne.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
        caseRecOne.AccountId = taxPayerData.Service_Provider_Name__c;
        caseRecOne.ContactId = taxPayerData.Levy_Contact__c;
        caseRecOne.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
        caseRecOne.Tax_Payer_Registration__c = taxPayerData.Id;
        caseRecOne.Assessment_Start_Date__c = System.Today().addMonths(-1);
        caseRecOne.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
        caseRecOne.RecordTypeId = levyAdministrationcCaseRecordTypeId;
        caseRecOne.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_AUDIT_AND_COMPLIANCE;
        
        insert caseRecOne;
        
        Case caseRecTwo = new Case();
        
        caseRecTwo.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
        caseRecTwo.AccountId = taxPayerData.Service_Provider_Name__c;
        caseRecTwo.ContactId = taxPayerData.Levy_Contact__c;
        caseRecTwo.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
        caseRecTwo.Tax_Payer_Registration__c = taxPayerData.Id;
        caseRecTwo.Assessment_Start_Date__c = System.Today().addMonths(-1);
        caseRecTwo.Assessment__c = tempRelatedAssessment.Id;
        caseRecTwo.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
        caseRecTwo.RecordTypeId = levyAdministrationcCaseRecordTypeId;
        caseRecTwo.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_AUDIT_AND_COMPLIANCE;
        caseRecTwo.Compromise_Assessment__c = 'Yes';
        insert caseRecTwo;
        
        Test.startTest();
        
        caseRecOne.Status = GlobalConstants.CLOSED_CASE_STATUS;
        caseRecOne.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        
        update caseRecOne;
        
        caseRecTwo.Status = GlobalConstants.CLOSED_CASE_STATUS;
        caseRecTwo.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        
        update caseRecTwo;
        
        tempRelatedAssessment = [SELECT Id, Status__c, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c WHERE Id = :tempRelatedAssessment.Id];
        System.assertEquals(tempRelatedAssessment.Status__c, GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED);
        
        Test.stopTest();
    }
    
    @isTest
    private static void processClosedLevyCasesHeldAssessmentApproved() {
        
        Tax_Payer_Registration__c taxPayerData = [SELECT Id, Service_Provider_Name__c,Levy_Contact__c
                                                  FROM Tax_Payer_Registration__c];
        
        
        Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
        
        Case caseRecOne = new Case();
        Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case
            										.getRecordTypeInfosByName()
            										.get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME)
            										.getRecordTypeId();
       
        caseRecOne.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
        caseRecOne.AccountId = taxPayerData.Service_Provider_Name__c;
        caseRecOne.ContactId = taxPayerData.Levy_Contact__c;
        caseRecOne.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
        caseRecOne.Tax_Payer_Registration__c = taxPayerData.Id;
        caseRecOne.Assessment__c = tempRelatedAssessment.Id;
        caseRecOne.Assessment_Start_Date__c = System.Today().addMonths(-1);
        caseRecOne.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
        caseRecOne.RecordTypeId = levyAdministrationcCaseRecordTypeId;
        caseRecOne.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_HELD_ASSESSMENT;
        caseRecOne.Compromise_Assessment__c = 'Yes';
        
        insert caseRecOne;
        
        Test.startTest();
        
        caseRecOne.Status = GlobalConstants.CLOSED_CASE_STATUS;
        caseRecOne.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        
        update caseRecOne;
        
        Test.stopTest();
    }

    @isTest
    private static void processClosedLevyCasesHeldAssessmentDeclined() {
        
        Tax_Payer_Registration__c taxPayerData = [SELECT Id, Service_Provider_Name__c,Levy_Contact__c
                                                  FROM Tax_Payer_Registration__c];
        
        
        Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
        
        Case caseRecOne = new Case();
        Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case
            										.getRecordTypeInfosByName()
            										.get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME)
            										.getRecordTypeId();
       
        caseRecOne.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
        caseRecOne.AccountId = taxPayerData.Service_Provider_Name__c;
        caseRecOne.ContactId = taxPayerData.Levy_Contact__c;
        caseRecOne.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
        caseRecOne.Tax_Payer_Registration__c = taxPayerData.Id;
        caseRecOne.Assessment__c = tempRelatedAssessment.Id;
        caseRecOne.Assessment_Start_Date__c = System.Today().addMonths(-1);
        caseRecOne.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
        caseRecOne.RecordTypeId = levyAdministrationcCaseRecordTypeId;
        caseRecOne.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_HELD_ASSESSMENT;
        caseRecOne.Estimation_Assessment__c = 'Yes';
		caseRecOne.Estimate_Reason_Code__c = 'Compliance';
        insert caseRecOne;
        
        Test.startTest();
        
        caseRecOne.Status = GlobalConstants.CLOSED_CASE_STATUS;
        caseRecOne.Sub_Status__c = GlobalConstants.DECLINED_CASE_SUB_STATUS;
        
        update caseRecOne;
        
        Test.stopTest();
    }

    //test assessments which were submitted to revenue before
    @isTest
    private static void processClosedLevyCasesAssessmentSubmitted() {
        
        Tax_Payer_Registration__c taxPayerData = [SELECT Id, Service_Provider_Name__c,
                                                  Levy_Contact__c FROM Tax_Payer_Registration__c];
        
        
        Assessment__c tempRelatedAssessment = [SELECT Id, Period_End_Date__c, Period_Start_Date__c, Taxpayer_Registration__c FROM Assessment__c];
        
        tempRelatedAssessment.Revenue_Assessment_Number_BSP__c = '123456';
        tempRelatedAssessment.Revenue_Assessment_Number_TSP__c = '123457';
        update tempRelatedAssessment;

        Case caseRecOne = new Case();
        Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME).getRecordTypeId();
       
        caseRecOne.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
        caseRecOne.AccountId = taxPayerData.Service_Provider_Name__c;
        caseRecOne.ContactId = taxPayerData.Levy_Contact__c;
        caseRecOne.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
        caseRecOne.Tax_Payer_Registration__c = taxPayerData.Id;
        caseRecOne.Assessment_Start_Date__c = System.Today().addMonths(-1);
        caseRecOne.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
        caseRecOne.RecordTypeId = levyAdministrationcCaseRecordTypeId;
        caseRecOne.Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_OTHER;
        caseRecOne.Assessment__c = tempRelatedAssessment.Id;
        
        insert caseRecOne;
        
        Test.startTest();
        
        caseRecOne.Status = GlobalConstants.CLOSED_CASE_STATUS;
        caseRecOne.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        
        update caseRecOne;
        
        Assessment__c  reassessment = [SELECT Id, Status__c, Period_End_Date__c, Period_Start_Date__c, Issue_Date__c FROM Assessment__c WHERE Assessment_Type__c = :GlobalConstants.ASSESSMENT_TYPE_REASSESSMENT LIMIT 1];
        System.assertEquals(reassessment.Issue_Date__c, System.today());
        
        Test.stopTest();
    }    
}