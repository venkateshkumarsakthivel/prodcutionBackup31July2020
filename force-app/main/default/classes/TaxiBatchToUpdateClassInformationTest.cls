@isTest
public class TaxiBatchToUpdateClassInformationTest {
  
    @testSetup
    static void setup() {
    
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Id ownerid = GlobalUtility.getOwnerId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Id taxiLicenceRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Taxi Licence').getRecordTypeId();
           
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX08',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Granted', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,
                                                         RecordTypeId = taxiLicenceRecordTypeId);
        
        insert taxiAuth;
            
    }
    
    @isTest
    public static void testBatchExecution() {
      
      Authorisation__c taxiAuth = [SELECT Licence_Class__c, Class_allows_Renewals__c FROM Authorisation__c LIMIT 1];
      
      System.assertEquals('No', taxiAuth.Class_allows_Renewals__c);  
      
      Test.startTest();
      TaxiBatchToUpdateClassInformation b = new TaxiBatchToUpdateClassInformation(); 
      database.executebatch(b);
      Test.stopTest();
      
      taxiAuth = [SELECT Licence_Class__c, Class_allows_Renewals__c FROM Authorisation__c LIMIT 1];
      
      System.assertEquals('No', taxiAuth.Class_allows_Renewals__c);
    }
}