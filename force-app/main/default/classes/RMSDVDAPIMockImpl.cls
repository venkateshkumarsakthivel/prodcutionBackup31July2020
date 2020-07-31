/**
 * Mock Implementation for RMS API test
 * Built and used only for Mock Integration 
 * for E2E flow testing prior to SIT
 */
public class RMSDVDAPIMockImpl implements WebServiceMock {

    @TestVisible
    private static Boolean TEST_FOR_ERROR = false;
    
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction, String requestName, String responseNS, String responseName, String responseType){
        //check request body for request type
        
               
        //create response
        
    }
    
    public AWSC_Response execute(AWSC_ServiceRestRequest request){
        
        RMSResponseEnvelope.ResponseStatusMessages successStatus = 
            (RMSResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus": "SUCCESS"}', 
                                                                               RMSResponseEnvelope.ResponseStatusMessages.class);
        RMSResponseEnvelope.ResponseStatusMessages error_validationStatus = 
            (RMSResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus": "ERROR","message": [{"severity": "ERROR","code": "DATA VALIDATION","description": "The information entered cannot be verified. Please check the details entered and try again"}]}',
                                                                               RMSResponseEnvelope.ResponseStatusMessages.class);
        
        String vehicleY = '{"transactionId":"19-23-001-804-TfNSW","vehicleEligibilityStatus":"Y","lastPassedAISInspectionDate":"2019-03-11"}';
        String vehicleUnknown = '{"transactionId":"19-23-001-804-TfNSW","vehicleEligibilityStatus":"DATA_VALIDATION","lastPassedAISInspectionDate":""}';
        
        RMSRequestEnvelope req = (RMSRequestEnvelope) request.getParams();
        RMSResponseEnvelope res = new RMSResponseEnvelope();
        res.setHeader(req.getHeader());
        String queryUid = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,10);
        String body = '{}';
        Boolean isError = false;
        
        if(!TEST_FOR_ERROR) {
            //data success - Y or N
            res.setStatusMessages(successStatus);
            body = vehicleY;
            
        }else{
            isError = true;
            res.setStatusMessages(error_validationStatus);
            //data validation error - always N
            body = vehicleUnknown;
        }        
        
        res.setBody((RMSResponseEnvelope.RMSResponseBody)JSON.deserializeStrict(body, RMSResponseEnvelope.RMSResponseBody.class));
        String responseText = JSON.serialize(res);
        Integer statusCode = isError? 400 : 200;
        AWSC_Response response = new AWSC_Response('mock', responseText, statusCode, 'application/json');
        return response;
    }
}