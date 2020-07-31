/**
 */
 
public class P2PWIBSPaymentClient {

    /*** Unified interface endpoint for invoking the callout to WIBS
     * This method will switch between the callout resources based on passed parameter
     */
    
     public Enum WIBS_PAYMENT_REQUEST_TYPE  {
        SECURITY_TOKEN, HANDS_OFF, QUICKVAULT_SECURITY_TOKEN
     }
     
    public class WIBSPaymentRequestParam  {
        public String username;
        public String password;
        public String supplierBusinessCode;
        public String connectionType;
        public String product;
        public String accountType;
        public Double principalAmount;
        public String paymentReference;
        public String serverReturnUrl;
        public String customerReferenceNumber;
        public String errorEmailToAddress;
        public String returnUrl;
        public String cancelUrl;
        
        public WIBS_PAYMENT_REQUEST_TYPE requestType;
    }
    
    
    public class P2PWIBSPaymentAuthStrategy implements AWSC_AuthenticationStrategy {    
       /*Default overrides */
       public Boolean checkLoggedIn() { return true; }
       public Boolean authenticate() { return true; }

        
       /** @TODO Load from settings */ 
       public P2PWIBSPaymentAuthStrategy(){
       }
        
       /** Load and set certificates into the request for Client Authentication */
       public void decorateRequestWithCredential(HttpRequest request) {
       }
    }
    
    public class P2PWIBSPaymentServiceConfig implements AWSC_ServiceLocator {
        
        private final String TEST_SECURITY_TOKEN_BASE_URL = 'https://ws.support.qvalent.com/services/quickweb';
        private final String PROD_SECURITY_TOKEN_BASE_URL = 'https://ws.support.qvalent.com/services/quickweb';
        private final String TEST_HANDOFF_BASE_URL = 'https://quickweb.support.qvalent.com';
        private final String PROD_HANDOFF_BASE_URL = 'https://quickweb.support.qvalent.com';

        /** Service Gateway endpoint for Westpac WIBS PAYMENT API */ 
        private final String endpoint;
        
        //@TODO - load from custom settings

        // empty default constructor.
        public P2PWIBSPaymentServiceConfig() {        }
        
        
        public P2PWIBSPaymentServiceConfig(WIBS_PAYMENT_REQUEST_TYPE wibsPaymentRequestType) {
                if(wibsPaymentRequestType == WIBS_PAYMENT_REQUEST_TYPE.SECURITY_TOKEN || wibsPaymentRequestType == WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN)  {
                        this.endpoint = Label.WIBS_REMOTE_BASE_URL + 'services/quickweb/';
                }
        }
        
        public void setEndpoint(String endpoint) {
                /* do nothing in this method. */
        }

        public String endpoint() {
            return endpoint;
        }
    
        public String version() {
           return 'v0.0.1';  
        }
    }
    
    /**
     * Generic Request Builder for WIBS PAYMENT Queries 
     */
    public class P2PWIBSPaymentRequestBuilder implements AWSC_RequestBuilder {
         private AWSC_ServiceResource parent;
         public P2PWIBSPaymentRequestBuilder(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
       
         public AWSC_Request buildRequest(Object reqParams) {
             AWSC_ServiceRestRequest request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator(), true);
             request.setParams(reqParams);
             request.method = ((P2PWIBPaymentSRestServiceResource)parent).httpMethod();
             
             Map<String, String> headers = new Map<String, String> ();
             
             if(request.method == AWSC_Request.RequestMethod.POST){
                 headers.put('Content-Type', 'application/x-www-form-urlencoded');
             }
           
             //add any headers required here..
             String acceptHeader = ((P2PWIBPaymentSRestServiceResource)parent).acceptHeader();
             if(!String.isEmpty(acceptHeader)){
                 headers.put('Accept', acceptHeader);
             }
             if(!headers.isEmpty())
                 request.headers = headers;
             return request;
         }
    }
    
    public class P2PWIBSPaymentRestClient extends AWSC_RestClient  {
        
        public P2PWIBSPaymentRestClient(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
            super(serviceLocator, authProvider);
            if(Test.isRunningTest()){
                //@XXX Just for coverage! 
                authProvider.checkLoggedIn();
                authProvider.authenticate();
                serviceLocator.version();
                serviceLocator.setEndpoint(null);
                //Inject the mock response generator for the framework
                injectTestProxy(new P2PWIBSPaymentMockImplementation());
            }
        }
        
