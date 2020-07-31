/**
 *	Rest resource to receive the response from Quick vault. Quick vault posts the response configured in returnURL
 *	ReturnURL needs to added to the custom metadata type: WIBS_Configuration__mdt for field: qvalent serverReturnUrl
 *	Any errors recevied while updating the Authorisation record will be logged in Application Logs.
 */
@RestResource(urlMapping='/P2PQuickVaultPayment/*')
global without sharing class P2PQuickVaultPaymentResponseController {
    @HttpPost
    global static Boolean processServerReturnCallback() {
        try {
            
                Map <String, String> parameters = RestContext.request.params;
                System.debug('parameters: '+parameters);
                //ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2PQuickVaultPaymentResponseController', 
                //                                 'processServerReturnCallback', String.valueOf(parameters) , null);
                String customerReferenceNumber = parameters.get('customerReferenceNumber');
            	String preregistrationCode = parameters.get('preregistrationCode');	
                if(parameters.containsKey('accountNumber') && preregistrationCode != NULL ) {
                    // direct debit registration
                    String accountName = parameters.get('accountName');
                    String accountNumber = parameters.get('accountNumber');                   
                    String bsb = parameters.get('bsb');
                    RegistrationStatus.updateDirectDebitAuthDetails(customerReferenceNumber, accountName, accountNumber,
                                                                    bsb, preregistrationCode);
                } else if(parameters.containsKey('cardholderName') && preregistrationCode != NULL){
                    // credit card registration
                    String cardholderName = parameters.get('cardholderName');
                    String maskedCardNumber	= parameters.get('maskedCardNumber');                   
                    String expiryDateMonth = parameters.get('expiryDateMonth');
                    String expiryDateYear = parameters.get('expiryDateYear');
                    String cardScheme = parameters.get('cardScheme');
                    RegistrationStatus.updateCreditCardAuthDetails(customerReferenceNumber, cardholderName, maskedCardNumber, 
                                                                   expiryDateMonth, expiryDateYear, cardScheme, preregistrationCode);
                } else {
                    // registration failed at quick vault
                    ApplicationLogUtility.logMessage(GlobalConstants.INFO, 'P2PQuickVaultPaymentResponseController', 'processServerReturnCallback',
                                                     'Registration failed in Quick vault.\n Parameters recived:\n'+Json.serialize(parameters), null);
                }
        	} catch (Exception commonException) {
                    ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2PQuickVaultPaymentResponseController	', 
                                                     'processServerReturnCallback', commonException.getMessage(), commonException);
                    return false;
        	}
        return true; 
    }
}