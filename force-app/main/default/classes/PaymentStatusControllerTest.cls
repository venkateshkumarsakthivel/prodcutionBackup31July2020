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
private class PaymentStatusControllerTest {
	
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
    
    private static testMethod void paid()  {
    		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
    		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
            Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        	insert authorisation;
    		Order order = new Order(Name = 'paymentStatusControllerTestUser Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
    		insert order;
    		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];

    		String paymentReference = order.Payment_Reference__c;
    		System.debug('order.Payment_Reference__c : ' + order.Payment_Reference__c);
    		
    		PaymentStatusController.paid(order.Payment_Method__c, paymentReference, 'receiptNumber-0001', '20170818', '1215.98', '119.00');
    		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :paymentReference];
    		
    		System.assert(order.Status.toLowerCase() == 'paid in full', 'Actual Value is ' + order.Status);
    }
    
    private static testMethod void reject()  {
    		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
    		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
            Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        	insert authorisation;        
    		Order order = new Order(Name = 'paymentStatusControllerTestUser Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due');
    		insert order;
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER  LIMIT 1];    		
    		
    		String paymentReference = order.Payment_Reference__c;
    		PaymentStatusController.reject(paymentReference);
    		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :paymentReference];
    		
    		System.assert(order.Status.toLowerCase() == 'payment rejected', 'Actual Value is ' + order.Status);
    }
    
    private static testMethod void cancel()  {
    		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
    		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
			Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
			insert authorisation;        
    		Order order = new Order(Name = 'paymentStatusControllerTestUser Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due');
    		insert order;
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER LIMIT 1];
    		
    		String paymentReference = order.Payment_Reference__c;
    		PaymentStatusController.cancel(paymentReference);
    		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :paymentReference];
    		
    		System.assert(order.Status.toLowerCase() == 'payment cancelled', 'Actual Value is ' + order.Status);
    }
    
    
}