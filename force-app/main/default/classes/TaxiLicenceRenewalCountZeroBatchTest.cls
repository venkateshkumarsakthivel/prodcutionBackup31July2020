@IsTest
private with sharing class TaxiLicenceRenewalCountZeroBatchTest {
    private static final Decimal BASE_PRICE = 120000;
    private static final Decimal APPLICATION_FEE = 200;
    
    private static testMethod void testForLicenceNonRenewal(){
        System.Test.startTest();
        Database.executeBatch(new TaxiLicenceRenewalCountZeroBatch());
        System.Test.stopTest();
        List<Authorisation__c> licences = [SELECT Id FROM Authorisation__c WHERE Renewal_Requested__c = true];
        //System.assert(!licences.isEmpty());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Authorisation__c auth = createLicence(act.Id);
     
    }
    
    private static Account createAccount(){
        Account act = new Account();
        act.Name = 'Test Account';
        act.Email__c = 'test@example.com';
        act.Notice_Email__c = 'test@example.com';
        act.Notice_Address_City__c = 'Sydney';
        act.Notice_Address_Country__c = 'Australia';
        act.Notice_Address_Postal_Code__c = '2000';
        act.Notice_Address_State__c = 'NSW';
        act.Notice_Address_Street__c = '333 George Street';
        act.ACN__c = '000000019';
        act.ABN__c = '89000000019';
        
        insert act;
        return act;        
    }
    
    private static Authorisation__c createLicence(Id actId){
       // Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
        Date todayMinusSeven = System.Today() + 2;
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = actId;
        auth.Name = 'Test';
        auth.End_Date__c = todayMinusSeven;
        auth.Start_Date__c = System.today().addYears(-1);
        auth.Bank_Account_Name__c = 'Test';
        auth.Bank_Account_Number__c = '1313121321';
        auth.BSB_Number__c = '132-132';
        auth.Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
        auth.Licence_Class__c = 'TXA03';
        auth.Licence_Fee__c = BASE_PRICE;
        auth.Renewal_Count_Remaining__c= 0;
        auth.Renewal_Requested__c= false;
        auth.TaxiLicence10YearsExpiry__c= false;
        auth.Licence_Type__c = GlobalConstants.LICENCE_TYPE_ANNUAL;
        auth.Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
        
        insert auth;
        return auth;
    }
    
   
}