public without sharing class P2PWIBSPaymentController {
    
    @AuraEnabled
    public static String payment(String community, Decimal principalAmount, String paymentReference, String accountType)  {
        P2PWIBSPaymentFacade p2PWIBSPaymentFacade = new P2PWIBSPaymentFacade();
        Map<String, String> result = p2PWIBSPaymentFacade.securityToken(community, principalAmount, paymentReference, accountType, false, '');
        return Json.serialize(result);
    }

}