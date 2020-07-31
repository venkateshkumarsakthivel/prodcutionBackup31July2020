/* Test class for UpdateRelatedRegistrationsAuthHelper */
@isTest
public class UpdateRelatedRegistrationsAuthHelperTest {
    
    @testSetup 
    static void setup() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name', Phone='0211111111');
        con.Primary_Contact__c = TRUE;
        insert con;
        
    }
    
    @isTest
    private static void processRelatedRegistrationsIsUpdateTest() {
        
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Authorisation__c authBSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_BSP);
        authBSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        insert authBSP;
        
        Authorisation__c authTSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_TSP);
        authTSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        insert authTSP;
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        authBSP.End_Date__c = authBSP.End_Date__c.addMonths(1);
        authTSP.End_Date__c = authTSP.End_Date__c.addMonths(1);
        
        update authBSP;
        update authTSP;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(TRUE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
    }
    
    @isTest
    private static void processRelatedRegistrationsAndCloneIsUpdateTest(){
        
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Authorisation__c authBSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_BSP);
        authBSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        insert authBSP;
        
        Authorisation__c authTSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_TSP);
        authTSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        insert authTSP;
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        authBSP.End_Date__c = authBSP.End_Date__c.addMonths(1);
        authTSP.End_Date__c = authTSP.End_Date__c.addMonths(1);
        
        update authBSP;
        update authTSP;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(TRUE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Levy_Notification_Address_Street__c FROM Tax_Payer_Registration__c 
                                                                   WHERE Service_Provider_Name__c = :tempAcc.Id
                                                                   AND Status__c = :GlobalConstants.STATUS_SUPERSEDED];
        
        System.assert(!supersededRegistrations.isEmpty());
    }  
    
    @isTest
    private static void processRelatedRegistrationsIsCreateTest() {
        
         
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Test.startTest();
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        Authorisation__c authBSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_BSP);
        authBSP.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        insert authBSP;
        
        Authorisation__c authTSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_TSP);
        authTSP.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        insert authTSP;
        
        authBSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        update authBSP;
        
       // authTSP.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        //update authTSP;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        //System.assertEquals(TRUE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(TRUE, taxPayerData.IsBSPAuthorisationCreate__c);
          Test.stopTest();
    }
    
    @isTest
    private static void processRelatedRegistrationsAndCloneIsCreateTest(){
        
      
        
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(FALSE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        List<Authorisation__c> authsList = new List<Authorisation__c>();
        
        Authorisation__c authBSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_BSP);
        authBSP.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        authsList.add(authBSP);
        
        Authorisation__c authTSP = createAuthorisation(tempAcc.Id, GlobalConstants.AUTHORISATION_TYPE_TSP);
        authTSP.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        authsList.add(authTSP);
        
        insert authsList;
        
        authsList[0].Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        
        authsList[1].Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        
        update authsList;
        
        Test.startTest();
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsTSPAuthorisationCreate__c, IsBSPAuthorisationCreate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(TRUE, taxPayerData.IsTSPAuthorisationCreate__c);
        System.assertEquals(TRUE, taxPayerData.IsBSPAuthorisationCreate__c);
        
        List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Levy_Notification_Address_Street__c FROM Tax_Payer_Registration__c 
                                                                   WHERE Service_Provider_Name__c = :tempAcc.Id
                                                                   AND Status__c = :GlobalConstants.STATUS_SUPERSEDED];
        
        System.assert(!supersededRegistrations.isEmpty());  
        
        Test.stopTest();
    }
    
    private static Authorisation__c createAuthorisation(String accId, String type){
       
        Authorisation__c auth = new Authorisation__c();
        auth.Service_Provider__c = accId;
        auth.Authorisation_Type__c = type;
        auth.Start_Date__c = System.today().addMonths(-6);
        auth.End_Date__c = System.today().addMonths(6);
        auth.Authorisation_Name__c = 'testAcc';
        
        return auth;
    }  
}