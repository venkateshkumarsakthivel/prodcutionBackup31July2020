public with sharing class P2POSRPaymentStatusResource extends P2POSRRPCServiceResource {
    
    //constructor
    public P2POSRPaymentStatusResource(Object parameters, AWSC_ResponseParserVisitor visitor) { 
        super(parameters);
        this.visitor = visitor;
    }
    
    public class P2POSRPaymentStatusSOAPRequest extends AWSC_RPCRequest {
        /** construct a new service SOAP request for the passed service resource */
        public P2POSRPaymentStatusSOAPRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
            super(serviceResource, serviceLocator, false);
        }
    }
    
    public class P2POSRPaymentStatusSOAPRequestBuilder extends P2POSRSOAPRequestBuilder {
        
        /*** create a request builder */
        public P2POSRPaymentStatusSOAPRequestBuilder(AWSC_ServiceResource parent) { 
            this.parent = parent;
        }
        
        public override AWSC_Request buildRequest(Object requestParameters) {
            
            P2POSRPaymentStatusSOAPRequest request = new P2POSRPaymentStatusSOAPRequest(this.parent, this.parent.getServiceLocator());
            request.method = AWSC_Request.RequestMethod.POST;
            P2POSRRequestParameter osrRequestParameters = (P2POSRRequestParameter) requestParameters;
            try{
                //fetch required params from the config
                if(P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:getPaymentStatusRecordCountRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/"><reportDate>';
                    this.postFixRequestBodyTag = '</reportDate></tns:getPaymentStatusRecordCountRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag
                        + osrRequestParameters.paymentStatusReportDate.unescapeHtml4()
                        + this.postFixRequestBodyTag + this.postFixXML();
                } 
                else if(P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_REPORT_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:getPaymentStatusReportRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:getPaymentStatusReportRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    
                    this.requestBody += '<reportDate>' + osrRequestParameters.paymentStatusReportDate.unescapeHtml4() + '</reportDate>';
                    this.requestBody += '<requestPage>' + osrRequestParameters.paymentStatusReportRequestPage + '</requestPage>';
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                } 
                
                this.requestBody = this.requestBody.replaceAll('&', '&amp;');
                System.debug(LoggingLevel.INFO, 'Request Body: ' + this.requestBody);
                request.setXMLBody(this.requestBody);
                Map<String, String> headers = new Map<String, String>();
                request.headers = headers;
                request.contentType = 'application/xml';
                return request;
                
            } catch(Exception ex) {
                //Insert Application Log
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2POSRCUAssessmentResource', 'buildRequest', ex.getMessage(), JSON.serialize(osrRequestParameters), ex, null, 'Revenue NSW Request Generation Error', osrRequestParameters.referenceId, null);
                return null;
            }
        }
    }
    
    /** return the relative uri path to the resource */
    public override String getResourcePath() { 
        return ''; 
    }
    
    /** return the authentication strategy */
    protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() { 
        return new P2POSRAuthenticationStrategy();
    }
    
    /** return the service locator */
    public override AWSC_ServiceLocator getServiceLocator() {
        if(this.serviceLocator == null) { 
            this.serviceLocator = new P2POSR_SOAPServiceLocator(); 
        }
        return this.serviceLocator;
    }
    
    /** return the service request builder, request builder - to be provided by specific resource implementation */
    protected virtual override AWSC_RequestBuilder getRequestBuilder() {
        return new P2POSRPaymentStatusSOAPRequestBuilder(this);
    }
    
    /** return the service response parser response parser - to be provided by specific resource implementation */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POSRSOAPResponseParser(this);
    }
}