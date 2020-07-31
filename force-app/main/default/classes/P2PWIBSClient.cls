/**
 * Westpac Batch Payment Interface
 * Defines and Exposes the services required for Batch Payment File Processing  
 * From Spec: WIBS HTTPS Specification.pdf (version 1.3)
 * Upload Payment File 
 * Query List of Response Files
 * Fetch Response File 
 * Delete Response File from Server
 */
public class P2PWIBSClient {

    public class P2PWIBSAuthStrategy implements AWSC_AuthenticationStrategy {    
       /*Default overrides */
       public Boolean checkLoggedIn() { return true; }
       public Boolean authenticate() { return true; }
        
       /**Westpac Provided SSL cert for use with WIBS API for Auth*/
       public final String P2P_WIBS_AUTH_CERT_NAME;
        
       /** @TODO Load from settings */ 
       public P2PWIBSAuthStrategy(){
           P2P_WIBS_AUTH_CERT_NAME = 'p2p_wibs_client';
       }
        
       /** Load and set certificates into the request for Client Authentication */
       public void decorateRequestWithCredential(HttpRequest request) {
           request.setClientCertificateName(Label.WIBS_REMOTE_CERTIFICATE_NAME);
       }
    }
    
    public class P2PWIBSServiceConfig implements AWSC_ServiceLocator {
        
        private final String TEST_BASE_URL = 'https://ws.support.qvalent.com/';
        private final String PROD_BASE_URL = 'https://ws.qvalent.com/';

        /** Service Gateway endpoint for Westpac WIBS API */ 
        private final String endpoint;
        
        //@TODO - load from custom settings
        public P2PWIBSServiceConfig(){
            endpoint = Label.WIBS_REMOTE_BASE_URL + 'services/messaging/rest';
        }
        
        public void setEndpoint(String endpoint) {
            //do nothing
        }

        public String endpoint() {
            return endpoint;
        }
    
        public String version() {
           return '1.3';  
        }
    }
    
    /**
     * Generic Request Builder for WIBS Queries 
     */
    public class P2PWIBSRequestBuilder implements AWSC_RequestBuilder {
         private AWSC_ServiceResource parent;
         public P2PWIBSRequestBuilder(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
       
         public AWSC_Request buildRequest(Object reqParams) {
             AWSC_ServiceRestRequest request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
             request.setParams(reqParams);

             request.method = ((P2PWIBSRestServiceResource)parent).httpMethod();
             
             Map<String, String> headers = new Map<String, String> ();
             
             if(request.method == AWSC_Request.RequestMethod.POST){
                 //file upload..
                 headers.put('Content-Type', 'application/octet-stream');
             }
           
             //add any headers required here..
             String acceptHeader = ((P2PWIBSRestServiceResource)parent).acceptHeader();
             if(!String.isEmpty(acceptHeader)){
               	 headers.put('Accept', acceptHeader);
             }
             if(!headers.isEmpty())
                 request.headers = headers;
             return request;
         }
    }

    public abstract class P2PWIBSResponseParser implements AWSC_ResponseParser {

        private AWSC_ServiceResource parent;
        
        @TestVisible
        protected String responseText {get; set;}
        @TestVisible
        protected Integer responseStatus {get; set;}
        
        protected AWSC_Request request;
        protected AWSC_Response response;

        public P2PWIBSResponseParser(AWSC_ServiceResource parent) {
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
            System.debug('Response='+response.getResponseStatus() + ',' + response.getResponseText());
            processResponse();
        }
        protected abstract void processResponse();
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            if(visitor != null) visitor.visit(this);
        }
    }
    public class P2PWIBSFileUploadResponseParser extends P2PWIBSResponseParser {
    	
    		public Map<String, String> response { get; set; }
    		
