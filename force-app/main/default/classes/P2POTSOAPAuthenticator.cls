/**
 * OT Content Server ECMLink SOAP Service Client
 * 
 * OT ECM - SF Authentication Interaction Resource over SOAP
 * 
 * Uses OTSAPXECM Auth Service over SOAP 
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */
public class P2POTSOAPAuthenticator extends AWSC_RPCServiceResource
                                                 implements AWSC_AuthenticationStrategy {
	
    public class P2POTSOAP_ServiceLocator implements AWSC_ServiceLocator{
        
        /** endpoint - should be the FQDN without additional service path */
        private String endpoint = null;
        
        
        /**set the endpoint explicitly to override config values runtime */
        public void setEndpoint(String endpoint){
            this.endpoint = endpoint;
        }
        
        /*** provide the endpoint for the sample webservice client implementation */
        public String endpoint() {
            if(this.endpoint != null) {
                return endpoint;
            }
            //@TODO - move to config
            return 'https://hostb.dema1.com/otdsws/services/Authentication?wsdl';
        }
        
        /*** provide the service version - for backward compatibility checks */
        public String version(){
            return '1.0.0';
        }
    }                                                     
    /*
     * Auth Strategy class is used to provide the auth logic required 
     * by the OT service
     */
     
    /** Auth token */
    private String otcsticket;
    
    /** set the Auth token */
    public void setOtcsticket(String ticket) {
        //TODO: This should be set in the Platform/Session Cache with a TTL
        this.otcsticket = ticket;
    }
    
    /** get the Auth token */
    public String getOtcsticket(){
        
        //this should be picked from Platform/Session Cache with a TTL
        
         return this.otcsticket;
    }
    
/////////////////Methods from Service Resource
    /*** return the relative uri path to the resource */
    public override String getResourcePath(){
        //OT auth token path
        return '/auth';
    }
    
    /**
     * return the service request builder 
     * request builder - to be provided by specific resource implementation
     */
    protected override AWSC_RequestBuilder getRequestBuilder() {
        return new P2POTSOAP_AuthRequestBuilder(this);
    }
    
    /**
     * return the service response parser 
     * response parser - to be provided by specific resource implementation
     */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POTSOAP_AuthResponseParser(this);
    }
    
    /**
     * return the service locator
     */
    public override AWSC_ServiceLocator getServiceLocator() {
        if(serviceLocator == null) {
            serviceLocator = new P2POTSOAP_ServiceLocator();
        }
        return serviceLocator ;
    }
    
    /**
     * return the authentication strategy
     */
    protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
        return this;
    }

     
