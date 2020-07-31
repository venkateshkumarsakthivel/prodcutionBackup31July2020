/**
*/
public with sharing class P2POSRClient {
    public Enum OSR_REQUEST_TYPE { OSR_ECHO_REQUEST, OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST, OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST,
        OSR_CREATE_AUTHORISATION_REQUEST, OSR_UPDATE_AUTHORISATION_REQUEST, OSR_CANCEL_AUTHORISATION_REQUEST,
        OSR_CREATE_ASSESSMENT_REQUEST, OSR_UPDATE_ASSESSMENT_REQUEST, OSR_GET_ASSESSMENT_REQUEST,
        OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST, OSR_GET_PAYMENT_STATUS_REPORT_REQUEST }
    public P2POSRRPCServiceResource resource { get; set; }
    
    public void call(OSR_REQUEST_TYPE requestType, AWSC_ResponseParserVisitor visitor, P2POSRRequestParameter requestParameters)  {
        //should throw an exception if no query for found
        P2POSRRequestParameter parameters = (P2POSRRequestParameter) requestParameters;
        
        if(requestType == null)  {
            throw new AWSC_Exception('No OSR REQUEST requestType value set. Unable to understand which query to fire.');
        }
        
        if(requestType == OSR_REQUEST_TYPE.OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST;
            resource = new P2POSRProviderAuthorisationResource(requestParameters, visitor);
        } else if(requestType == OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST;
            resource = new P2POSRProviderAuthorisationResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_CREATE_AUTHORISATION_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_CREATE_AUTHORISATION_REQUEST;
            resource = new P2POSRIndividualAuthorisationResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_UPDATE_AUTHORISATION_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_UPDATE_AUTHORISATION_REQUEST;
            resource = new P2POSRIndividualAuthorisationResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_CANCEL_AUTHORISATION_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_CANCEL_AUTHORISATION_REQUEST;
            resource = new P2POSRIndividualAuthorisationResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST;
            resource = new P2POSRCUAssessmentResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_UPDATE_ASSESSMENT_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_UPDATE_ASSESSMENT_REQUEST;
            resource = new P2POSRCUAssessmentResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST;
            resource = new P2POSRCUAssessmentResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST;
            resource = new P2POSRPaymentStatusResource(requestParameters, visitor);        	
        } else if(requestType == OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_REPORT_REQUEST)  {
            parameters.requestType = OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_REPORT_REQUEST;
            resource = new P2POSRPaymentStatusResource(requestParameters, visitor);        	
        }

        resource.execute();
    }
    
}