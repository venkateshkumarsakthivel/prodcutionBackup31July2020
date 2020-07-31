@isTest
public class ASPAuthRenewalFormControllerTest {
    
    @testSetup
    private static void setupTestData()
    {
        
        
        Id ownerid = GlobalUtility.getOwnerId();
        /* Account created------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert ac;
        
        /* Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /*---Authorisation related to Account--*/
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  );
        
        insert taxiAuth;
        taxiAuth.Start_Date__c = Date.parse('10/12/2017');
        taxiAuth.End_Date__c = Date.parse('10/1/2018');
        update taxiAuth ;  
        
        Id recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        Case newCase = new Case(Family_name__c = 'Family Name 1',Birthdate__c= Date.parse('01/01/1985'),Contact_Type__c = 'Nominated Director/Manager',
                                AccountId = ac.Id, Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                                Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                                Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION,RecordTypeId =recordTypeID 
                                ,Service_Type__c =GlobalConstants.SERVICE_TYPE_TAXI , Is_TSP_Auth_Renewal_Request__c = true,
                                Is_BSP_Auth_Renewal_Request__c = false, Is_Privacy_Statement_Declared__c = true );        
        insert newCase;
        
        taxiAuth.Application__c =newCase.Id;
        update taxiAuth;
        
    }
    @isTest
    private static void  getRenewalCaseDetailsTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Case  caseRec ;
        Test.startTest();
        {
            
            
            caseRec = ASPAuthRenewalFormController.getRenewalCaseDetails(accountId);
            System.debug('case record is'+ caseRec);
            System.assertNotEquals(NULL,caseRec);
        }
        Test.stopTest();
        String invalidAccountId = '13124244';
        caseRec = ASPAuthRenewalFormController.getRenewalCaseDetails(invalidAccountId );
        System.assertEquals(NULL,caseRec);
    }
    
    @isTest
    private static void  getAuthorisationDetailsTest()
    {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id caseId =[select id from Case where AccountId = :accountId limit 1].Id ;
        
        List<Authorisation__c> authRec ;
        Test.startTest();
        {
            
            
            authRec  = ASPAuthRenewalFormController.getAuthorisationDetails(caseId);
            System.debug('auth record is'+ authRec);
            System.assertNotEquals(NULL,authRec);
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void  getASPAuthRenewalCaseDataTest()
    {  Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
     Id caseId =[select id from Case where AccountId = :accountId limit 1].Id ;
     
     Case caseRec;
     Test.startTest();
     {
         
         
         caseRec = ASPAuthRenewalFormController.getASPAuthRenewalCaseData(caseId);
         System.debug('case data is'+ caseRec);
         System.assertNotEquals(NULL,caseRec);
     }
     Test.stopTest();
     
     string invalidCaseId = '3735'; 
     caseRec = ASPAuthRenewalFormController.getASPAuthRenewalCaseData(invalidCaseId );
     System.debug('case data is'+ caseRec);
     System.assertEquals(NULL,caseRec);
     
     
    }
    
    @isTest
    private static void  updateASPAuthRenewalCaseTest()
    { 
        boolean checkUpdateStatusLodged = true ;
        boolean result ;
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Case CaseRec = [select Id,Date_Submitted__c,Status,Sub_Status__c from Case where  AccountId = :accountId ];
        string caseData = JSON.serialize(CaseRec);
        Test.startTest();
        {
            
            
            result = ASPAuthRenewalFormController.updateASPAuthRenewalCase(caseData,checkUpdateStatusLodged);
            System.debug('result is'+ result);
            //System.assertNotEquals(NULL,caseRec);
        }
        Test.stopTest();
        
        
        
        
    }
    
    
    
    
}