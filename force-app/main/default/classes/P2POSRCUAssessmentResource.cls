/**
* @name P2POSRCUAssessmentResource
* @usage this class represents OSR Assessment resource, this will take care of populating resource related
* attributes and calling approriate super methods, finally this resource will be called by client based on the request type.
* actual SOAP envelop will be created by requestBuilder of this resource.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRCUAssessmentResource extends P2POSRRPCServiceResource  {
    
    //constructors     
    public P2POSRCUAssessmentResource(Object parameters, AWSC_ResponseParserVisitor visitor) { super(parameters);
                                                                                              this.visitor = visitor;
                                                                                             }
    
    public  class P2POSRProviderAuthorisationSOAPRequest extends AWSC_RPCRequest {
        /** construct a new service SOAP request for the passed service resource */
        public P2POSRProviderAuthorisationSOAPRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
            super(serviceResource, serviceLocator, false);
        }
        
    }
    
    
    public class P2POSRProviderAuthorisationSOAPRequestBuilder extends P2POSRSOAPRequestBuilder {
        
        /*** create a request builder */
        public P2POSRProviderAuthorisationSOAPRequestBuilder(AWSC_ServiceResource parent) { this.parent = parent;
                                                                                          }
        
        
        public override AWSC_Request buildRequest(Object requestParameters) {
            
            P2POSRProviderAuthorisationSOAPRequest request = new P2POSRProviderAuthorisationSOAPRequest(this.parent, this.parent.getServiceLocator());
            request.method = AWSC_Request.RequestMethod.POST;
            P2POSRRequestParameter osrRequestParameters = (P2POSRRequestParameter) requestParameters;
            try{
                //fetch required params from the config
                if(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:createAssessmentRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:createAssessmentRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    
                    if(null != osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation.toXML('assessment').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation.toXML('assessment').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                } else if(P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_ASSESSMENT_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:updateAssessmentRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:updateAssessmentRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    
					if(null != osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation.toXML('assessment').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation.toXML('assessment').unescapeHtml4() + '</requestParameter>';
                    }
                    
                    this.requestBody += this.postFixRequestBodyTag + this.postFixXML();
                } else if(P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:getAssessmentRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">';
                    this.postFixRequestBodyTag = '</tns:getAssessmentRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag;
                    
                    if(null != osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForTspAuthorisation.toGetAssessmentXML().unescapeHtml4() + '</requestParameter>';
                    }
                    
                    if(null != osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation)  {
                        this.requestBody += '<requestParameter>' + osrRequestParameters.p2pOSRAssessments.assessmentForBspAuthorisation.toGetAssessmentXML().unescapeHtml4() + '</requestParameter>';
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
            } catch(Exception ex) {
                //Insert Application Log
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2POSRCUAssessmentResource', 'buildRequest', ex.getMessage(), JSON.serialize(osrRequestParameters), ex, null, 'Revenue NSW Request Generation Error', osrRequestParameters.referenceId, null);
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
        return new P2POSRProviderAuthorisationSOAPRequestBuilder(this);
    }
    
    /** return the service response parser response parser - to be provided by specific resource implementation */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POSRSOAPResponseParser(this);
    }
    
}