public without sharing class P2PQuickVaultPaymentFacade {
    
        public Map<String, String> securityToken(String paymentReference, String sfRecordId) {
        
        P2PQuickVaultRequestConstants p2PWIBSPaymentRequestConstants = new P2PQuickVaultRequestConstants();
        P2PWIBSPaymentClient client = new P2PWIBSPaymentClient();
        P2PWIBSPaymentClient.WIBSPaymentRequestParam parameters = new P2PWIBSPaymentClient.WIBSPaymentRequestParam();
        
        parameters.username = p2PWIBSPaymentRequestConstants.username;
        parameters.password = p2PWIBSPaymentRequestConstants.password;
        parameters.paymentReference = paymentReference;
        parameters.customerReferenceNumber = paymentReference;
        parameters.principalAmount = 0;
        parameters.supplierBusinessCode = p2PWIBSPaymentRequestConstants.supplierBusinessCode;
        parameters.connectionType = p2PWIBSPaymentRequestConstants.connectionType;
        parameters.product = p2PWIBSPaymentRequestConstants.product;
        parameters.serverReturnUrl = p2PWIBSPaymentRequestConstants.serverReturnUrl;
        parameters.returnUrl = p2PWIBSPaymentRequestConstants.internalStaffReturnUrl+'/'+sfRecordId + '/view';
        parameters.cancelUrl = p2PWIBSPaymentRequestConstants.internalStaffCancelUrl+'/'+sfRecordId + '/view';            
        
        parameters.errorEmailToAddress = p2PWIBSPaymentRequestConstants.errorEmailToAddress;
        P2PWIBSSTResponseParserVisitor p2PWIBSSTResponseParserVisitor = new P2PWIBSSTResponseParserVisitor();
        client.callWIBSPAYMENTApplication(P2PWIBSPaymentClient.WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN, p2PWIBSSTResponseParserVisitor, parameters);
        String token = p2PWIBSSTResponseParserVisitor.token;
        String redirectURL = p2PWIBSPaymentRequestConstants.redirectURL + '?communityCode=' + p2PWIBSPaymentRequestConstants.communityCode + '&token=' + token;
        Map<String, String> result = new Map<String, String>();
        result.put('redirectURL', redirectURL);
        return result;
    }
    
}