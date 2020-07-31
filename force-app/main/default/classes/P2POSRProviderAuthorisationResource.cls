/**
* @name P2POSRProviderAuthorisationResource
* @usage this class represents OSR Provider Authorisation resource, this will take care of populating resource related
* attribute and calling approriate super methods, finally this resource will be called by client based on the request type.
* actual SOAP envelop will be created by requestBuilder of this resource.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRProviderAuthorisationResource extends P2POSRRPCServiceResource  {
    
    //constructors     
    public P2POSRProviderAuthorisationResource(Object parameters, AWSC_ResponseParserVisitor visitor) { super(parameters);
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
            try {
                //fetch required params from the config
                if(P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:createProviderAuthorisationRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/"><requestParameter>';
                    this.postFixRequestBodyTag = '</requestParameter></tns:createProviderAuthorisationRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag
                        + osrRequestParameters.providerDetail.toXML('providerDetail').unescapeHtml4()
                        + osrRequestParameters.providerAuthorisations.toXML('authorisations').unescapeHtml4()
                        + this.postFixRequestBodyTag + this.postFixXML();
                } else if (P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST == osrRequestParameters.requestType)  {
                    this.preFixRequestBodyTag = '<tns:updateProviderRequest xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/"><requestParameter>';
                    this.postFixRequestBodyTag = '</requestParameter></tns:updateProviderRequest>';
                    this.requestBody = this.preFixXML() + this.preFixRequestBodyTag
                        + osrRequestParameters.providerDetail.toXML('providerDetail').unescapeHtml4()
                        + this.postFixRequestBodyTag + this.postFixXML();
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
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'P2POSRProviderAuthorisationResource', 'buildRequest', ex.getMessage(), JSON.serialize(osrRequestParameters), ex, null, 'Revenue NSW Request Generation Error', osrRequestParameters.referenceId, null);
                
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
        return new P2POSRProviderAuthorisationSOAPRequestBuilder(this);
    }
    
    /** return the service response parser response parser - to be provided by specific resource implementation */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POSRSOAPResponseParser(this);
    }
    
}