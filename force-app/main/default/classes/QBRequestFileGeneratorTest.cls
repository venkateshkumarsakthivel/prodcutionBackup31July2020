@IsTest
public class QBRequestFileGeneratorTest {
    
	@testSetup
    private static void initialize() {
	    	try {
	    		Account account = new Account(Name = 'Account For Order');
	    		insert account;
	    		
	        Contact contact = new Contact(LastName ='QB req estLastName',AccountId = account.Id, Email='QBtester@qval.com');
	        insert contact;
	        
	        Id profileId = [select Id from profile where name='Authorised Service Provider'].Id;
	        User user = new User(alias = 'PSTEST', email='QBFileGeneratorTestUser@qval.com',
	                             emailencodingkey='UTF-8', lastname='ABAFileGeneratorTestUserLastName', languagelocalekey='en_US',
	                             localesidkey='en_US', profileid = profileId, country='India', IsActive =true,
	                             contactId = contact.Id,
	                             timezonesidkey='America/Los_Angeles', username='QBFileGeneratorTestUser@qval.com.dev');
	        
	        insert user;
	    	} catch(Exception cexception) {
	    		System.debug(cexception.getMessage());
	    	}
    		
    }
    
    
    public static testMethod void executeTest()  {
    		Account account = [SELECT Id, Name FROM Account WHERE Name = 'Account For Order' LIMIT 1];
    		User user = [SELECT Id, username, lastname FROM User LIMIT 1];
    		Authorisation__c authorisation1 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order', Payment_Token__c = String.valueOf(Math.random()));
    		insert authorisation1;
			
        	Order order1 = new Order(Authorisation__c = authorisation1.Id, Name = 'paymentStatusControllerTestUser Order', 
                                    AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', 
                                    Payment_Method__c = 'Credit Card/Debit Card');
        	insert order1;
        	Authorisation__c authorisation2 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order', Payment_Token__c = String.valueOf(Math.random()));
    		insert authorisation2;
    		Order order2 = new Order(Authorisation__c = authorisation2.Id, Name = 'ControllerTestUser Order', 
                                    AccountId = account.Id, EffectiveDate = Date.Today(), Status = 'Payment Due', 
                                    Payment_Method__c = 'Direct Debit');
    		
    		insert order2;
    		List<Order> orders = [SELECT ID, TotalAmount, Authorisation__r.Payment_Token__c,
                                  Authorisation__r.Authorisation_Number__c, Payment_Reference__c,Payment_Method__c
                                  FROM Order ];
    		
    		QBRequestFileGenerator qbRequest = new QBRequestFileGenerator();
    		qbRequest.execute(orders);
    		System.assert(qbRequest.visitor.response.get('status') == '202', ' actual value is : ' + qbRequest.visitor.response.get('status'));
    }
}