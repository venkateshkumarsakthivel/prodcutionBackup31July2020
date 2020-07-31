/**
 * Mock Implementation for WIBS PAYMENT REST API (qvalent) test
 * Built and used only for Mock Integration
 */
public class P2PWIBSPaymentMockImplementation implements AWSC_TestProxy {
	public AWSC_Response execute(AWSC_Request request)  {
        String endpoint = request.getEndpoint();
        AWSC_Request.RequestMethod method = request.method;
        P2PWIBSPaymentClient.WIBSPaymentRequestParam requestParameters = (P2PWIBSPaymentClient.WIBSPaymentRequestParam) ((AWSC_ServiceRestRequest)request).getParams();
        AWSC_Response response;
        String responseText = '';
        if(requestParameters.requestType == P2PWIBSPaymentClient.WIBS_PAYMENT_REQUEST_TYPE.SECURITY_TOKEN || 
           requestParameters.requestType == P2PWIBSPaymentClient.WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN)  {
            responseText = 'token=grcSZKglZa79wPUiHwYaUh6nYyfAtDslc9sTvoYLnKs';
            response = new AWSC_Response('wibs-payment-mock', responseText, 200, 'text/plain');
        }
        
        return response;
    }
}