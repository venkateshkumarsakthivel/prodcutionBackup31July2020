public class P2POSRIndividualAuthorisationResource extends P2POSRRPCServiceResource {
    
    //constructors     
    public P2POSRIndividualAuthorisationResource(Object parameters, AWSC_ResponseParserVisitor visitor) { super(parameters);
        this.visitor = visitor;
    }
    
    public  class P2POSRIndividualAuthorisationSOAPRequest extends AWSC_RPCRequest {
        /** construct a new service SOAP request for the passed service resource */
        public P2POSRIndividualAuthorisationSOAPRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
            super(serviceResource, serviceLocator, false);
        }
        
    }
    
    
    public class P2POSRIndividualAuthorisationSOAPRequestBuilder extends P2POSRSOAPRequestBuilder {
        
        /*** create a request builder */
        public P2POSRIndividualAuthorisationSOAPRequestBuilder(AWSC_ServiceResource parent) { this.parent = parent;
        }
        
        
        public override AWSC_Request buildRequest(Object requestParameters) {
            
            P2POSRIndividualAuthorisationSOAPRequest request = new P2POSRIndividualAuthorisationSOAPRequest(this.parent, this.parent.getServiceLocator());
            request.method = AWSC_Request.RequestMethod.POST;
            P2POSRRequestParameter osrRequestParameters = (P2POSRRequestParameter) requestParameters;
            try {
                //fetch required params from the config
                if(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_AUTHORISATION_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:createAuthorisationRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:createAuthorisationRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    System.debug('In Create Authorisation Request condition');
                    if(null != osrRequestParameters.providerAuthorisations.tspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.tspAuthorisation.toXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.providerAuthorisations.bspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.bspAuthorisation.toXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                    System.debug('Request : ' + this.requestBody);
                } else if (P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_AUTHORISATION_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:updateAuthorisationRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:updateAuthorisationRequest>';
                    
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    if(null != osrRequestParameters.providerAuthorisations.tspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.tspAuthorisation.toXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.providerAuthorisations.bspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.bspAuthorisation.toXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                    System.debug('Request : ' + this.requestBody);
                } else if (P2POSRClient.OSR_REQUEST_TYPE.OSR_CANCEL_AUTHORISATION_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:cancelAuthorisationRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:cancelAuthorisationRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    
                    if(null != osrRequestParameters.providerAuthorisations.tspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.tspAuthorisation.cancelAuthorisationToXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.providerAuthorisations.bspAuthorisation)  {
                        this.requestBody += '<requestParameter><TfNSWProviderNumber>' + osrRequestParameters.tfNSWProviderNumber + '</TfNSWProviderNumber>' 
                            + osrRequestParameters.providerAuthorisations.bspAuthorisation.cancelAuthorisationToXML('authorisation').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                    
                }
                this.requestBody = this.requestBody.replaceAll('&', '&amp;');
                System.debug(LoggingLevel.INFO, 'Request Body: ' + this.requestBody);
                request.setXMLBody(this.requestBody);
                Map<String, String> headers = new Map<String, String>();
                request.headers = headers;
                request.contentType = 'application/xml';
                
                return request;
            }catch(Exception ex) {
                //Insert Application Log
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2POSRIndividualAuthorisationResource', 'buildRequest', ex.getMessage(), JSON.serialize(osrRequestParameters), ex, null, 'Revenue NSW Request Generation Error', osrRequestParameters.referenceId, null);
                
                // Update Tax Payer Registration - Revenue NSW Status - Error
                GlobalUtility.updateTaxPayerRegistrationRevenueNSWStatus(osrRequestParameters.referenceId);
                
                return null;
            }
        }
    }
    
    /** return the relative uri path to the resource */
    public override String getResourcePath(){ return ''; }
    
    /** return the authentication strategy */
    protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() { return new P2POSRAuthenticationStrategy();
                                                                               }
    
    /** return the service locator */
    public override AWSC_ServiceLocator getServiceLocator() {
        if(this.serviceLocator == null) { this.serviceLocator = new P2POSR_SOAPServiceLocator(); }
        return this.serviceLocator;
    }
    
    /** return the service request builder, request builder - to be provided by specific resource implementation */
    protected virtual override AWSC_RequestBuilder getRequestBuilder() {
        return new P2POSRIndividualAuthorisationSOAPRequestBuilder(this);
    }
    
    /** return the service response parser response parser - to be provided by specific resource implementation */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POSRSOAPResponseParser(this);
    }
}