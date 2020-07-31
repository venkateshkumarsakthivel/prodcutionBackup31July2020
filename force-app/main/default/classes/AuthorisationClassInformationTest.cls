@isTest
public class AuthorisationClassInformationTest {
    
    @testSetup
    private static void setupTestData(){
    
        /*--- Using this record type for Case creation---*/
        
        Id ownerid = GlobalUtility.getOwnerId();
        
        /*--- Account created------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId= ownerid);
        insert ac;
        
        /*---Contact ---*/
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /*---Authorisation related to Account--*/
        Id taxiLicenceRecordTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Taxi Licence').getRecordTypeId();
        
        Authorisation__c taxiAuth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX01',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,
                                                         RecordTypeId = taxiLicenceRecordTypeId);
        insert taxiAuth;
        
        Authorisation__c taxiAuth1 = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX03',Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,
                                                         RecordTypeId = taxiLicenceRecordTypeId);
        insert taxiAuth1;
        
        Authorisation__c taxiAuth2 = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Type__c='Annual', Licence_Fee__c = 100, 
                                                         Contact__c = con.Id, Status__c = 'Suspended', Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE,
                                                         RecordTypeId = taxiLicenceRecordTypeId);
        insert taxiAuth2;
    }
    
    @isTest
    private static void populateExisitingAuthorisationClassInformationTest(){
        
        Taxi_Class__mdt getTX03LicenceClassmdt = [SELECT Licence_Class__c, Description__c, Is_Legacy_Only__c, Is_WAT__c, 
                                                        Is_Transferable__c, Is_Renewable__c, Renew_Months__c, 
                                                        Max_Years__c, Renew_Formula__c FROM Taxi_Class__mdt where Licence_Class__c = 'TX03' ];
        
        Taxi_Class__mdt getTX01LicenceClassmdt = [SELECT Licence_Class__c, Description__c, Is_Legacy_Only__c, Is_WAT__c, 
                                                        Is_Transferable__c, Is_Renewable__c, Renew_Months__c, 
                                                        Max_Years__c, Renew_Formula__c FROM Taxi_Class__mdt where Licence_Class__c = 'TX01' ];
        
        
        Authorisation__c testAuth = [SELECT Id,Licence_Class__c, Class_Description__c, Class_Max_Duration__c, Record_Type_Dev_Name__c from Authorisation__c where Licence_Class__c = 'TX03'];
        System.debug(testAuth);
        System.assertEquals(getTX03LicenceClassmdt.Licence_Class__c, testAuth.Licence_Class__c);
        System.assertEquals(getTX03LicenceClassmdt.Description__c, testAuth.Class_Description__c);
        System.assertEquals(getTX03LicenceClassmdt.Max_Years__c, testAuth.Class_Max_Duration__c);
        testAuth.Licence_Class__c = 'TX01';
        update testAuth;
        Authorisation__c updatedtestAuth = [SELECT Id,Licence_Class__c, Class_Description__c, Class_Max_Duration__c, Record_Type_Dev_Name__c from Authorisation__c where Id =:testAuth.Id];
        System.assertEquals(getTX01LicenceClassmdt.Licence_Class__c, updatedtestAuth.Licence_Class__c);
        System.assertEquals(getTX01LicenceClassmdt.Description__c, updatedtestAuth.Class_Description__c);
        System.assertEquals(getTX01LicenceClassmdt.Max_Years__c, updatedtestAuth.Class_Max_Duration__c);
        testAuth.Licence_Class__c = '';
        update testAuth;
        Authorisation__c updatedtestAuth2 = [SELECT Id,Licence_Class__c, Class_Description__c, Class_Max_Duration__c, Record_Type_Dev_Name__c from Authorisation__c where Id =:testAuth.Id];
        System.assertEquals(null, updatedtestAuth2.Licence_Class__c);
        System.assertEquals(null, updatedtestAuth2.Class_Description__c);
        System.assertEquals(null, updatedtestAuth2.Class_Max_Duration__c);
        
      }
}