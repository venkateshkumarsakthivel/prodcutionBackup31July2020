@isTest
public class Surrender_CancelCaseClosePostProcessorTe {
    
    @testSetup
    private static void setupTestData()
    {
        Id ownerid = GlobalUtility.getOwnerId();
        
        /* Account ------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert ac;
        
        /* Contact ------ */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
    }
    
    @isTest
    private static void checkRenewalCaseIsInProgressTestforSurrendercase()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        
        Test.startTest();
            
            Authorisation__c originalAuth = new Authorisation__c(Service_Provider__c = accountId, Licence_Class__c = 'TX08', Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                 Contact__c = conId, Status__c = 'Granted', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            insert originalAuth;
            
            Authorisation__c draftAuth = new Authorisation__c(Service_Provider__c = accountId, Status__c = 'Draft', Related_Authorisation__c = originalAuth.Id);
            insert draftAuth;
            
            Case surrenderCase = new Case(Authorisation__c = originalAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_SURRENDER, Status= GlobalConstants.CASE_NEW, RecordTypeId = taxiLicenseAdministrationRecordTypeId);
            insert surrenderCase;
            
            Case renewalCase = new Case(Authorisation__c = draftAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = 'Renewal Application', Status= 'Draft', Sub_Status__c = 'Draft', RecordTypeId = TaxiLicenseAdministrationRecordTypeId);
            insert renewalCase;
            
            surrenderCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
            surrenderCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
            update surrenderCase;
            
            Case renewalCaseRec = [SELECT Status, Sub_Status__c, Authorisation__c FROM Case WHERE Id =: renewalCase.Id LIMIT 1];
            System.assertEquals(GlobalConstants.CANCELLED_CASE_STATUS, renewalCaseRec.Status);
            System.assertEquals(GlobalConstants.CASE_SUB_STATUS_CANCELLED, renewalCaseRec.Sub_Status__c);
            
            Authorisation__c draftAuthorisationRec = [SELECT ID, Name, Status__c FROM Authorisation__c 
                                                      WHERE Id =: renewalCaseRec.Authorisation__c];
            System.assertEquals(GlobalConstants.AUTHORISATION_STATUS_DISCARDED, draftAuthorisationRec.Status__c);
        Test.stopTest();
    }
    
    @isTest
    private static void checkRenewalCaseIsInProgressTestforCancelcase()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id taxiLicenseAdministrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();         
        
        Test.startTest();
            
            Authorisation__c originalAuth = new Authorisation__c(Service_Provider__c = accountId, Licence_Class__c = 'TX08', Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                                 Contact__c = conId, Status__c = 'Granted', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE );
            insert originalAuth;
            
            Authorisation__c draftAuth = new Authorisation__c(Service_Provider__c = accountId, Status__c = 'Draft', Related_Authorisation__c = originalAuth.Id);
            insert draftAuth;
            
            Case CancelCase = new Case(Authorisation__c = originalAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_CANCEL, Status= GlobalConstants.CASE_NEW, RecordTypeId = taxiLicenseAdministrationRecordTypeId, Suspension_Reason__c = 'Other');
            insert CancelCase;
            
            Case renewalCase = new Case(Authorisation__c = draftAuth.Id, Type = GlobalConstants.TAXI_CASE_TYPE, Sub_Type__c = 'Renewal Application', Status= 'Draft', Sub_Status__c = 'Draft', RecordTypeId = TaxiLicenseAdministrationRecordTypeId);
            insert renewalCase;
            
            CancelCase.Status = GlobalConstants.CLOSED_CASE_STATUS;
            CancelCase.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
            update CancelCase;
            
            Case renewalCaseRec = [SELECT Status, Sub_Status__c, Authorisation__c FROM Case WHERE Id =: renewalCase.Id LIMIT 1];
            System.assertEquals(GlobalConstants.CANCELLED_CASE_STATUS, renewalCaseRec.Status);
            System.assertEquals(GlobalConstants.CASE_SUB_STATUS_CANCELLED, renewalCaseRec.Sub_Status__c);
            
            Authorisation__c draftAuthorisationRec = [SELECT ID, Name, Status__c FROM Authorisation__c 
                                                      WHERE Id =: renewalCaseRec.Authorisation__c];
            System.assertEquals(GlobalConstants.AUTHORISATION_STATUS_DISCARDED, draftAuthorisationRec.Status__c);

        Test.stopTest();
    }
    
}