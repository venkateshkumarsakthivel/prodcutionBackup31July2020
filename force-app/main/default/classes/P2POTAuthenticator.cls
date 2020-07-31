/**
 * Content Server REST Service Client
 * This provides OTCS Ticket for use with REST service
 * 
 * NOTE IMPORTANT: This DOES NOT provide creds to use with the ECMLink SOAP Service
 *  
 * OT Authenticator for P2P
 * Login with creds to procure a OTCSTICKET
 * this ticket will be used in subsequent REST calls to the content server API
 * 
 * @TODO: Update to use custom settings/metadata for creds/endpoint
 * @TODO: Remove insecure debug logs
 * Uses Arxxus Webservice Client Framework
 * @author raghu
 */
public class P2POTAuthenticator extends AWSC_RestServiceResource
                                                 implements AWSC_AuthenticationStrategy {
	
    public class P2POT_ServiceLocator implements AWSC_ServiceLocator{
        
        /** endpoint - should be the FQDN without additional service path */
        private String endpoint = null;
        
        
        /**
         * set the endpoint explicitly to override config values runtime
         */
        public void setEndpoint(String endpoint){
            this.endpoint = endpoint;
        }
        
        /**
         * provide the endpoint for the sample webservice client implementation
         */
        public String endpoint() {
        
            if(this.endpoint != null) {
                return endpoint;
            }
            /*
            P2POT_Config__c config;
            if(Test.isRunningTest()) {
                config = new P2POT_Config__c();
                config.endpoint__c = 'https://www.arxxus.com.au';
            } else {
                
                config = P2POT_Config__c.getInstance(UserInfo.getProfileId());
                System.debug('------ endpoint ----' + config.endpoint__c);
                if(config == null) {
                    throw new AWSC_MissingConfigurationException('No configuration available for P2POT');   
                }
            }
            
            return config.endpoint__c;
			*/
            
            //@TODO
            return 'https://p2p.dema1.com/otcs/cs.exe/api/v1';
        }
        
        /**
         * provide the service version - for backward compatibility checks
         */
        public String version(){
            return '1.0.0';
        }
    }                                                     
    /*
     * Auth Strategy class is used to provide the auth logic required 
     * by the OT service
     */
     
    /** OAuth access token */
    private String otcsticket;
    
    /**
     * set the OAuth access token
     */
    public void setOtcsticket(String ticket) {
        this.otcsticket = ticket;
    }
    
    public String getOtcsticket(){
         return this.otcsticket;
    }
    
     //Methods from Service Resource
    /**
     * return the relative uri path to the resource
     */
    public override String getResourcePath(){
        //OT auth token path
        return '/auth';
    }
    
    /**
     * return the service request builder 
     * request builder - to be provided by specific resource implementation
     */
    protected override AWSC_RequestBuilder getRequestBuilder() {
        return new P2POT_AuthRestRequestBuilder(this);
    }
    
    /**
     * return the service response parser 
     * response parser - to be provided by specific resource implementation
     */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POT_AuthRestResponseParser(this);
    }
    
    /**
     * return the service locator
     */
    public override AWSC_ServiceLocator getServiceLocator() {
        if(serviceLocator == null) {
            serviceLocator = new P2POT_ServiceLocator();
        }
        return serviceLocator ;
    }
    
    /**
     * return the authentication strategy
     */
    protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
        return this;
    }

     
     
     //Methods from Authentication Strategy
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
         if(Test.isRunningTest()) otcsticket = 'vy6J+JVb37GyOWi94q992nt/8Fg9xSxc4KeizlgVPPM4Hk1duU9dQvVx2SFR5PXh5KNZMLWlrFJ5P/5ypxRjR004yT40SFku';
         return (otcsticket != null);
     }
     
     /**
      * add the token to the request params block
      */
     public void decorateRequestWithCredential(System.HttpRequest request) {
         request.setHeader('OTCSTICKET', otcsticket);
     }
     
     /**
      * Constructor
      * create an authentication resource
      */
     public P2POTAuthenticator() {
         super();
     }
                                                     
     public void debugEndpoint(){
        System.debug(serviceLocator.endpoint());                                                    
     }
     
     /**
      * Auth Request Builder class
      */
     public class P2POT_AuthRestRequestBuilder implements AWSC_RequestBuilder {
     
         /** handle to outer class for instance variables */
         private P2POTAuthenticator parent;
         
         /**
          * create a request builder for auth
          */
         public P2POT_AuthRestRequestBuilder(P2POTAuthenticator parent) {
             this.parent = parent;
         }
         
         
         public AWSC_Request buildRequest(Object reqParams) {

             //TODO fetch required params from the config
             
             //P2POT_Config__c config = P2POT_Config__c.getInstance(UserInfo.getProfileId());
             //if(config == null) {
             //    throw new AWSC_MissingConfigurationException('No configuration available for OT Integration');   
             //}
             
             Map<String, String> params = new Map<String, String>();
             //params.put('username', config.ot_username__c);
             //params.put('password', config.ot_password__c);
             params.put('username', 'API_admin');
             params.put('password', 'Ap!adm1n');
             
             AWSC_ServiceRestRequest request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator(), true);
             request.method = AWSC_Request.RequestMethod.POST;
             request.setParams(params);
             request.isAuthRequest = true;
             
             request.contentType = 'application/x-www-form-urlencoded';
             System.debug('Request - ' + request);
             
             return request;
         }
         
     } 
     
     /**
      * Auth response parser
      */
     public class P2POT_AuthRestResponseParser implements AWSC_ResponseParser {
     
        /** handle to outer class for instance variables */
         private P2POTAuthenticator parent;
      
         /**
          * create a response parser for auth
          */
         public P2POT_AuthRestResponseParser(P2POTAuthenticator parent) {
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
             Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(responseText);
             String ticket = (String) m.get('ticket');
             
             System.debug('OTCSTICKET = ' + ticket);

             //update the auth strategy with the access token
             this.parent.setOtcsticket(ticket); 
             
             System.debug('Logged in = ' + this.parent.checkLoggedIn());
             
         }
         
         public void accept(AWSC_ResponseParserVisitor visitor){
             //do nothing
         }
     }
 }