/**
 * Mock Implementation for RMS API test
 * Built and used only for Mock Integration 
 * for E2E flow testing prior to SIT
 */
@isTest
public class RMSSDOAPIMockImpl implements WebServiceMock {

    @TestVisible
    private static Boolean TEST_FOR_ERROR = false;
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
           String soapAction, String requestName, String responseNS, String responseName, String responseType){
        //check request body for request type
        
               
        //create response
        
    }
    
    public AWSC_Response execute(AWSC_ServiceRestRequest request){
        
        RMSSDOResponseEnvelope.ResponseStatusMessages successStatus = 
            (RMSSDOResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus":"Success","message":null}', 
                                                                               RMSSDOResponseEnvelope.ResponseStatusMessages.class);
        RMSSDOResponseEnvelope.ResponseStatusMessages error_validationStatus = 
            (RMSSDOResponseEnvelope.ResponseStatusMessages)JSON.deserializeStrict('{"overallStatus": "ERROR","message": [{"severity": "ERROR","code": "SYS0000003","description": "Backend internal server error"}]}',
                                                                               RMSSDOResponseEnvelope.ResponseStatusMessages.class);
        
        String licencePASS = '{"transactionId":"19-23-001-800-TRNSPT","licenceCheckStatus":"PASS","licenceTenureStatus":"PASS","drivingOffenceStatus":"PASS","safetyOffenceStatus":"NOT_APPLICABLE","criminalChargeStatus":"PASS"}}';
        String licenceUnknown = '{"transactionId":"19-23-001-800-TRNSPT","licenceCheckStatus":"DATA_VALIDATION","licenceTenureStatus":"DATA_VALIDATION","drivingOffenceStatus":"DATA_VALIDATION","safetyOffenceStatus":"NOT_APPLICABLE","criminalChargeStatus":"DATA_VALIDATION"}}';
        
        RMSSDORequestEnvelope req = (RMSSDORequestEnvelope) request.getParams();
        RMSSDOResponseEnvelope res = new RMSSDOResponseEnvelope();
        res.setHeader(req.getHeader());
        String queryUid = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,10);
        String body = '{}';
        Boolean isError = false;
        if(!TEST_FOR_ERROR) {
            //data success - Y or N
            res.setStatusMessages(successStatus);
            body = licencePASS;                
        }else{
            isError = true;
            res.setStatusMessages(error_validationStatus);
            //data validation error - always N
            body = licenceUnknown;
        }
       
        system.debug('body: '+body);
        res.setBody((RMSSDOResponseEnvelope.RMSResponseBody)JSON.deserializeStrict(body, RMSSDOResponseEnvelope.RMSResponseBody.class));
        String responseText = JSON.serialize(res);
        Integer statusCode = isError? 400 : 200;
        AWSC_Response response = new AWSC_Response('mock', responseText, statusCode, 'application/json');
        return response;
    }
}