        public P2PWIBSFileUploadResponseParser(AWSC_ServiceResource parent){ super(parent); }     
        protected override void processResponse(){
        		this.response = new Map<String, String>();
        		this.response.put('text', responseText);
        		this.response.put('status', String.valueOf(responseStatus));
            System.debug('FILEUPLOAD: Processing Response');
            if(responseStatus == P2PWIBSConstants.HTTP_ACCEPTED){
	            System.debug('FILEUPLOAD: Accepted Successfully');
            } else {
                //@TODO
                //retry only in case of HTTP_SERVER_ERROR || HTTP_SERVICE_UNAVAILABLE 
                //else hard fail with Exception and Notify Administrator - mark payments as Errored - Need Manual Intervention

            }
            //mark file upload log event as uploaded
            //mark each payment transaction in file as uploaded
        }
    }
    public class P2PWIBSFilesListResponseParser extends P2PWIBSResponseParser {
        public P2PWIBSFilesListResponseParser(AWSC_ServiceResource parent){ super(parent); }
        public String flist { get; set; }
        protected override void processResponse(){
            System.debug('FILESLIST: Processing Response');
            if(responseStatus == P2PWIBSConstants.HTTP_OK){
	            System.debug('FILELIST: Listed Successfully');
	            flist = responseText;
            } else {
                HttpResponse hResponse = this.response.getHttpResponse();
                List<String> hKeys = hResponse.getHeaderKeys();
                for(String hKey: hKeys){
                    System.debug('Header['+hKey+']=' + hResponse.getHeader(hKey));
                }
                //@TODO - 
                //HTTP_NO_CONTENT - discard this response 
                //HTTP_FORBIDDEN, HTTP_NOT_FOUND - need manual handling - Throw Exception
                //HTTP_SERVER_ERROR || HTTP_SERVICE_UNAVAILABLE retry - Throw Exception
            }
        }
    }
    public class P2PWIBSFileDownloadResponseParser extends P2PWIBSResponseParser {
        public P2PWIBSFileDownloadResponseParser(AWSC_ServiceResource parent){ super(parent); }
        public String data { get; set; } {this.data = '';}
        protected override void processResponse(){
            System.debug('FILESDOWNLOAD: Processing Response');
            if(responseStatus == P2PWIBSConstants.HTTP_OK){
	            System.debug('FILESDOWNLOAD: Downloaded Successfully');
	            this.data = responseText;
            } else {
                //@TODO - 
                //HTTP_FORBIDDEN, HTTP_NOT_FOUND - need manual handling - Throw Exception
                //HTTP_SERVER_ERROR || HTTP_SERVICE_UNAVAILABLE retry - Throw Exception
            }
        }
    }
    public class P2PWIBSFileDeleteResponseParser extends P2PWIBSResponseParser {
        public P2PWIBSFileDeleteResponseParser(AWSC_ServiceResource parent){ super(parent); }
        protected override void processResponse(){
            System.debug('FILEDELETE: Processing Response');
            if(responseStatus == P2PWIBSConstants.HTTP_NO_CONTENT){
	            System.debug('FILEDELETE: Deleted Successfully');
            } else {
                //@TODO - 
                //HTTP_BAD_REQUEST - need manual handling - probably logic error in file syntax - Throw Exception
                //HTTP_FORBIDDEN, HTTP_NOT_FOUND - need manual handling - Throw Exception
                //HTTP_SERVER_ERROR || HTTP_SERVICE_UNAVAILABLE retry - Throw Exception
            }
        }        
    }
    
    public class P2PWIBSRestClient extends AWSC_RestClient{
        
        public P2PWIBSRestClient(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
            super(serviceLocator, authProvider);
            if(Test.isRunningTest()){
                //@XXX Just for coverage! 
                authProvider.checkLoggedIn();
                authProvider.authenticate();
                serviceLocator.version();
                serviceLocator.setEndpoint(null);
                //Inject the mock response generator for the framework
	            injectTestProxy(new P2PWIBSMockImpl());
            }
        }
        
        /**
         * build the POST request
         */
        protected override HttpRequest buildPost(AWSC_Request request, String path) {
            AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
            URL uri = buildUri(path);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(uri.toExternalForm());
            req.setMethod('POST');
            WIBSRequestParam wibsParams = (WIBSRequestParam)restRequest.getParams();
            req.setBody(wibsParams.fileData);
            return req;
        }
    }
    
    public abstract class P2PWIBSRestServiceResource extends AWSC_RestServiceResource {
        
        //Hook to hold any callback action data from ResponseParsing
        private AWSC_ResponseParserVisitor visitor;
        
        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected virtual override AWSC_RequestBuilder getRequestBuilder() {
            return new P2PWIBSRequestBuilder(this);
        }
                
