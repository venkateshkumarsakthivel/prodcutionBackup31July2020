@isTest
private class P2PWIBSPaymentControllerTest {
    private static testMethod void paymentSuccess()  {
        String accountType = 'CREDIT_CARD';
        String paymentReference = 'INV00001';
        Double principalAmount = 1000.90;
        /* ASP execute controller payment method and check if we receive security token. */
        String token = P2PWIBSPaymentController.payment('ASP', principalAmount, paymentReference, accountType);
        System.assert(false == String.isblank(token));
        
        /* TAXI execute controller payment method and check if we receive security token. */
        token = P2PWIBSPaymentController.payment('TAXI', principalAmount, paymentReference, accountType);
        System.assert(false == String.isblank(token));
    }
}