@RestResource(urlMapping='/P2PWIBSPayment/*')
global without sharing class P2PWIBSPaymentResponseController {
    @HttpPost
    global static Boolean processServerReturnCallback()  {
            try {
            
            //ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2PWIBSPaymentResponseController', 'processServerReturnCallback', 'Debug Log: Rest Response Handler', null);
            
            Map <String, String> parameters = RestContext.request.params;
            String request = '';
            String summaryCode = parameters.get('summaryCode');
            String paymentReference = parameters.get('paymentReference');
            String paymentType = 'CREDIT_CARD', cardScheme, referenceNumber, receiptNumber, settlementDate;
            Decimal surcharge = parameters.containsKey('surchargeAmount') ? Decimal.valueOf(parameters.get('surchargeAmount')) : 0;
            cardScheme = parameters.get('cardScheme');
            receiptNumber = parameters.get('receiptNumber');
            settlementDate = parameters.get('settlementDate');
            Decimal amount = Decimal.valueOf(parameters.get('paymentAmount'));
            if(summaryCode.equalsIgnoreCase('0'))  {
                    PaymentStatus.updateToPaidInFull(paymentType, paymentReference, receiptNumber, settlementDate, amount, surcharge);
            } else if(summaryCode.equalsIgnoreCase('1'))  {
                    PaymentStatus.updateToPaymentRejected(paymentReference);
            }
            //ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2PWIBSPaymentResponseController', 'processServerReturnCallback', 'Debug Log: Rest Response Handler', null);
            return true;
            } catch (Exception commonException) {
            
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2PWIBSPaymentResponseController', 'processServerReturnCallback', commonException.getMessage(), commonException);
                return false;
            }
    }
}