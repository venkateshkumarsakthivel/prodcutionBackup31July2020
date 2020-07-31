@isTest
public class AuditCaseCreationHandlerTest {

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
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Start_Date__c = System.Today(), End_Date__c = System.Today().addYears(5), Status__c = 'Granted With Conditions', Service_Provider__c = ac.Id);
        insert authRec; 
          
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, Levy_Contact__c = con.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayerData;
            
        Assessment__c tempRelatedAssessment = new Assessment__c();
        tempRelatedAssessment.Account__c = ac.Id;
        tempRelatedAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_ISSUED;
        tempRelatedAssessment.Period_Start_Date__c = System.Today().addMonths(-1);
        tempRelatedAssessment.Taxpayer_Registration__c = taxPayerData.Id;
        insert tempRelatedAssessment;
    }
    
    @isTest
    private static void postAuditCaseCreationAutomationTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        RecordType caseAuditRecordType = [SELECT Name FROM RecordType WHERE DeveloperName = 'Audit' AND SobjectType = 'Case'];  
        Test.startTest();
        
        Case tempAuditCase = new Case();
        tempAuditCase.RecordTypeId = caseAuditRecordType.Id;
        tempAuditCase.AccountId = accountId;
        insert tempAuditCase;
        Test.stopTest();
        
        Account tempAcc = [SELECT Authorisation_Details__c 
                            FROM Account];
                            
        System.assertNotEquals(NULL, tempAcc.Authorisation_Details__c);
    }
}