/////////////////Methods from Authentication Strategy
     /**
      * authenticate using strategy
      */
     public Boolean authenticate() {
         //for the auth provider, the auth call is the same as a request invocation
         if(!checkLoggedIn()) { 
             invoke();
         }
         return checkLoggedIn();
     }
     
     /**
      * return whether logged in
      */
     public Boolean checkLoggedIn() {
         //unsafe - fix for long running calls?, expired tokens etc
         //TODO: check Platform/Session Cache for token TTL
         return (otcsticket != null);
     }
     
     /**
      * add the token to the request params block
      */
     public void decorateRequestWithCredential(System.HttpRequest request) {
         //Set the OTCSTicket into the AuthHeader
         String reqBody = request.getBody();
         reqBody = reqBody.replace('{OTCSTICKET_TOKEN}', this.otcsticket);
         request.setBody(reqBody);
     }
     
     /**
      * Constructor:  create an authentication resource
      */
     public P2POTSOAPAuthenticator() {
         super();
     }
                                                     
     public void debugEndpoint(){
        System.debug(serviceLocator.endpoint());                                                    
     }
	
	 //Set isAuthRequest to TRUE for this request
     public  class P2POTSOAPAuthRequest extends AWSC_RPCRequest {
        
        /**
        * construct a new service rest request for the passed service resource
        */
        public P2POTSOAPAuthRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
            super(serviceResource, serviceLocator, true);
        }
        
        /**
        * construct a new service rest request for the passed service resource
        */
        public P2POTSOAPAuthRequest(AWSC_ServiceResource serviceResource, 
                                  AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest) {
                                      super(serviceResource, serviceLocator, true);
                                  } 
        
        /**
        * TODO: fix more elegantly to reuse request/response paradigm for auth
        * requests also
        */
        public P2POTSOAPAuthRequest(AWSC_ServiceResource serviceResource, 
                                  AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest, AWSC_Request.RequestMethod requestMethod) {
                                      super(serviceResource, serviceLocator, true, requestMethod);
                                  } 
    }   
                                                     
     /**
      * Auth Request Builder class
      */
     public class P2POTSOAP_AuthRequestBuilder implements AWSC_RequestBuilder {
     
        /** handle to outer class for instance variables */
        private AWSC_ServiceResource parent;
        
        /*** create a request builder for auth*/
        public P2POTSOAP_AuthRequestBuilder(AWSC_ServiceResource parent) {
            this.parent = parent;
        }
        
        
        public AWSC_Request buildRequest(Object reqParams) {
            //fetch required params from the config
            P2POTSOAPAuthRequest request = new P2POTSOAPAuthRequest(parent, parent.getServiceLocator());
            request.method = AWSC_Request.RequestMethod.POST;
            String username, password;
                        
            String reqBody =
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:api.ecm.opentext.com" xmlns:urn1="urn:authws.services.ecm.opentext.com">'
+ '    <soapenv:Header>'
+ '    </soapenv:Header>'
+ '    <soapenv:Body>'
+ '       <urn1:Authenticate>'
+ '          <username>{OT_USERNAME}</username>'
+ '          <password>{OT_PASSWORD}</password>'
+ '       </urn1:Authenticate>'
+ '    </soapenv:Body>'
+ ' </soapenv:Envelope>';
            reqBody = reqBody.replace('{OT_USERNAME}', 'API_admin');
            reqBody = reqBody.replace('{OT_PASSWORD}', 'Ap!adm1n');
            request.setXMLBody(reqBody);
            
            request.contentType = 'text/xml';
            //TODO any other headers here...
            
            return request;
        }
     } 
     
     /**
      * Auth response parser
      */
     public class P2POTSOAP_AuthResponseParser implements AWSC_ResponseParser {
     
        /** handle to outer class for instance variables */
         private P2POTSOAPAuthenticator parent;
      
         /**
          * create a response parser for auth
          */
         public P2POTSOAP_AuthResponseParser(P2POTSOAPAuthenticator parent) {
             this.parent = parent;
         }
         
         
         /**
          * parse the response to validate authentication, get token etc
          */
         public void parseResponse(AWSC_Response response) {
             parseResponse(null, response);
         }

         
         /**
          * parse the response to validate authentication, get token etc
          */
         public void parseResponse(AWSC_Request request, AWSC_Response response) {
         
             //XXX - unsafe  - check for error codes, status etc
             String responseText = response.getResponseText();
             System.debug('Response Body = ' + responseText);

             //update the auth strategy with the access token
             //this.parent.setOtcsticket(ticket); 
             Dom.Document domDoc = new Dom.Document();
             domDoc.load(responseText);
             String token = extractAuthToken(domDoc.getRootElement());
                          
             System.debug('Logged in Token = ' + token);
             this.parent.otcsticket = token;
             
         }
         
        public String extractAuthToken(Dom.XMLNode fromNode) {
            
            if (fromNode.getName().equalsIgnoreCase('AuthenticationToken')) {
            	System.debug('Found Token');
                return fromNode.getText(); 
            }
        
	        for (Dom.XmlNode child: fromNode.getChildElements()) {
	            if (child.getName().equalsIgnoreCase('AuthenticationToken')) {
	               return child.getText();
	            } else if(! child.getChildElements().isEmpty()){
	                return extractAuthToken(child);
	            }
	        } 
            return null;
        }
         
         
         public void accept(AWSC_ResponseParserVisitor visitor){
             //do nothing
         }
     }
 }