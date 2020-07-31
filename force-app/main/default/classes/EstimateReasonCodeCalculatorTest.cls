@IsTest
public with sharing class EstimateReasonCodeCalculatorTest {

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
    
    private static testMethod void testForNullReturnCode(){
        Map<Id, Assessment__c> oldAssessment = new Map<Id, Assessment__c> ( [select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c ]);
        Map<Id, Assessment__c>  newAssessment = new Map<Id, Assessment__c> ([select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c ]);
        
        for(Id assessmentId : newAssessment.keyset()){
            newAssessment.get(assessmentId).Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
            newAssessment.get(assessmentId).Levy_Calculation_Method__c  = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_BY_SF;
        }
        
        System.Test.startTest();
        EstimateReasonCodeCalculator calculator = new EstimateReasonCodeCalculator(oldAssessment, newAssessment);
        calculator.calculate();
        System.Test.stopTest();
        
        for(Id assessmentId : newAssessment.keyset()){
            System.assert(newAssessment.get(assessmentId).Estimate_Reason_Code__c  == null);
        }
    }
    
    private static testMethod void testForReturnNotReceived(){
        Map<Id, Assessment__c> oldAssessment = new Map<Id, Assessment__c> ( [select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c LIMIT 1]);
        Map<Id, Assessment__c>  newAssessment = new Map<Id, Assessment__c> ([select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c LIMIT 1]);
        
        for(Id assessmentId : newAssessment.keyset()){
            newAssessment.get(assessmentId).Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
            newAssessment.get(assessmentId).Levy_Calculation_Method__c  = GlobalConstants.LEVY_CALCULATION_METHOD_ESTIMATED_BY_SF;
        }
        
        System.Test.startTest();
        EstimateReasonCodeCalculator calculator = new EstimateReasonCodeCalculator(oldAssessment, newAssessment);
        calculator.calculate();
        System.Test.stopTest();
        
        for(Id assessmentId : newAssessment.keyset()){
            System.assert(newAssessment.get(assessmentId).Estimate_Reason_Code__c  == GlobalConstants.INADEQUATE_ASSESSMENT_RECORDS);
        }
    }
    
    private static testMethod void testForNonQualifiedAssessment(){
        Map<Id, Assessment__c> oldAssessment = new Map<Id, Assessment__c> ( [select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c LIMIT 1]);
        Map<Id, Assessment__c>  newAssessment = new Map<Id, Assessment__c> ([select id, status__c, levy_calculation_method__c, estimate_reason_code__c From Assessment__c LIMIT 1]);
            
        System.Test.startTest();
        EstimateReasonCodeCalculator calculator = new EstimateReasonCodeCalculator(oldAssessment, newAssessment);
        calculator.calculate();
        System.Test.stopTest();
        
        for(Id assessmentId : newAssessment.keyset()){
            System.assert(newAssessment.get(assessmentId).Estimate_Reason_Code__c  == null);
        }
    }
    
}