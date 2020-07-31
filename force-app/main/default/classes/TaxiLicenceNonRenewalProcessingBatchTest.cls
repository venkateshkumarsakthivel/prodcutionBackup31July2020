@IsTest
private with sharing class TaxiLicenceNonRenewalProcessingBatchTest {
    @TestSetup
    private static void setup(){
       
		Id authTaxiLicRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(
                    GlobalConstants.TAXI_LICENCE_AUTHORISATION).getRecordTypeId();
		Id taxiLicAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                    GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Id taxiAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                    GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
		Set<String> ignoreFieldNames = new Set<String> ();
		//ignoreFieldNames.add('Name');

		Map<String, Object> accountValues = new Map<String, Object> ();
        accountValues.put('Name', 'Test Account');
        accountValues.put('Email__c', 'test@example.com');
        accountValues.put('Notice_Email__c', 'test@example.com');
        accountValues.put('ACN__c', '000000019');
        accountValues.put('ABN__c', '89000000019');
        accountValues.put('Notice_Address_State__c', 'NSW');
        accountValues.put('Notice_Address_City__c', 'Sydney');
        accountValues.put('Notice_Address_Street__c', '477 George Street');

        Account acc = (Account) TestDataFactory.createSObject('Account', accountValues, ignoreFieldNames);
		insert acc;

        Authorisation__c auth;
        ignoreFieldNames = new Set<String> ();
		ignoreFieldNames.add('Name');

        Taxi_Class__mdt config = [SELECT Licence_Class__c, Licence_Type__c,Renew_Months__c
                                    FROM Taxi_Class__mdt
                                    WHERE Is_Renewable__c = 'Yes'
                                    AND Max_Years__c > 0 AND Is_WAT__c = 'No' LIMIT 1];
        Map<String, Object> authtValues = new Map<String, Object> ();
        authtValues.put('Service_Provider__c', acc.Id);
        authtValues.put('End_Date__c', System.today().addDays(1));
        authtValues.put('Start_Date__c', System.today().addYears(-1));
        authtValues.put('Bank_Account_Name__c', 'Test');
        authtValues.put('BSB_Number__c', '132-132');
        authtValues.put('Status__c',  GlobalConstants.TAXI_LICENCE_GRANTED_STATUS);
        authtValues.put('Licence_Type__c', config.Licence_Type__c);
        authtValues.put('Authorisation_Type__c', GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE);
        authtValues.put('Licence_Class__c', config.Licence_Class__c);
        authtValues.put('RecordTypeId', authTaxiLicRecordTypeId);

        auth = (Authorisation__c) TestDataFactory.createSObject('Authorisation__c', authtValues, ignoreFieldNames);
        insert auth;

        auth.Start_Date__c =    System.today().addYears(-1)     ;
        auth.End_Date__c = System.today().addDays(-1);
        update auth;

        //create Draft Renewal authorisation
        Authorisation__c renAuth = auth.clone(false, true, false, false);
        renAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;  
        renAuth.Support_Process_Approval_Status__c = '';
        renAuth.Auto_Generate_Number__c = false;
        renAuth.Decision_Date__c = NULL;
        renAuth.Decision_Made_By__c = NULL;
        renAuth.Decision_Reason__c = '';
        renAuth.Start_Date__c = auth.End_Date__c.addDays(1);
        renAuth.End_Date__c = renAuth.Start_Date__c.addMonths(
                                            Integer.valueOf(config.Renew_Months__c)).addDays(-1);
        renAuth.Is_Renewal_Licence__c = TRUE;
        renAuth.Related_Authorisation__c = auth.Id;
        renAuth.Variation_Auth_Id__c = auth.Id;
        renAuth.SNSW_Plate_Pickup_Location__c = null;

        insert renAuth;

        //Create expiry case for old authorisation
        List<Case> cases = new List<Case>();
        ignoreFieldNames = new Set<String> ();
		ignoreFieldNames.add('Name');
		ignoreFieldNames.add('BusinessHoursId');
        
        Map<String, Object> caseValues = new Map<String, Object> ();
        caseValues.put('RecordTypeId', taxiLicAdminRecordType);
        caseValues.put('Status', GlobalConstants.CASE_STATUS_NEW);
        caseValues.put('Type', GlobalConstants.CASE_TYPE_TAXI);
        caseValues.put('Description', 'Test Expiry case');
        caseValues.put('AccountId', acc.Id);
        caseValues.put('Authorisation__c', auth.Id);
        caseValues.put('Sub_Type__c', GlobalConstants.EXPIRY_CASE_SUB_TYPE);
        cases.add((Case) TestDataFactory.createSObject('Case', caseValues, ignoreFieldNames));

        //create Renewal Case
        caseValues = new Map<String, Object> ();
        caseValues.put('RecordTypeId', taxiAdminRecordType);
        caseValues.put('Status', GlobalConstants.CASE_STATUS_NEW);
        caseValues.put('Type', GlobalConstants.CASE_TYPE_TAXI);
        caseValues.put('Description', 'Test Renewal Case');
        caseValues.put('AccountId', acc.Id);
        caseValues.put('Authorisation__c', renAuth.Id);
        caseValues.put('Sub_Type__c', GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION);
        cases.add((Case) TestDataFactory.createSObject('Case', caseValues, ignoreFieldNames));
        
        insert cases;
    }
   
    @isTest
    private static void testNonRenewalTaxiLicence(){
        System.Test.startTest();
        Database.executeBatch(new TaxiLicenceNonRenewalProcessingBatch());
        System.Test.stopTest();
        
        List<Authorisation__c> licences = [SELECT Status__c FROM Authorisation__c WHERE Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE];
        Authorisation__c lapsedLicence;
        Authorisation__c discardedLicence;
        for(Authorisation__c auth : licences){
            if(auth.Status__c == GlobalConstants.AUTH_STATUS_LAPSED){
                lapsedLicence = auth;
            }else if(auth.Status__c == GlobalConstants.AUTHORISATION_STATUS_DISCARDED){
                discardedLicence = auth;
            }
        }
        
        System.assertEquals(true, lapsedLicence != null);
        System.assertEquals(true, discardedLicence != null);
        
        System.assertEquals(GlobalConstants.CASE_SUB_STATUS_WAITING_FOR_PLATES, [SELECT Sub_Status__c FROM Case WHERE Sub_Type__c = :GlobalConstants.EXPIRY_CASE_SUB_TYPE LIMIT 1].Sub_Status__c);
        System.assertEquals(GlobalConstants.CLOSED_CASE_STATUS, [SELECT Status FROM Case WHERE Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION LIMIT 1].Status);
    }

    @isTest
    private static void testNonRenewalTaxiLicence_RenewalInitiated(){
        //test when renewal process has been initiated
        Case renwealCase = [SELECT Status FROM Case WHERE Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION LIMIT 1];
        renwealCase.Status = GlobalConstants.LODGED_CASE_STATUS;
        update renwealCase;

        System.Test.startTest();
        Database.executeBatch(new TaxiLicenceNonRenewalProcessingBatch());
        System.Test.stopTest();
        //Expiry and Renewal cases will not be updated  
        System.assertEquals(GlobalConstants.CASE_STATUS_NEW, [SELECT Status FROM Case WHERE Sub_Type__c = :GlobalConstants.EXPIRY_CASE_SUB_TYPE LIMIT 1].Status);
        System.assertEquals(GlobalConstants.LODGED_CASE_STATUS, [SELECT Status FROM Case WHERE Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION LIMIT 1].Status);
    }
}