@isTest
private class P2PQVPaymentResponseControllerTest {

    static testMethod void processServerReturnCallbackTestInvalidAuthNumber() {
		Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(Name = 'Account For Order');
		insert account;
	    		
        User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation1 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation1;
       
        Map<String, String> parameters = new Map<String, String> {
                'communityCode' => 'TNSWPTP', 
                'supplierBusinessCode' => 'TNSWPTP', 
                'customerReferenceNumber' => 'sadfsdfasf',//authorisation1.Authorisation_Number__c,  //Authorisation Number
                'cardholderName' => 'test account', 
                'maskedCardNumber' => '411111...111', 
                'cardScheme' => 'VISA',
                'expiryDateMonth' => '01',
                'expiryDateYear' =>	'2031',
                'preregistrationCode' =>'TNSWPP10841795', //token
        		'action' => 'Registered'};
		
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PQuickVaultPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		authorisation1 = [SELECT Payment_Token__c, Payment_Expiry_Date__c, 
                          		Payment_Card_Number__c, Payment_Card_Type__c
                          FROM Authorisation__c  LIMIT 1];	
        System.debug('authorisation1.Payment_Token__c: '+authorisation1.Payment_Token__c);
		System.assert(authorisation1.Payment_Token__c == NULL, 'Payment token not registered.');
        
    }
    
	static testMethod void processServerReturnCallbackTestDirectDebit() {
		Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(Name = 'Account For Order');
		insert account;
	    		
        User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation1 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation1;
        authorisation1 = [Select Id,Name,Authorisation_Number__c from Authorisation__c limit 1];

        Map<String, String> parameters = new Map<String, String> {
                'communityCode' => 'TNSWPTP', 
                'supplierBusinessCode' => 'TNSWPTP', 
                'customerReferenceNumber' => authorisation1.Name,  //Authorisation Number
                'accountName' => 'test account', 
                'bsb' => 'xxx-999', 
                'accountNumber' => 'xxxxxx994',
                'preregistrationCode' =>'TNSWPP10851726', //token
        		'action' => 'Registered'};
		
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PQuickVaultPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
	
		authorisation1 = [SELECT Payment_Token__c, Payment_Expiry_Date__c, 
                          		Payment_Card_Number__c, Payment_Card_Type__c
                          FROM Authorisation__c  LIMIT 1];

        System.debug('authorisation1.Payment_Token__c: '+authorisation1.Payment_Token__c);
		System.assert(authorisation1.Payment_Token__c != NULL, 'Payment token registered.');
 
    }
   	static testMethod void processServerReturnCallbackTestCreditCard() {
		Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(Name = 'Account For Order');
		insert account;
	    		
        User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation1 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation1;
        authorisation1 = [Select Id,Name, Authorisation_Number__c from Authorisation__c limit 1];
         Map<String, String> parameters = new Map<String, String> {
                'communityCode' => 'TNSWPTP', 
                'supplierBusinessCode' => 'TNSWPTP', 
                'customerReferenceNumber' => authorisation1.Name,  //Authorisation Number
                'cardholderName' => 'test account', 
                'maskedCardNumber' => '411111...111', 
                'cardScheme' => 'VISA',
                'expiryDateMonth' => '01',
                'expiryDateYear' =>	'2031',
                'preregistrationCode' =>'TNSWPP10841795', //token
        		'action' => 'Registered'};
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PQuickVaultPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		authorisation1 = [SELECT Payment_Token__c, Payment_Expiry_Date__c, 
                          		Payment_Card_Number__c, Payment_Card_Type__c
                          FROM Authorisation__c  LIMIT 1];	
        System.debug('authorisation1.Payment_Token__c: '+authorisation1.Payment_Token__c);
		System.assert(authorisation1.Payment_Token__c != NULL, 'Payment token registered.');
        
    }
   	static testMethod void processServerReturnCallbackTestFailure() {
		Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(Name = 'Account For Order');
		insert account;
	    		
        User user = [SELECT Id, username, lastname FROM User LIMIT 1];
        Authorisation__c authorisation1 = new Authorisation__c(Service_Provider__c = account.Id, Authorisation_Name__c = 'Authorisation for Order');
        insert authorisation1;
        authorisation1 = [Select Id, Name, Authorisation_Number__c from Authorisation__c limit 1];
         Map<String, String> parameters = new Map<String, String> {
                'communityCode' => 'TNSWPTP', 
                'supplierBusinessCode' => 'TNSWPTP', 
                'customerReferenceNumber' => authorisation1.Name,  //Authorisation Number
                'cardholderName' => 'test account', 
                'maskedCardNumber' => '411111...111', 
                'cardScheme' => 'VISA',
                'expiryDateMonth' => '01',
                'expiryDateYear' =>	'2031',
                'preregistrationCode' =>null, //token
        		'action' => 'Registered'};
		RestRequest restRequest = new RestRequest();
		RestResponse restResponse = new RestResponse();
		restRequest.httpMethod = 'POST';
		/** add parameters to request. */
		for(String key : parameters.keySet())  {
			restRequest.addParameter(key, parameters.get(key));
		}
		
		RestContext.request = restRequest; RestContext.response = restResponse;
		
		Test.startTest();
			Boolean success = P2PQuickVaultPaymentResponseController.processServerReturnCallback();
		Test.stopTest();
		
		authorisation1 = [SELECT Payment_Token__c, Payment_Expiry_Date__c, 
                          		Payment_Card_Number__c, Payment_Card_Type__c
                          FROM Authorisation__c  LIMIT 1];	
        System.debug('authorisation1.Payment_Token__c: '+authorisation1.Payment_Token__c);
		System.assert(authorisation1.Payment_Token__c == NULL, 'Payment token not registered.');
        
    }
}