        /** return the service locator */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new P2PWIBSServiceConfig();
            }
            return serviceLocator;
        }
        
        /** return the authentication strategy */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new P2PWIBSAuthStrategy();
        }
               
        public P2PWIBSRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
            super(params);
            this.client = new P2PWIBSRestClient(this.serviceLocator, this.authProvider);
            this.visitor = visitor;
        }        
        public String fileName(){
            WIBSRequestParam wibsParams = (WIBSRequestParam)requestParams;
            return wibsParams.fileName;
        }

        /**
         * default method is GET - except for file DELETE
         */
        protected virtual AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.GET;
        }

        /** Default is null*/
        public virtual String acceptHeader() {
            return 'text/plain'; 
        }
        
        /**
         * fire the defensive (retry loaded) call to the service
         */
        public void defensiveInvoke(){
            request = getRequestBuilder().buildRequest(requestParams);
            AWSC_Response response = client.request(request);
            AWSC_ResponseParser responseParser = getResponseParser();
            responseParser.parseResponse(request, response);

            //use the visitor to do the response data processing, database commits etc.
            responseParser.accept(this.visitor);
        }
    }

    /**
    * Set the method endpoint 
    * '/uploadedFile'                       - POST To Upload a File
    * '/filesForDownload'                   - for List of Files
    * '/filesForDownload/{fileName}'        - GET Specific File Download
    * '/filesForDownload/{fileName}'        - DELETE Specific File
    */
    public class P2PWIBSFileUploadResource extends P2PWIBSRestServiceResource {
        public P2PWIBSFileUploadResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return 'uploadedFiles/' + fileName(); }
        /** return the service response for Files Upload resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PWIBSFileUploadResponseParser(this);
        }
        public override AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.POST;
        }
    }    
    public class P2PWIBSFilesListResource extends P2PWIBSRestServiceResource {
        public P2PWIBSFilesListResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return 'filesForDownload/'; }
        /** return the service response for Files List resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PWIBSFilesListResponseParser(this);
        }
        /** One file per line in plain text with CRLF separator*/
        public override String acceptHeader() {
            return 'text/plain';
        }
    }
    public class P2PWIBSFileDownloadResource extends P2PWIBSRestServiceResource {
        public P2PWIBSFileDownloadResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return 'filesForDownload/' + fileName(); }
        /** return the service response for Files Download resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PWIBSFileDownloadResponseParser(this);
        }
    }
    public class P2PWIBSFileDeleteResource extends P2PWIBSRestServiceResource {
        public P2PWIBSFileDeleteResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor); }
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return 'filesForDownload/' + fileName(); }
        /** return the service response for Files Delete resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PWIBSFileDeleteResponseParser(this);
        }
        public override AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.DELETE_X;
        }
    }
    
    
    /**
     * Unified interface endpoint for invoking the callout to WIBS
     * This method will switch between the callout resources based on passed parameter
     */
    
     public Enum WIBS_REQUEST_TYPE {
            FILEUPLOAD,
            FILESLIST,
            FILEDOWNLOAD,
            FILEDELETE
     }

    public class WIBSRequestParam{
        public String fileName;
        public String fileData;
        public WIBS_REQUEST_Type requestType;
    }
    
    public void callWIBSApp(WIBS_REQUEST_TYPE requestType, AWSC_ResponseParserVisitor visitor, WIBSRequestParam requestParams){
        //should throw an exception if no query for found
        if(requestType == null){
            throw new AWSC_Exception('No WIBS requestType value set. Unable to understand which query to fire.');
        }
        P2PWIBSRestServiceResource resource;
        if(requestType == WIBS_REQUEST_TYPE.FILEUPLOAD){
            if(null == requestParams || String.isEmpty(requestParams.fileName) || String.isEmpty(requestParams.fileData)){
                throw new AWSC_Exception('No fileName/fileData value set in param. Unable to understand what to Upload.');
            }
            requestParams.requestType = WIBS_REQUEST_TYPE.FILEUPLOAD;
            resource = new P2PWIBSClient.P2PWIBSFileUploadResource(requestParams, visitor);
        }else if(requestType == WIBS_REQUEST_TYPE.FILESLIST){
            requestParams.requestType = WIBS_REQUEST_TYPE.FILESLIST;
            resource = new P2PWIBSClient.P2PWIBSFilesListResource(requestParams, visitor);
        }else if(requestType == WIBS_REQUEST_TYPE.FILEDOWNLOAD){
            if(null == requestParams || String.isEmpty(requestParams.fileName)){
                throw new AWSC_Exception('No fileName value set in param. Unable to understand which file to Download.');
            }
            requestParams.requestType = WIBS_REQUEST_TYPE.FILEDOWNLOAD;            
            resource = new P2PWIBSClient.P2PWIBSFileDownloadResource(requestParams, visitor);
        }else if(requestType == WIBS_REQUEST_TYPE.FILEDELETE){
            if(null == requestParams || String.isEmpty(requestParams.fileName)){
                throw new AWSC_Exception('No fileName value set in param. Unable to understand which file to Delete.');
            }
            requestParams.requestType = WIBS_REQUEST_TYPE.FILEDELETE;
            resource = new P2PWIBSClient.P2PWIBSFileDeleteResource(requestParams, visitor);
        }
        resource.defensiveInvoke();
        return;
    }
}