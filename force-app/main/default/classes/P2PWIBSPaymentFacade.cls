public without sharing class P2PWIBSPaymentFacade {
    
    private static final String ASP = GlobalConstants.INVOCATION_CONTEXT_ASP.toLowerCase();
    private static final String TAXI = GlobalConstants.INVOCATION_CONTEXT_TAXI.toLowerCase();
    private static final String INTERNAL_STAFF = GlobalConstants.INVOCATION_CONTEXT_INTERNAL_STAFF.toLowerCase();
    
    public Map<String, String> securityToken(String community, Decimal principalAmount, String paymentReference, String accountType, Boolean isInitiatedFromManageAccount, String sfRecordId) {
        
        P2PWIBSPaymentRequestConstants p2PWIBSPaymentRequestConstants = new P2PWIBSPaymentRequestConstants();
        P2PWIBSPaymentClient client = new P2PWIBSPaymentClient();
        P2PWIBSPaymentClient.WIBSPaymentRequestParam parameters = new P2PWIBSPaymentClient.WIBSPaymentRequestParam();
        
        parameters.username = p2PWIBSPaymentRequestConstants.username;
        parameters.password = p2PWIBSPaymentRequestConstants.password;
        parameters.principalAmount = principalAmount;
        parameters.paymentReference = paymentReference;
        parameters.customerReferenceNumber = paymentReference;
        parameters.accountType = accountType;
        parameters.supplierBusinessCode = p2PWIBSPaymentRequestConstants.supplierBusinessCode;
        parameters.connectionType = p2PWIBSPaymentRequestConstants.connectionType;
        parameters.product = p2PWIBSPaymentRequestConstants.product;
        parameters.serverReturnUrl = p2PWIBSPaymentRequestConstants.serverReturnUrl;
        
        /**
        * switch return and cancel URLs based on which community currently active.
        */
        if(community.toLowerCase().compareTo(ASP) == 0)  {
            
            parameters.returnUrl = p2PWIBSPaymentRequestConstants.aspReturnUrl;
            parameters.cancelUrl = p2PWIBSPaymentRequestConstants.aspCancelUrl;            
        } 
        else if(community.toLowerCase().compareTo(TAXI) == 0)  {
            
            parameters.returnUrl = p2PWIBSPaymentRequestConstants.taxiReturnUrl;
            parameters.cancelUrl = p2PWIBSPaymentRequestConstants.taxiCancelUrl;            
        }
        else if(community.toLowerCase().compareTo(INTERNAL_STAFF) == 0)  {
            
            parameters.returnUrl = p2PWIBSPaymentRequestConstants.internalStaffReturnUrl+'/'+sfRecordId + '/view';
            parameters.cancelUrl = p2PWIBSPaymentRequestConstants.internalStaffCancelUrl+'/'+sfRecordId + '/view';            
        }
        
        if(isInitiatedFromManageAccount && community.toLowerCase().compareTo(INTERNAL_STAFF) != 0)
            parameters.cancelUrl += '/manage-profile?src=accountMenu';
        else if(community.toLowerCase().compareTo('asp') == 0)
            parameters.cancelUrl += '/asp-application-list?src=myApplicationMenu';
        else if(community.toLowerCase().compareTo('taxi') == 0)
            parameters.cancelUrl += '/manage-profile?src=accountMenu';
        
        //adding parameters to return URL
        if(community.toLowerCase().compareTo(INTERNAL_STAFF) != 0)
          parameters.returnUrl += '?isInitiatedFromManageAccount='+isInitiatedFromManageAccount+'&communityContext='+community;
        
        parameters.errorEmailToAddress = p2PWIBSPaymentRequestConstants.errorEmailToAddress;
        P2PWIBSSTResponseParserVisitor p2PWIBSSTResponseParserVisitor = new P2PWIBSSTResponseParserVisitor();
        client.callWIBSPAYMENTApplication(P2PWIBSPaymentClient.WIBS_PAYMENT_REQUEST_TYPE.SECURITY_TOKEN, p2PWIBSSTResponseParserVisitor, parameters);
        String token = p2PWIBSSTResponseParserVisitor.token;
        String redirectURL = p2PWIBSPaymentRequestConstants.redirectURL + '?communityCode=' + p2PWIBSPaymentRequestConstants.communityCode + '&token=' + token;
        Map<String, String> result = new Map<String, String>();
        result.put('redirectURL', redirectURL);
        return result;
    }
}