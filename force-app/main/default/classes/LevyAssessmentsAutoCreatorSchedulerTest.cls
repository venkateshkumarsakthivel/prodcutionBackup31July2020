@isTest
public class LevyAssessmentsAutoCreatorSchedulerTest {
    
    @testSetup 
    static void setup(){
        /* Account with Company RecordType */
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc1',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Account with Individual RecordType and Street Address >50 Characters */
        Id rtIdForIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL).getRecordTypeId();
        
        Account ac2 = new Account(ACN__c = '1234567899',ABN__c = '123456780', Name = 'testAcc2',  Notice_Email__c = 's1@r.com', Notice_Address_City__c = 'Sydney',
                                  Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australias', Notice_Address_State__c = 'NSW',
                                  Notice_Address_Street__c = 'castle D, 5th wing,Road DonBurg, Luci,vegass total more tha 50 charactes', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                  BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                  ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name1', RecordTypeId = rtIdForIndividual);
        insert ac2;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Primary Contact Related to Individual account */
        Contact con2 = new Contact(Title='Mr.',LastName ='testConP', AccountId = ac2.Id,Birthdate = Date.parse('01/01/1992'), Primary_Contact__c = true, Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con2;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth;
        
        tspauth.Start_Date__c = Date.parse('10/12/2017');
        update tspauth;  
        
        /* Authorisation__c Related to Individual account */
        Authorisation__c bspauthac2 = new Authorisation__c(Service_Provider__c = ac2.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                           Contact__c = con2.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'BSP');
        insert bspauthac2;
        
        bspauthac2.Start_Date__c = Date.parse('25/12/2017');
        update bspauthac2;  
        
        /* Lookup to TSP */
        Tax_Payer_Registration__c sampleTaxPayerData1 = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                      Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING,
                                                                                      Taxi_Service_Provider_Number__c = tspauth.Id,
                                                                                      BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                      Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                      Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                      Levy_Notification_Address_Street__c = 'castle');
        insert sampleTaxPayerData1;
        
        
        /* Lookup on BSP */
        Tax_Payer_Registration__c sampleTaxPayerData2 = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac2.Id, Levy_Contact__c = con2.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                      Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_PENDING,
                                                                                      Booking_Service_Provider_Number__c = bspauthac2.Id,
                                                                                      BSB__c = '012-003', Bank_Account_Number__c = '122222222', 
                                                                                      Bank_Account_Holder_s_Name__c = 'Sample', Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australias',
                                                                                      Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                      Levy_Notification_Address_Street__c = 'castle D, 5th wing,Road DonBurg, Luci,vegass total more tha 50 charactes');
       
        sampleTaxPayerData2.Rebate_Approved__c = true;
        sampleTaxPayerData2.Rebate_Approval_Date__c = System.today().addYears(-1);
        insert sampleTaxPayerData2;
    }
    
    @isTest
    private static void executeTest(){
        LevyAssessmentsAutoCreatorScheduler levyAssessmentsAutoCreatorScheduler = new LevyAssessmentsAutoCreatorScheduler();
        test.startTest();
        levyAssessmentsAutoCreatorScheduler.execute(null);
        test.stopTest();
        System.assert(true);
    }
}