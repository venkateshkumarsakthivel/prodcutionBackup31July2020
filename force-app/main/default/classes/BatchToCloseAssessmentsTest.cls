@isTest
public class BatchToCloseAssessmentsTest {
	
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
            
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id, Levy_Contact__c = con.Id, ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayerData.Revenue_NSW_Status__c = 'Pending';
        taxPayerData.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayerData;
            
    }
    
	@isTest
    private static void getAccountDetailsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
    	Tax_Payer_Registration__c taxPayerData = [select id from Tax_Payer_Registration__c LIMIT 1];
        
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        List<Tax_Payer_Registration__c> taxPayerRegistrations = new List<Tax_Payer_Registration__c>();
        
        Tax_Payer_Registration__c taxPayer1 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer1.Revenue_NSW_Status__c = 'Pending';
        taxPayer1.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayerRegistrations.add(taxPayer1);
        
        Tax_Payer_Registration__c taxPayer2 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer2.Revenue_NSW_Status__c = 'Pending';
        taxPayer2.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayerRegistrations.add(taxPayer2);
        
        Tax_Payer_Registration__c taxPayer3 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer3.Revenue_NSW_Status__c = 'Pending';
        taxPayer3.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayerRegistrations.add(taxPayer3);
        
        Tax_Payer_Registration__c taxPayer4 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer4.Revenue_NSW_Status__c = 'Pending';
        taxPayer4.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        taxPayerRegistrations.add(taxPayer4);
		insert taxPayerRegistrations;
        
        Assessment__c assessment1 = new Assessment__c();
        assessment1.Account__c = accountId;
        assessment1.Status__c = 'Error';
        //assessment1.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment1.Taxpayer_Registration__c = taxPayer1.Id;
        assessmentList.add(assessment1);
        
        Assessment__c assessment2 = new Assessment__c();
        assessment2.Account__c = accountId;
        assessment2.Status__c = 'Closed';
        //assessment2.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment2.Taxpayer_Registration__c = taxPayer2.Id;
        assessmentList.add(assessment2);
        
        Assessment__c assessment3 = new Assessment__c();
        assessment3.Account__c = accountId;
        assessment3.Status__c = 'Outstanding';
        //assessment3.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment3.Payment_Due_Date__c = System.today();
        assessment3.Taxpayer_Registration__c = taxPayer3.Id;
        assessmentList.add(assessment3);
        
        Assessment__c assessment4 = new Assessment__c();
        assessment4.Account__c = accountId;
        assessment4.Status__c = 'Outstanding';
        //assessment3.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment4.Payment_Due_Date__c = System.today()-20;
        assessment4.Taxpayer_Registration__c = taxPayer4.Id;
        assessmentList.add(assessment4);
        insert assessmentList;

        Test.startTest();
            BatchToCloseAssessments closeAssessments = new BatchToCloseAssessments();
            Database.executeBatch(closeAssessments);
        Test.stopTest();

        assessment1 = [Select Id, Is_Closed__c FROM Assessment__c Where Id =: assessment1.Id];
        assessment2 = [Select Id, Is_Closed__c FROM Assessment__c Where Id =: assessment2.Id];
        assessment3 = [Select Id, Is_Closed__c FROM Assessment__c Where Id =: assessment3.Id];
		assessment4 = [Select Id, Is_Closed__c FROM Assessment__c Where Id =: assessment4.Id];

        System.assert(assessment1.Is_Closed__c);
        System.assert(assessment2.Is_Closed__c);
        System.assert(!assessment3.Is_Closed__c);
        System.assert(!assessment3.Is_Closed__c);
        
    }
    
    @isTest
    public static void testScheduler() {
    	Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Tax_Payer_Registration__c taxPayer1 = new Tax_Payer_Registration__c(Service_Provider_Name__c = accountId, Levy_Contact__c = conId, 
                                                                            ABN__c='123456789', Sub_Status__c = 'Completed', Status__c = 'Active');
        taxPayer1.Revenue_NSW_Status__c = 'Pending';
        taxPayer1.Rebate_Approval_Date__c = System.Today().addMonths(-2);
        insert taxPayer1;
       
        Assessment__c assessment1 = new Assessment__c();
        assessment1.Account__c = accountId;
        assessment1.Status__c = 'Error';
        //assessment1.Period_Start_Date__c = System.Today().addMonths(-1);
        assessment1.Taxpayer_Registration__c = taxPayer1.Id;
        insert assessment1;
        
        
        Test.startTest();
            SchedulableContext sc = null;
			ScheduleBatchToCloseAssessment scheduler = new ScheduleBatchToCloseAssessment();
        	scheduler.execute(sc);
        Test.stopTest();
    }
    
}