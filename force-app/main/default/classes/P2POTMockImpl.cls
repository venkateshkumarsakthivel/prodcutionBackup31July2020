/**
 * Mock Implementation for OT API test
 * Built and used only for Mock Integration 
 * for E2E flow testing prior to SIT
 */
public class P2POTMockImpl implements AWSC_TestProxy {

    public AWSC_Response execute(AWSC_Request request){
        
        String endpoint = request.getEndpoint();
        AWSC_Request.RequestMethod method = request.method;
        P2POTAppClient.P2POTRequestParam reqParams = (P2POTAppClient.P2POTRequestParam) ((AWSC_ServiceRestRequest)request).getParams();

        String responseText = '';
        Integer statusCode = 200;
        AWSC_Response response;
        if(reqParams.requestType == P2POTAppClient.OT_REQUEST_TYPE.CREATENODE){
        		response = new P2POTMockDataGenerator().getUploadResponse(reqParams);
        } else if(reqParams.requestType == P2POTAppClient.OT_REQUEST_TYPE.BROWSENODE){
        		response = new P2POTMockDataGenerator().getBrowseResponse(reqParams);
        } else if(reqParams.requestType == P2POTAppClient.OT_REQUEST_TYPE.NODECONTENT){
            //200-OK, 403-Forbidden, 404-Notfound, 500-InternalServerError
            response = new P2POTMockDataGenerator().getNodeContentResponse(reqParams);
        }
        return response;
    }
}