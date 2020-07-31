@isTest
public class AssessmentLevyAmountCalculatorTest {
    
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
         //System.debug( 'TPR start date is' + tspauth.Start_Date__c );
       
        Date firstDateOfPreviousMonth = Date.newInstance(2018, 1, 1);
        Date lastDateOfPreviousMonth = Date.newInstance(2018, 1, 31);
        
        Assessment__c assessmentRecord = new Assessment__c();
        assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Assessment_Type__c = 'Assessment';
        assessmentRecord.Period_Start_Date__c = firstDateOfPreviousMonth;
        assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
        assessmentRecord.Levy__c = Decimal.valueOf(System.Label.Levy_Amount_Per_Trip);
        insert assessmentRecord;

    }

    @isTest
    public static void calculateLevyAmountManualAssessmentYes() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        
        assessmentRecord.Manual_Assessment_Required__c = 'Yes';
        assessmentRecord.BSP_Transaction_Count__c = 200;
        assessmentRecord.TSP_Transaction_Count__c = 200;
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_HELD, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c, 400);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 200);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 200);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY);
        
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Rebate_Approval_Date__c = System.today();
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
    }
    
    @isTest
    public static void calculateLevyAmountTestExemptionApproved() 
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        
        
        assessmentRecord.Exemption_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2017, 12, 26);
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);  
        
        System.assertEquals(assessmentRecord.Rebate_Approval_Date__c.addMonths(-1).month(), 11);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c, 0);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 0);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 0);
        
        assessmentRecord.Exemption_Approved__c = false;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2017, 12, 26);
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);  
        
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
    }
    @isTest
    public static void calculateLevyAmountTestExemptionNotApproved_annualEstimatesFewerThan150() 
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord); 
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        
        assessmentRecord.Exemption_Approved__c = false;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesFewerThan150;
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Exemption_Approved__c = false;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesFewerThan150;
        assessmentRecord.BSP_Transaction_Count__c=100;
        assessmentRecord.TSP_Transaction_Count__c=20;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,120);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 100);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 20);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Exemption_Approved__c = false;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesFewerThan150;
        assessmentRecord.BSP_Transaction_Count__c=100;
        assessmentRecord.TSP_Transaction_Count__c=200;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
        
        assessmentRecord.BSP_Transaction_Count__c=Null;
        assessmentRecord.TSP_Transaction_Count__c=Null;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
    }

    @isTest
    public static void calculateLevyAmountTestRebateApproved()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id ,Taxi_Service_Provider_Number__c,Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c , Booking_Service_Provider_Number__c ,Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, 
                                          Status__c, BSP_Transaction_Count__c, 
                                          TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, 
                                          TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        
        System.debug(assessmentRecord);
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord);
        //----  levyPeriodAnniversaryMonth != levyPeriodMonth
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c=true;
        assessmentRecord.Rebate_Approval_Date__c= Date.newInstance(2018, 3, 2);
        //AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        //System.assertEquals(assessmentRecord.Status__c,GlobalConstants.ASSESSMENT_STATUS_ASSESSED);
       // System.assertEquals(assessmentRecord.Total_Levy_Amount__c,0);
       // System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 0);
       // System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 0);
        
          //----  levyPeriodAnniversaryMonth = levyPeriodMonth
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
         assessmentRecord.Rebate_Approved__c=true;
        assessmentRecord.Rebate_Approval_Date__c= Date.newInstance(2018, 2, 2);
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        assessmentRecord.TSP_Transaction_Count__c = 50;
        assessmentRecord.BSP_Transaction_Count__c = 50;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,0);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2018, 2, 2);
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        assessmentRecord.TSP_Transaction_Count__c = 80;
        assessmentRecord.BSP_Transaction_Count__c = 80;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c,75);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c,75);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400; 
        assessmentRecord.BSP_Transaction_Count__c = 250;
        assessmentRecord.TSP_Transaction_Count__c = 250;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,400);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = true;
        assessmentRecord.Rebate_Approval_Date__c = Date.newInstance(2018, 2, 2);
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween401and600;
        assessmentRecord.BSP_Transaction_Count__c = null;
        assessmentRecord.TSP_Transaction_Count__c = null;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_HELD, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,0);
        
        assessmentRecord.BSP_Transaction_Count__c = 350;
        assessmentRecord.TSP_Transaction_Count__c = 350;
         assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween401and600;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_HELD, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c,350);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c,350);
    
       }

    @isTest
    public static void calculateLevyAmountTestRebateNotApproved_and_ExemptionNotApproved()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c, Period_Start_Date__c, Period_End_Date__c, 
                                          Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, 
                                          Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c, 
                                          Taxpayer_Registration__r.Booking_Service_Provider_Number__c
                                          FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord); 
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF);
        System.debug('bsp: '+assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c+' Tsp: '+assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c+' bsp count: '+assessmentRecord.BSP_Transaction_Count__c +' tsp count: '+assessmentRecord.TSP_Transaction_Count__c);

        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        assessmentRecord.BSP_Transaction_Count__c = 200;
        assessmentRecord.TSP_Transaction_Count__c = 150;
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        
        System.assertEquals(assessmentRecord.Status__c,GlobalConstants.ASSESSMENT_STATUS_ASSESSED);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,350);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 200);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 150);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween151and400;
        assessmentRecord.BSP_Transaction_Count__c = 300;
        assessmentRecord.TSP_Transaction_Count__c = 150;
        
        AssessmentLevyAmountCalculator.calculate(listAssessments, true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
        
        //-------- Annual trip estimates between 401 and 600
        //
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.BSP_Transaction_Count__c = null;
        assessmentRecord.TSP_Transaction_Count__c = null;
        
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesBetween401and600 ;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.BSP_Transaction_Count__c = 300;
        assessmentRecord.TSP_Transaction_Count__c = 250;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
        
        System.assertEquals(assessmentRecord.Status__c,GlobalConstants.ASSESSMENT_STATUS_ASSESSED);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,550);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 300);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 250);
        
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Rebate_Approved__c = False;
        assessmentRecord.Exemption_Approved__c=False;
        assessmentRecord.BSP_Transaction_Count__c = 300;
        assessmentRecord.TSP_Transaction_Count__c = 350;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
       
        System.assertEquals(GlobalConstants.ASSESSMENT_STATUS_ASSESSED, assessmentRecord.Status__c);
        System.assertEquals(assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF);
        
    }
    //-------- annualEstimatesOver600
    @isTest
    public static void calculateLevyAmountTest_annualEstimatesOver600()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id, Service_Provider_Name__c FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Levy__c,Levy_Calculation_Method__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        listAssessments.add(assessmentRecord); 
        assessmentRecord.Status__c = 'Open';
        assessmentRecord.Manual_Assessment_Required__c = 'No';
        assessmentRecord.Manual_Assessment_Comments__c = '';
        assessmentRecord.Estimated_BSP_Transactions__c = '151 to 400';
        assessmentRecord.Estimated_TSP_Transactions__c = '151 to 400';
        assessmentRecord.BSP_Transaction_Count__c = 30;
        assessmentRecord.TSP_Transaction_Count__c = 25;
        
        assessmentRecord.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesOver600;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
        System.assertEquals(assessmentRecord.Total_Levy_Amount__c,55);
        System.assertEquals(assessmentRecord.BSP_Levy_Amount__c, 30);
        System.assertEquals(assessmentRecord.TSP_Levy_Amount__c, 25);
        
        assessmentRecord.BSP_Transaction_Count__c = Null;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
        
        assessmentRecord.BSP_Transaction_Count__c = 30;
        assessmentRecord.TSP_Transaction_Count__c = Null;
        AssessmentLevyAmountCalculator.calculate(listAssessments,true);
        
 }
    
    @isTest
    public static void annualEstimateOver600ForPreAssmntsTest() {
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id, Service_Provider_Name__c FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
       
        List<Assessment__c> listOfPreviousAssessments = New List<Assessment__c>();
            
        Assessment__c assessmentRecordOne = new Assessment__c();
        assessmentRecordOne.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecordOne.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecordOne.Status__c = 'Open';
        assessmentRecordOne.Assessment_Type__c = 'Assessment';
        assessmentRecordOne.BSP_Transaction_Count__c = 200;
        assessmentRecordOne.TSP_Transaction_Count__c = 300;
        assessmentRecordOne.Rebate_Approved__c = false;
        assessmentRecordOne.Period_Start_Date__c = System.today().addMonths(-5).toStartOfMonth();
        assessmentRecordOne.Period_End_Date__c = System.today().addMonths(-4).toStartOfMonth().addDays(-1);
        assessmentRecordOne.Payment_Due_Date__c = System.today().addMonths(-3).toStartOfMonth().addDays(25);
        assessmentRecordOne.Issue_Date__c = System.today().addMonths(-3).toStartOfMonth().addDays(11);
        assessmentRecordOne.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF;
        listOfPreviousAssessments.add(assessmentRecordOne);
        
        Assessment__c assessmentRecordSecond = new Assessment__c();
        assessmentRecordSecond.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecordSecond.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecordSecond.Status__c = 'Open';
        assessmentRecordSecond.Assessment_Type__c = 'Assessment';
        assessmentRecordSecond.BSP_Transaction_Count__c = 200;
        assessmentRecordSecond.TSP_Transaction_Count__c = 300;
        assessmentRecordSecond.Rebate_Approved__c = false;
        assessmentRecordSecond.Period_Start_Date__c = System.today().addMonths(-4).toStartOfMonth();
        assessmentRecordSecond.Period_End_Date__c = System.today().addMonths(-3).toStartOfMonth().addDays(-1);
        assessmentRecordSecond.Payment_Due_Date__c = System.today().addMonths(-2).toStartOfMonth().addDays(25);
        assessmentRecordSecond.Issue_Date__c = System.today().addMonths(-2).toStartOfMonth().addDays(11);
        assessmentRecordSecond.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF;
        listOfPreviousAssessments.add(assessmentRecordSecond);
        
        Assessment__c assessmentRecordThird = new Assessment__c();
        assessmentRecordThird.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecordThird.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecordThird.Status__c = 'Open';
        assessmentRecordThird.Assessment_Type__c = 'Assessment';
        assessmentRecordThird.BSP_Transaction_Count__c = 200;
        assessmentRecordThird.TSP_Transaction_Count__c = 300;
        assessmentRecordThird.Rebate_Approved__c = false;
        assessmentRecordThird.Period_Start_Date__c = System.today().addMonths(-3).toStartOfMonth();
        assessmentRecordThird.Period_End_Date__c = System.today().addMonths(-2).toStartOfMonth().addDays(-1);
        assessmentRecordThird.Payment_Due_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(25);
        assessmentRecordThird.Issue_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(11);
        assessmentRecordThird.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF;
        listOfPreviousAssessments.add(assessmentRecordThird);
        
        Insert listOfPreviousAssessments;
        
        Assessment__c assessmentRecordToUpdate = [SELECT Id, Levy__c, Levy_Calculation_Method__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c,Taxpayer_Registration__c  
                                          FROM Assessment__c 
                                          WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id 
                                          AND Levy_Calculation_Method__c !=: GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF LIMIT 1];
        
        List<Assessment__c> listAssessmentsToUpdate = new List<Assessment__c>();
        assessmentRecordToUpdate.BSP_Transaction_Count__c = Null;
        assessmentRecordToUpdate.TSP_Transaction_Count__c = Null;
        assessmentRecordToUpdate.Period_Start_Date__c = System.today().addMonths(-2).toStartOfMonth();
        assessmentRecordToUpdate.Period_End_Date__c = System.today().addMonths(-1).toStartOfMonth().addDays(-1);
        assessmentRecordToUpdate.Payment_Due_Date__c = System.today().addMonths(1).toStartOfMonth().addDays(-6);
        assessmentRecordToUpdate.Issue_Date__c = System.today().addMonths(1).toStartOfMonth().addDays(-17);
        assessmentRecordToUpdate.Levy__c = Null;
        assessmentRecordToUpdate.Annual_Estimates__c = AssessmentLevyAmountCalculator.annualEstimatesOver600;
        assessmentRecordToUpdate.Estimated_BSP_Transactions__c = '151 to 400';
        assessmentRecordToUpdate.Estimated_TSP_Transactions__c = '151 to 400';
        assessmentRecordToUpdate.Manual_Assessment_Required__c = 'No';
        assessmentRecordToUpdate.Manual_Assessment_Comments__c = '';
        assessmentRecordToUpdate.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF;
        listAssessmentsToUpdate.add(assessmentRecordToUpdate);
        
        AssessmentLevyAmountCalculator.calculate(listAssessmentsToUpdate,true);

    }
    
    @isTest
    public static void updateAssessmentAsHeldTest() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Tax_Payer_Registration__c taxpayerRegistrationRecord = [SELECT Id, Service_Provider_Name__c FROM Tax_Payer_Registration__c WHERE Service_Provider_Name__c = :accountId];
        Assessment__c assessmentRecord = [SELECT Id, Manual_Assessment_Comments__c, Levy__c, Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Total_Levy_Amount__c, BSP_Levy_Amount__c, TSP_Levy_Amount__c FROM Assessment__c WHERE Taxpayer_Registration__c = :taxpayerRegistrationRecord.Id];
        assessmentRecord.Manual_Assessment_Comments__c = '';
        update assessmentRecord;
        AssessmentLevyAmountCalculator.updateAssessmentAsHeld(assessmentRecord);
        System.assertEquals( assessmentRecord.Levy_Calculation_Method__c,GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY);
    }

}