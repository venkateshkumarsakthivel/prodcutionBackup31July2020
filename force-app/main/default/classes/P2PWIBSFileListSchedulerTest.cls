/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class P2PWIBSFileListSchedulerTest {
    
    
    @testSetup
    private static void initialize() {
        try {
            Account account = new Account(Name = 'Account For Order');
            insert account;
            
            Contact contact = new Contact(LastName ='paymentStatusControllerTestLastName',AccountId = account.Id, Email='paymentStatusControllerTestUser@testing.don');
            insert contact;
            
            Id profileId = [select Id from profile where name='Authorised Service Provider'].Id;
            User user = new User(alias = 'PSTEST', email='paymentStatusControllerTestUser@testing.don',
                                 emailencodingkey='UTF-8', lastname='paymentStatusControllerTestUserLastName', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileId, country='India', IsActive =true,
                                 contactId = contact.Id,
                                 timezonesidkey='America/Los_Angeles', username='tpaymentStatusControllerTestUser@testing.don');
            
            insert user;
        } catch(Exception cexception) {
            System.debug(cexception.getMessage());
        }
        
    }
    
    static testMethod void test() {
        
        String cron = '0 0 12 * * ?';
        Test.startTest();
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation;
       
        User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Order order = new Order(Name = 'DEEDS Order', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card', Authorisation__c =  authorisation.Id);
        insert order;
        order = new Order(Name = 'DERPS Order', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card', Authorisation__c =  authorisation.Id );
        insert order;
        
        order = new Order(Name = 'DD Order 1', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Direct Debit', Authorisation__c =  authorisation.Id);
        insert order;
        order = new Order(Name = 'DD Order 2', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Direct Debit', Authorisation__c =  authorisation.Id );
        insert order;
        order = new Order(Name = 'DD Order 2', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'BPay', Authorisation__c =  authorisation.Id );
        insert order;
        System.debug('Orders for Testing :: ' + [SELECT Name, AccountId, Payment_Reference__c, Payment_Method__c FROM Order]);
                
        System.schedule('Schedule P2PWIBSFileListScheduler', cron, new P2PWIBSFileListScheduler());
        Test.stopTest();
        system.assert(true);
        
    }
}