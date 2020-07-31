@isTest
public class AuthorisationFeeCalculationBatchTest {
    
        @testSetup
    private static void setupTestData() {
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Authorisation Fees - Annual');
        insert prod;
        // Create a std price book
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 1, IsActive = true);
        insert standardPrice;
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='P2P Default', isActive=true);
        insert customPB;
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id,UnitPrice = 1, IsActive = true);
        insert customPrice;
        
        // set auth start and end date of auth
        Integer currentYear = System.now().Year();
        Integer pastYear = currentYear - 2;
        Integer futureYear = currentYear + 2;
        String authStartDate = '10/12/'+pastYear;
        String authEndDate = '10/12/'+futureYear;
        
        Auth_Fee_Collection_Period_Configuration__mdt  FeeCollectionPeriod = [SELECT Start_Date__c, End_Date__c 
                                                                              FROM Auth_Fee_Collection_Period_Configuration__mdt
                                                                              WHERE Year__c = :String.valueOf(currentYear) LIMIT 1];
        
        Date assessmentStart = FeeCollectionPeriod.Start_Date__c;
        assessmentStart.addDays(20);
        Date assessmentEnd = FeeCollectionPeriod.Start_Date__c;
        assessmentEnd.addDays(60);
        
        
        //Create on account without any assessments
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
        Account ac1 = new Account(ACN__c = '1234567899',ABN__c = '123456777', Name = 'testAcc1',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac1;
        
        /* Contact Related to company account */
        Contact con1 = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac1.Id,Birthdate = Date.parse('01/01/1992'), Email='test1@contest.com',FirstName = 'Name1',Phone='0211111111',Primary_Contact__c = true);
        insert con1;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth1 = new Authorisation__c(Service_Provider__c = ac1.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con1.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth1;
        
        tspauth1.Start_Date__c = Date.parse(authStartDate);
        tspauth1.End_Date__c = Date.parse(authEndDate);
        update tspauth1;  
        
        
        //create account with assessment
          
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        /* Contact Related to company account */
        Contact con = new Contact(Title='Mr.',LastName ='testCon',Primary_Contact__c = true, AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        /* Authorisation__c Related to company account */
        Authorisation__c tspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'TSP');
        insert tspauth;
        
        tspauth.Start_Date__c = Date.parse(authStartDate);
        tspauth.End_Date__c = Date.parse(authEndDate);
        update tspauth;  
        
        /* Authorisation__c Related to Individual account */
        Authorisation__c bspauth = new Authorisation__c(Service_Provider__c = ac.Id,Licence_Class__c = 'TX-08',Licence_Type__c='Annual',Licence_Fee__c = 100, 
                                                        Contact__c = con.Id,Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = 'BSP');
        insert bspauth;
        
        bspauth.Start_Date__c = Date.parse(authStartDate);
        tspauth.End_Date__c = Date.parse(authEndDate);
        update bspauth;  
        
                /* Lookup to TSP and BSP both */
        Tax_Payer_Registration__c taxpayerRegistrationRecord = new Tax_Payer_Registration__c(Service_Provider_Name__c = ac.Id,Levy_Contact__c = con.Id,ABN__c='123456789',Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED,
                                                                                             Status__c = GlobalConstants.STATUS_ACTIVE,Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS,
                                                                                             Taxi_Service_Provider_Number__c = tspauth.Id, Booking_Service_Provider_Number__c = bspAuth.Id,
                                                                                             BSB__c = '012-003', Bank_Account_Number__c = '122222222', Bank_Account_Holder_s_Name__c = 'Sample',
                                                                                             Levy_Notification_Address_City__c='Sydney', Levy_Notification_Address_Country__c ='Australia',
                                                                                             Levy_Notification_Address_Postal_Code__c ='1234', Levy_Notification_Address_State__c ='NSW',
                                                                                             Levy_Notification_Address_Street__c = 'castle');
        insert taxpayerRegistrationRecord;

        Assessment__c assessmentRecord = new Assessment__c();
        assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
        assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
        assessmentRecord.Status__c = 'Assessed';
        assessmentRecord.Assessment_Type__c = 'Assessment';
        assessmentRecord.Period_Start_Date__c = assessmentStart;
        assessmentRecord.Period_End_Date__c = assessmentEnd;
        assessmentRecord.Annual_Estimates__c = '151 to 400';
        assessmentRecord.TSP_Transaction_Count__c = 100000;
        assessmentRecord.BSP_Transaction_Count__c = 200000;
        assessmentRecord.Total_Levy_Amount__c = 0;
        assessmentRecord.TSP_Levy_Amount__c = 0;
        assessmentRecord.BSP_Levy_Amount__c = 0;
        insert assessmentRecord;
        
        
        Integer pastYearForOrder = currentYear - 1;
        String EffectiveDate = '10/09/'+pastYearForOrder;
        
        Order ordObj = new Order();
        ordObj.accountId = ac.Id;
        ordObj.Status = 'Payment Due';
        ordObj.Description = 'orderDesciption';
        ordObj.Type = 'Authorisation fee'; // Portal type
        ordObj.BillToContactId = con.Id;
        ordObj.EffectiveDate = Date.parse(EffectiveDate); // due date
        ordObj.pricebook2ID = customPB.Id;
        insert ordObj;
        
        OrderItem ordItem = new OrderItem();
        ordItem.OrderId = ordObj.Id;
        ordItem.Annual_BSP_Count__c = 11;
        ordItem.Annual_TSP_Count__c = 11;
        ordItem.UnitPrice = 5000000;
        ordItem.Quantity= 1;
        ordItem.Description = 'Annual authorisation fee for ASP';
        ordItem.Transaction_Type__c = 'Authorisation Fee';
        ordItem.priceBookEntryID = customPrice.Id;
        insert ordItem;
        
    }
    
    @isTest
    private static void startTest() { 
        
         Test.startTest();
            AuthorisationFeeCalculationScheduler s = new AuthorisationFeeCalculationScheduler();
            s.execute(null);
        
            System.assert(true);
            
        Test.stopTest();
    }
    
    @isTest
    private static void OrderItemTriggerTest() { 
        
         Test.startTest();
            List<OrderItem> orderItems = [SELECT Id,Annual_TSP_Count__c FROM OrderItem];
        System.debug('itemsss'+orderItems);
            for(OrderItem item : orderItems) {
                System.debug('item'+item);
                item.Annual_TSP_Count__c = 50000;
            }
            update orderItems;
        Test.stopTest();
        
        OrderItem orderItemObj = [SELECT Id,UnitPrice FROM OrderItem LIMIT 1];
        System.assert(orderItemObj.UnitPrice != 5000000);
    }
    
    
     @isTest
    private static void authorisationPaymentInformationTest() { 
        
         Test.startTest();
            List<Order> orderList = [SELECT Id FROM Order];
            OrderItem item = AuthorisationPaymentInformation.getAuthorisationPaymentInformation(orderList[0].Id);
            AuthorisationPaymentInformation.getAuthorisationPaymentInformation('test');//this is for catch block
        Test.stopTest();
        
        System.assertEquals(11, item.Annual_BSP_Count__c);
    }
}