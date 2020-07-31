/* Test class for UpdateRelatedAccountHelper */
@isTest
public class UpdateRelatedAccountHelperTest {
    
    @testSetup 
    static void setup() {
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
    }
    
    @isTest
    private static void processRelatedAuthourisationsTest(){
        
        Account tempAcc = [SELECT Id,ASP_Category__c FROM Account WHERE Name = 'testAcc' LIMIT 1]; 
        
        Authorisation__c bspAuthourisation = new Authorisation__c(Service_Provider__c = tempAcc.Id, Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_BSP);
        insert bspAuthourisation;
        
        update tempAcc;
        
        tempAcc = [SELECT Id,ASP_Category__c FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        System.assertEquals(NULL, tempAcc.ASP_Category__c);
        
        bspAuthourisation.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
        
        update bspAuthourisation;
        
        tempAcc = [SELECT Id,ASP_Category__c FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        System.assertEquals(2, tempAcc.ASP_Category__c);
        
        Authorisation__c tspAuthourisation = new Authorisation__c(Service_Provider__c = tempAcc.Id, Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert tspAuthourisation;
        
       // tspAuthourisation.Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY;
       // update tspAuthourisation;
        
        //tempAcc = [SELECT Id,ASP_Category__c FROM Account WHERE Name = 'testAcc' LIMIT 1];
        //System.assertEquals(1, tempAcc.ASP_Category__c);
        
        bspAuthourisation = [SELECT Service_Provider__r.ASP_Category__c, Authorisation_Type__c
                          FROM Authorisation__c 
                          WHERE Service_Provider__c = :tempAcc.Id And Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_BSP];
        
        bspAuthourisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_NEW;
        
        update bspAuthourisation;
        
        tspAuthourisation = [SELECT Service_Provider__r.ASP_Category__c, Authorisation_Type__c
                        FROM Authorisation__c 
                        WHERE Service_Provider__c = :tempAcc.Id And Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TSP];
        
        tspAuthourisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_NEW;
        
       update tspAuthourisation;
        
        tempAcc = [SELECT Id,ASP_Category__c FROM Account WHERE Name = 'testAcc' LIMIT 1];
        
        System.assertEquals(null, tempAcc.ASP_Category__c);
    }
}