@IsTest
public with sharing class ApprovedWATApplicationProcessorTest {

    @testSetup 
    static void setup(){
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation,OwnerId=ownerid);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
    }
    
    
    private static testMethod void closeWatApplicationTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();

        Case oldCase = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI, ContactId = conId, 
                            Status = GlobalConstants.APPLICATION_STATUS_LODGED,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_REVIEW_PENDING ,
                            Type = GlobalConstants.SERVICE_TYPE_TAXI  ,Sub_Type__c = GlobalConstants.WAT_APPLICATION_SUB_TYPE ,
                            Notice_Address_City__c  = 'Test City', Notice_Address_Country__c  = 'Test Country', 
                            Notice_Address_Postal_Code__c = '8758', Notice_Address_State__c  = 'Test State',
                            Notice_Address_Street__c = 'Test Street', Notice_Email__c  = 'testemail@example.com',
                            Preferred_method_of_comm_for_notice__c = 'Email',
                            RecordTypeId = rtIdforIndividual);
        insert oldCase;
        
        Case newCase = [SELECT Id, AccountId, Service_Type__c, ContactId, Status, Sub_Status__c, Type, Sub_Type__c, Notice_Address_City__c,
                            Notice_Address_Country__c, Notice_Address_Postal_Code__c, Notice_Address_State__c, Notice_Address_Street__c,
                            Notice_Email__c, Preferred_method_of_comm_for_notice__c,RecordTypeId
                        FROM Case
                        WHERE Id = :oldCase.Id];
        newCase.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED;
        
        Test.startTest();
            ApprovedWATApplicationProcessor processor = new ApprovedWATApplicationProcessor(new Map<Id, Case>{oldCase.Id => oldCase}, new Map<Id, Case>{newCase.Id => newCase});
            processor.process();
        Test.stopTest();
        Account act = [SELECT Id, Notice_Address_City__c, Notice_Address_Country__c, Notice_Address_Postal_Code__c, 
                        Notice_Address_State__c, Notice_Address_Street__c, Notice_Email__c, 
                        Document_Delivery_Preference__c 
                        FROM Account WHERE Id = :accountId];
        System.assert(act.Notice_Address_City__c == oldCase.Notice_Address_City__c, 'Test failed for notice city');
        System.assert(act.Notice_Address_Country__c == oldCase.Notice_Address_Country__c, 'Test failed for notice country');
        System.assert(act.Notice_Address_Postal_Code__c == oldCase.Notice_Address_Postal_Code__c, 'Test failed for notice postcode');
        System.assert(act.Notice_Address_State__c == oldCase.Notice_Address_State__c, 'Test failed for notice state');
        System.assert(act.Notice_Address_Street__c == oldCase.Notice_Address_Street__c, 'Test failed for notice street');
        System.assert(act.Notice_Email__c == oldCase.Notice_Email__c, 'Test failed for notice email');
    }   
    
    private static testMethod void negativeTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();

        Case oldCase = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI, ContactId = conId, 
                            Status = GlobalConstants.APPLICATION_STATUS_LODGED,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_REVIEW_PENDING ,
                            Type = GlobalConstants.SERVICE_TYPE_TAXI  ,Sub_Type__c = GlobalConstants.WAT_APPLICATION_SUB_TYPE ,
                            Notice_Address_City__c  = 'Test City', Notice_Address_Country__c  = 'Test Country', 
                            Notice_Address_Postal_Code__c = '7676', Notice_Address_State__c  = 'Test State',
                            Notice_Address_Street__c = 'Test Street', Notice_Email__c  = 'testemail@example.com',
                            Preferred_method_of_comm_for_notice__c = 'Email',
                            RecordTypeId = rtIdforIndividual);
        insert oldCase;
        
        Case newCase = [SELECT Id, AccountId, Service_Type__c, ContactId, Status, Sub_Status__c, Type, Sub_Type__c, Notice_Address_City__c,
                            Notice_Address_Country__c, Notice_Address_Postal_Code__c, Notice_Address_State__c, Notice_Address_Street__c,
                            Notice_Email__c, Preferred_method_of_comm_for_notice__c,RecordTypeId
                        FROM Case
                        WHERE Id = :oldCase.Id];
        Test.startTest();
            ApprovedWATApplicationProcessor processor = new ApprovedWATApplicationProcessor(new Map<Id, Case>{oldCase.Id => oldCase}, new Map<Id, Case>{newCase.Id => newCase});
            processor.process();
        Test.stopTest();
        Account act = [SELECT Id, Notice_Address_City__c, Notice_Address_Country__c, Notice_Address_Postal_Code__c, 
                        Notice_Address_State__c, Notice_Address_Street__c, Notice_Email__c, 
                        Document_Delivery_Preference__c 
                        FROM Account WHERE Id = :accountId];
        System.assert(act.Notice_Address_City__c != oldCase.Notice_Address_City__c, 'Test failed for notice city');
        System.assert(act.Notice_Address_Country__c != oldCase.Notice_Address_Country__c, 'Test failed for notice country');
        System.assert(act.Notice_Address_Postal_Code__c != oldCase.Notice_Address_Postal_Code__c, 'Test failed for notice postcode');
        System.assert(act.Notice_Address_State__c != oldCase.Notice_Address_State__c, 'Test failed for notice state');
        System.assert(act.Notice_Address_Street__c != oldCase.Notice_Address_Street__c, 'Test failed for notice street');
        System.assert(act.Notice_Email__c != oldCase.Notice_Email__c, 'Test failed for notice email');
    }
    
    private static testMethod void nullTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id;
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();

        Case oldCase = new Case(AccountId = accountId, Service_Type__c = GlobalConstants.SERVICE_TYPE_TAXI, ContactId = conId, 
                            Status = GlobalConstants.APPLICATION_STATUS_LODGED,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_REVIEW_PENDING ,
                            Type = GlobalConstants.SERVICE_TYPE_TAXI  ,Sub_Type__c = GlobalConstants.WAT_APPLICATION_SUB_TYPE ,
                            Notice_Address_City__c  = 'Test City', Notice_Address_Country__c  = 'Test Country', 
                            Notice_Address_Postal_Code__c = '8786', Notice_Address_State__c  = 'Test State',
                            Notice_Address_Street__c = 'Test Street', Notice_Email__c  = 'testemail@example.com',
                            Preferred_method_of_comm_for_notice__c = 'Email',
                            RecordTypeId = rtIdforIndividual);
        insert oldCase;
        
        Case newCase = [SELECT Id, AccountId, Service_Type__c, ContactId, Status, Sub_Status__c, Type, Sub_Type__c, Notice_Address_City__c,
                            Notice_Address_Country__c, Notice_Address_Postal_Code__c, Notice_Address_State__c, Notice_Address_Street__c,
                            Notice_Email__c, Preferred_method_of_comm_for_notice__c,RecordTypeId
                        FROM Case
                        WHERE Id = :oldCase.Id];
        Test.startTest();
            ApprovedWATApplicationProcessor processor = new ApprovedWATApplicationProcessor(null, null);
            processor.process();
        Test.stopTest();
        Account act = [SELECT Id, Notice_Address_City__c, Notice_Address_Country__c, Notice_Address_Postal_Code__c, 
                        Notice_Address_State__c, Notice_Address_Street__c, Notice_Email__c, 
                        Document_Delivery_Preference__c 
                        FROM Account WHERE Id = :accountId];
        System.assert(act.Notice_Address_City__c != oldCase.Notice_Address_City__c, 'Test failed for notice city');
        System.assert(act.Notice_Address_Country__c != oldCase.Notice_Address_Country__c, 'Test failed for notice country');
        System.assert(act.Notice_Address_Postal_Code__c != oldCase.Notice_Address_Postal_Code__c, 'Test failed for notice postcode');
        System.assert(act.Notice_Address_State__c != oldCase.Notice_Address_State__c, 'Test failed for notice state');
        System.assert(act.Notice_Address_Street__c != oldCase.Notice_Address_Street__c, 'Test failed for notice street');
        System.assert(act.Notice_Email__c != oldCase.Notice_Email__c, 'Test failed for notice email');
    }
}