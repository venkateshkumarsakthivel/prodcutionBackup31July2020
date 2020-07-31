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
private class ABAFileGeneratorTest {
	
	@testSetup
    private static void initialize() {
	    	try {
	    		Account account = new Account(Name = 'Account For Order');
	    		insert account;
	    		
	        Contact contact = new Contact(LastName ='ABAFileGeneratorTestLastName',AccountId = account.Id, Email='ABAFileGeneratorTest@testing.don');
	        insert contact;
	        
	        Id profileId = [select Id from profile where name='Authorised Service Provider'].Id;
	        User user = new User(alias = 'PSTEST', email='ABAFileGeneratorTestUser@testing.don',
	                             emailencodingkey='UTF-8', lastname='ABAFileGeneratorTestUserLastName', languagelocalekey='en_US',
	                             localesidkey='en_US', profileid = profileId, country='India', IsActive =true,
	                             contactId = contact.Id,
	                             timezonesidkey='America/Los_Angeles', username='ABAFileGeneratorTestUser@testing.don');
	        
	        insert user;
	    	} catch(Exception cexception) {
	    		System.debug(cexception.getMessage());
	    	}
    		
    }
    
    
    public static testMethod void executeTest()  {
    		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
    		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
    		Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order', BSB_Number__c = '032-002', Bank_Account_Number__c = '123465', Bank_Account_Name__c = 'Name 123456');
    		insert authorisation;
    		authorisation = [SELECT Id, Authorisation_Name__c, BSB_Number__c, Bank_Account_Number__c, Bank_Account_Name__c FROM Authorisation__c];
    		
    		Order order = new Order(Authorisation__c = authorisation.Id, Name = 'paymentStatusControllerTestUser Order', AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', Payment_Method__c = 'Credit Card/Debit Card');
    		insert order;
    		List<Order> orders = [SELECT Authorisation__r.Authorisation_Name__c, Authorisation__r.BSB_Number__c, Authorisation__r.Bank_Account_Number__c, Authorisation__r.Bank_Account_Name__c, TotalAmount, Authorisation__c, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, Payment_Method__c FROM ORDER];
    		
    		ABAFileGenerator abaFileGenerator = new ABAFileGenerator();
    		abaFileGenerator.execute(1, orders);
    		System.assert(abaFileGenerator.visitor.response.get('status') == '202', ' actual value is : ' + abaFileGenerator.visitor.response.get('status'));
    }
}