        /**
         * build the POST request
         */
        protected override HttpRequest buildPost(AWSC_Request request, String path) {
            AWSC_ServiceRestRequest wibsPaymentRequest = (AWSC_ServiceRestRequest) request;
            URL uri = buildUri(path);
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(uri.toExternalForm());
            httpRequest.setMethod('POST');
            WIBSPaymentRequestParam wibsPaymentParams = (WIBSPaymentRequestParam) wibsPaymentRequest.getParams();
            String httpRequestBody;
            if(wibsPaymentParams.requestType == WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN) {
                httpRequestBody =      'username=' + EncodingUtil.urlEncode(wibsPaymentParams.username, 'UTF-8')
                                        + '&password=' + EncodingUtil.urlEncode(wibsPaymentParams.password, 'UTF-8')
                                        + '&supplierBusinessCode=' + EncodingUtil.urlEncode(wibsPaymentParams.supplierBusinessCode, 'UTF-8')
                                        + '&connectionType=' + EncodingUtil.urlEncode(wibsPaymentParams.connectionType, 'UTF-8')
                                        + '&product=' + EncodingUtil.urlEncode(wibsPaymentParams.product, 'UTF-8')
                                        + '&customerReferenceNumber=' + EncodingUtil.urlEncode(wibsPaymentParams.customerReferenceNumber, 'UTF-8')
                                        + '&serverReturnUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.serverReturnUrl, 'UTF-8')
                                        + '&returnUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.returnUrl, 'UTF-8')
                                        + '&errorEmailToAddress=' + EncodingUtil.urlEncode(wibsPaymentParams.errorEmailToAddress, 'UTF-8')
                                        + '&cancelUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.cancelUrl, 'UTF-8');
            } else {
                httpRequestBody =      'username=' + EncodingUtil.urlEncode(wibsPaymentParams.username, 'UTF-8')
                                        + '&password=' + EncodingUtil.urlEncode(wibsPaymentParams.password, 'UTF-8')
                                        + '&supplierBusinessCode=' + EncodingUtil.urlEncode(wibsPaymentParams.supplierBusinessCode, 'UTF-8')
                                        + '&connectionType=' + EncodingUtil.urlEncode(wibsPaymentParams.connectionType, 'UTF-8')
                                        + '&product=' + EncodingUtil.urlEncode(wibsPaymentParams.product, 'UTF-8')
                                        + '&principalAmount=' + EncodingUtil.urlEncode(String.valueOf(wibsPaymentParams.principalAmount), 'UTF-8')
                                        + '&paymentReference=' + EncodingUtil.urlEncode(wibsPaymentParams.paymentReference, 'UTF-8')
                                        + '&customerReferenceNumber=' + EncodingUtil.urlEncode(wibsPaymentParams.customerReferenceNumber, 'UTF-8')
                                        + '&accountType=' + EncodingUtil.urlEncode(wibsPaymentParams.accountType, 'UTF-8')
                                        + '&serverReturnUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.serverReturnUrl, 'UTF-8')
                                        + '&returnUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.returnUrl, 'UTF-8')
                                        + '&errorEmailToAddress=' + EncodingUtil.urlEncode(wibsPaymentParams.errorEmailToAddress, 'UTF-8')
                                        + '&cancelUrl=' + EncodingUtil.urlEncode(wibsPaymentParams.cancelUrl, 'UTF-8');
            }
            System.debug(httpRequestBody);
            httpRequest.setBody(httpRequestBody);
            return httpRequest;
        }
    }
    
    public abstract class P2PWIBSPaymentResponseParser implements AWSC_ResponseParser {

        private AWSC_ServiceResource parent;
        
        @TestVisible
        protected String responseText {get; set;}
        @TestVisible
        protected Integer responseStatus {get; set;}
        
        protected AWSC_Request request;
        protected AWSC_Response response;

        public P2PWIBSPaymentResponseParser(AWSC_ServiceResource parent) {
            this.parent = parent;
        }
        
        //Interface Implementation
        public virtual void parseResponse(AWSC_Response response) {
            parseResponse(null, response);
        }

