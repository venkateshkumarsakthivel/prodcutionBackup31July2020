/**
 * Mock Implementation for RMS OVT API test
 * Built and used only for Mock Integration 
 * for E2E flow testing prior to SIT
 */

public with sharing class P2PRMSOvtMockImplementation implements WebServiceMock {
    public static Integer reandomCode1;
    public static Integer reandomCode2;

	public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction, String requestName, String responseNS, String responseName, String responseType){
    	//check request body for request type
    	
               
		//create response
		
    }
    
    public AWSC_Response execute(AWSC_ServiceRestRequest request){
        
        RMSOVTResponseEnvelope.ResponseStatusMessages successStatus = 
            (RMSOVTResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus":"Success","message":null}', 
                                                                               RMSOVTResponseEnvelope.ResponseStatusMessages.class);
        RMSOVTResponseEnvelope.ResponseStatusMessages error_validationStatus = 
            (RMSOVTResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus": "ERROR","message": [{"severity": "ERROR","code": "SYS0000003","description": "Backend internal server error"}]}',
                                                                               RMSOVTResponseEnvelope.ResponseStatusMessages.class);
            
        RMSOVTRequestEnvelope req = (RMSOVTRequestEnvelope) request.getParams();
        RMSOVTResponseEnvelope res = new RMSOVTResponseEnvelope();
        res.setHeader(req.getHeader());

        Boolean isError = false;
            if(reandomCode1 != null && Math.mod(reandomCode1, 2)== 0) {
                //data success - Y or N
                res.setStatusMessages(successStatus);
            }
            else if(reandomCode1 != null && Math.mod(reandomCode1, 2)== 1) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Read timed out');
                throw e;
            }else{
                isError = true;
                if(reandomCode2 != null && Math.mod(reandomCode2, 2)== 0 )
                    res.setStatusMessages(error_validationStatus);
                else {
                    AWSC_Response response = new AWSC_Response('mock', 'responseText', 400, 'application/json');
                    return response;
                }
            }
       

        String responseText = JSON.serialize(res);
        Integer statusCode = isError? 400 : 200;
        AWSC_Response response = new AWSC_Response('mock', responseText, statusCode, 'application/json');
        return response;
    }
}