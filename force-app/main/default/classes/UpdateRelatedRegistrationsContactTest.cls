/* Test class for UpdateRelatedRegistrationsAccountHelper */
@isTest
public class UpdateRelatedRegistrationsContactTest {

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
    private static void processRelatedRegistrationsTest(){
        
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        update tempCon;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsProviderUpdate__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsProviderUpdate__c);
        
        tempCon.Phone = '0233333333';
        
        update tempCon;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsProviderUpdate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals('0233333333', taxPayerData.Levy_Contact_Phone__c);
        System.assertEquals(TRUE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(TRUE, taxPayerData.IsProviderUpdate__c);
    }
    
    @isTest
    private static void processRelatedRegistrationsAndCloneTest(){
        
        Account tempAcc = [SELECT Id FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        Contact tempCon = [SELECT Id FROM Contact WHERE LastName = 'testCon' LIMIT 1]; 
        
        Tax_Payer_Registration__c taxPayerData = new Tax_Payer_Registration__c(Service_Provider_Name__c = tempAcc.Id, ABN__c='123456789', Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED, Status__c = GlobalConstants.STATUS_ACTIVE);
        taxPayerData.Levy_Contact__c = tempCon.Id;
        taxPayerData.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_NA;
        taxPayerData.RNSWCustomerId__c = 'RNSW100';
        insert taxPayerData;
        
        update tempCon;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsProviderUpdate__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals(FALSE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(FALSE, taxPayerData.IsProviderUpdate__c);
        
        tempCon.Phone = '0233333333';
        
        update tempCon;
        
        taxPayerData = [SELECT IsAuthorisationUpdate__c, IsProviderUpdate__c, Levy_Contact_Phone__c 
                        FROM Tax_Payer_Registration__c 
                        WHERE Service_Provider_Name__c = :tempAcc.Id
                        AND Status__c = :GlobalConstants.STATUS_ACTIVE];
        
        System.assertEquals('0233333333', taxPayerData.Levy_Contact_Phone__c);
        System.assertEquals(TRUE, taxPayerData.IsAuthorisationUpdate__c);
        System.assertEquals(TRUE, taxPayerData.IsProviderUpdate__c);
        
        List<Tax_Payer_Registration__c> supersededRegistrations = [SELECT Levy_Notification_Address_Street__c FROM Tax_Payer_Registration__c 
                                                                   WHERE Service_Provider_Name__c = :tempAcc.Id
                                                                   AND Status__c = :GlobalConstants.STATUS_SUPERSEDED];
        
        System.assertEquals(1, supersededRegistrations.size());  
    }    
}