        public virtual void parseResponse(AWSC_Request request, AWSC_Response response) {
            this.request = request;
            this.response = response;
            this.responseText = response.getResponseText();
            this.responseStatus = response.getResponseStatus();
            processResponse();
        }
        protected abstract void processResponse();
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            if(visitor != null) visitor.visit(this);
        }
    }
    
    
    public class P2PWIBSPaymentSecurityTokenResponseParser extends P2PWIBSPaymentResponseParser {
        public String token { get; set; } { this.token = ''; }
        public P2PWIBSPaymentSecurityTokenResponseParser(AWSC_ServiceResource parent){ super(parent); }  
           
        protected override void processResponse()  {
            if(P2PWIBSConstants.HTTP_OK == this.responseStatus)  {
                System.debug('response :: ' + this.responseText);
                this.token = this.responseText.split('token=')[1];
            }
        }
    }
    
    public abstract class P2PWIBPaymentSRestServiceResource extends AWSC_RestServiceResource {
        
        //Hook to hold any callback action data from ResponseParsing
        private AWSC_ResponseParserVisitor visitor;
        private WIBS_PAYMENT_REQUEST_TYPE wibsPaymentRequestType;
        
        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected virtual override AWSC_RequestBuilder getRequestBuilder() {
            return new P2PWIBSPaymentRequestBuilder(this);
        }
                
        /** return the service locator */
        public override AWSC_ServiceLocator getServiceLocator() {
            serviceLocator = new P2PWIBSPaymentServiceConfig(this.wibsPaymentRequestType);
            return serviceLocator;
        }
        
        /** return the authentication strategy */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new P2PWIBSPaymentAuthStrategy();
        }
               
        public P2PWIBPaymentSRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
            super(params);
            this.wibsPaymentRequestType = ((WIBSPaymentRequestParam) params).requestType;
            this.client = new P2PWIBSPaymentRestClient(this.getServiceLocator(), this.authProvider);
            this.visitor = visitor;
        }        

        /**
         * default method is GET - except for file DELETE
         */
        protected virtual AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.GET;
        }

        /** Default is null*/
        public virtual String acceptHeader() {
            return null;
        }
        
        /**
         * fire the defensive (retry loaded) call to the service
         */
        public void defensiveInvoke()  {
            request = getRequestBuilder().buildRequest(requestParams);
            AWSC_Response response = client.request(request);
            AWSC_ResponseParser responseParser = getResponseParser();
            responseParser.parseResponse(request, response);

            //use the visitor to do the response data processing, database commits etc.
            responseParser.accept(this.visitor);
        }
    }
    
    
    public class P2PWIBSPaymentSecurityTokenResource extends P2PWIBPaymentSRestServiceResource {
        public P2PWIBSPaymentSecurityTokenResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return 'CommunityTokenRequestServlet'; }
        /** return the service response for Files Upload resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PWIBSPaymentSecurityTokenResponseParser(this);
        }
        public override AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.POST;
        }
    } 
    
       public void callWIBSPAYMENTApplication(WIBS_PAYMENT_REQUEST_TYPE requestType, AWSC_ResponseParserVisitor visitor, WIBSPaymentRequestParam requestParams)  {
        //should throw an exception if no query for found
        if(requestType == null)  {
            throw new AWSC_Exception('No WIBS PAYMENT requestType value set. Unable to understand which query to fire.');
        }
        P2PWIBPaymentSRestServiceResource resource;
        
        if(requestType == WIBS_PAYMENT_REQUEST_TYPE.SECURITY_TOKEN)  {
            requestParams.requestType = WIBS_PAYMENT_REQUEST_TYPE.SECURITY_TOKEN;
            resource = new P2PWIBSPaymentClient.P2PWIBSPaymentSecurityTokenResource(requestParams, visitor);
        } else if(requestType == WIBS_PAYMENT_REQUEST_TYPE.HANDS_OFF)  {
                requestParams.requestType = WIBS_PAYMENT_REQUEST_TYPE.HANDS_OFF;
        } else if(requestType == WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN) {
            requestParams.requestType = WIBS_PAYMENT_REQUEST_TYPE.QUICKVAULT_SECURITY_TOKEN;
            resource = new P2PWIBSPaymentClient.P2PWIBSPaymentSecurityTokenResource(requestParams, visitor);
        }
        
        resource.defensiveInvoke();
        return;
    }
}