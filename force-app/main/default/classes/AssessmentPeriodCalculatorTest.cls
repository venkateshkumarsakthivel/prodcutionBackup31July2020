@isTest
public class AssessmentPeriodCalculatorTest {
    
    @testSetup 
    private static void setupTestData() {
        
        /* Account with Company RecordType */
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth;
        
        tspauth.Start_Date__c = Date.parse('10/12/2017');
        update tspauth;  
        
        /* Authorisation__c Related to Individual account */
        Authorisation__c bspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'BSP');
        insert bspauth;
        
        bspauth.Start_Date__c = Date.parse('2/2/2018');
        update bspauth;  
        
        /* Lookup to TSP and BSP both */
        Tax_Payer_Registration__c taxpayerRegistrationRecord = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                             Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS,
                                                                                             Taxi_Service_Provider_Number__c = tspauth.Id, Booking_Service_Provider_Number__c = bspAuth.Id,
                                                                                             BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                             Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                             Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                             Levy_Notification_Address_Street__c = 'castle');
        insert taxpayerRegistrationRecord;
        
        Date firstDateOfPreviousMonth = Date.newInstance(2018, 01, 01);
        Date lastDateOfPreviousMonth = Date.newInstance(2018, 01, 31);
        
        Assessment__c assessmentRecord = new Assessment__c();
        assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Assessment_Type__c = 'Assessment';
        assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
        assessmentRecord.Levy__c = Decimal.valueOf(System.Label.Levy_Amount_Per_Trip);
        insert assessmentRecord;
    }
    
    @isTest
    public static void calculateLevyPeriod1() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        AssessmentPeriodCalculator assessmentPeriodCalculator = new AssessmentPeriodCalculator();
        assessmentPeriodCalculator.calculatePeriod(listAssessments);
    }
    
    @isTest
    public static void calculateLevyPeriod2() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        assessmentRecord.Period_Start_Date__c = null;
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2017, 01, 01);
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        AssessmentPeriodCalculator assessmentPeriodCalculator = new AssessmentPeriodCalculator();
        assessmentPeriodCalculator.calculatePeriod(listAssessments);
    }
     @isTest
     public static void calculateLevyPeriod3() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        assessmentRecord.Period_Start_Date__c = Date.newInstance(2018, 02, 01);
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2017, 01, 01);
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        AssessmentPeriodCalculator assessmentPeriodCalculator = new AssessmentPeriodCalculator();
        assessmentPeriodCalculator.calculatePeriod(listAssessments);
    }
    
    @isTest
     public static void calculateLevyPeriod4() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        assessmentRecord.Period_Start_Date__c = Date.newInstance(2017, 02, 01);
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2017, 02, 24);
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        AssessmentPeriodCalculator assessmentPeriodCalculator = new AssessmentPeriodCalculator();
        assessmentPeriodCalculator.calculatePeriod(listAssessments);
    }
}