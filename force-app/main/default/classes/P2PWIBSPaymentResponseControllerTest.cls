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
private class P2PWIBSPaymentResponseControllerTest {

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
    
    @isTest
    static void processServerReturnCallbackTestStatusCodeZERO() {
		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
		insert authorisation;
		Order order = new Order(Name = 'DEEDS Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
		insert order;
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
		Map<String, String> parameters = new Map<String, String> {'summaryCode' => '0', 'paymentReference' => order.Payment_Reference__c, 'cardScheme' => 'VISA', 'receiptNumber' => 'RECP00001', 'settlementDate' => '20170829', 'paymentAmount' => '1200.00'};
		
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PWIBSPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];		
		System.assert(order.Status == 'Paid In Full', ' Actual status of order is ' + order.Status);
        
    }
    
    static testMethod void processServerReturnCallbackTestStatusCodeONE() {
		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
		insert authorisation;
		Order order = new Order(Name = 'DEEDS Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
		insert order;
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
		Map<String, String> parameters = new Map<String, String> {'summaryCode' => '1', 'paymentReference' => order.Payment_Reference__c, 'cardScheme' => 'VISA', 'receiptNumber' => 'RECP00001', 'settlementDate' => '20170829', 'paymentAmount' => '1200.00'};
		
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PWIBSPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];		
		System.assert(order.Status == 'Payment Rejected', ' Actual status of order is ' + order.Status);
        
    }
    
    static testMethod void processServerReturnCallbackTestStatusCodeEXCEPTION() {
		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
		Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
		insert authorisation;        
		Order order = new Order(Name = 'DEEDS Order', AccountId = account.Id, Authorisation__c =  authorisation.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card' );
		insert order;
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];
		Map<String, String> parameters = new Map<String, String> {'paymentReference' => order.Payment_Reference__c, 'cardScheme' => 'VISA', 'receiptNumber' => 'RECP00001', 'settlementDate' => '20170829', 'paymentAmount' => '1200.00'};
		
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PWIBSPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		order = [SELECT Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER  LIMIT 1];		
		System.assert(order.Status == 'Payment Due', ' Actual status of order is ' + order.Status);
        
    }
}