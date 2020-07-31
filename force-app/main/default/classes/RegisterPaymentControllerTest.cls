@isTest
public class RegisterPaymentControllerTest {
    
    @isTest
    private static void initialize() {
    	String returnURL = RegisterPaymentController.fetchHandOffURL('paymentReference', 'sfRecordId');
        System.assert(returnURL != '',true);
    }

}