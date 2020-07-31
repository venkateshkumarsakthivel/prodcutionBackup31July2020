/**
 * Content Server REST Service Client
 * 
 * Should Use OTCSTICKET provided by P2POTAuthenticator (REST Client)
 * 
 * P2P to Opentext API Client Interface
 * Defines and Exposes the services required for File/Document Processing  
 * Create File at Node
 * Query List of Files at Node
 * Fetch Node Data (File) 
 */
public class P2POTAppClient {
    
    public class P2POTServiceConfig implements AWSC_ServiceLocator {
        
        private final String TEST_BASE_URL = 'https://p2p.dema1.com/';
        private final String PROD_BASE_URL = 'https://p2p.dema1.com/';

        /** Service Gateway endpoint for P2P OT API */ 
        private final String endpoint;
        
        //@TODO - load from custom settings
        public P2POTServiceConfig(){
            endpoint = TEST_BASE_URL + 'otcs/cs.exe/api/' + version();
        }
        
        public void setEndpoint(String endpoint) {
            //do nothing
        }

        public String endpoint() {
            return endpoint;
        }
    
        public String version() {
           return 'v2';
        }
    }
    
    /**
     * Generic Request Builder for OT Queries 
     */
    public class P2POTRequestBuilder implements AWSC_RequestBuilder {
         private AWSC_ServiceResource parent;
         public P2POTRequestBuilder(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
       
         public AWSC_Request buildRequest(Object reqParams) {
             AWSC_ServiceRestRequest request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
             request.setParams(reqParams);

             request.method = ((P2POTRestServiceResource)parent).httpMethod();
             //add any headers required here..
             String acceptHeader = ((P2POTRestServiceResource)parent).acceptHeader();
             if(!String.isEmpty(acceptHeader)){
                 Map<String, String> headers = new Map<String, String> ();
               	 headers.put('Accept', acceptHeader);
                 request.headers = headers;
             }
             return request;
         }
    }

    public abstract class P2POTResponseParser implements AWSC_ResponseParser {

        private AWSC_ServiceResource parent;
        
        @TestVisible
        protected String responseText {get; set;}
        
        protected Blob responseBlob {get; set;}
        
        @TestVisible
        protected Integer responseStatus {get; set;}
        
        protected AWSC_Request request;
        protected AWSC_Response response;

        public P2POTResponseParser(AWSC_ServiceResource parent) {
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
            this.responseBlob = response.getResponseBlob();
            this.responseStatus = response.getResponseStatus();
            processResponse();
        }
        protected abstract void processResponse();
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            if(visitor != null) visitor.visit(this);
        }
    }
    public class P2POTCreateNodeResponseParser extends P2POTResponseParser {
    		public Boolean success {get; set;}
        public P2POTCreateNodeResponseParser(AWSC_ServiceResource parent){ super(parent); }     
        protected override void processResponse(){
            System.debug('CREATENODE: Processing Response');
            if(responseStatus == P2POTConstants.HTTP_ACCEPTED || responseStatus == P2POTConstants.HTTP_OK){
	            System.debug('FILEUPLOAD: Accepted ' + responseText);
	            success = true;
            } else {
                System.debug('FILEUPLOAD: ERROR Failed ' + responseStatus + ' :: ' + responseText);
                success = false;
            }
        }
    }
    public class P2POTBrowseNodeResponseParser extends P2POTResponseParser {
    	
        public P2POTBrowseNodeResponseParser(AWSC_ServiceResource parent){ super(parent); }
        public List<OTNode> otNodes {get;set;}
        protected override void processResponse(){
        	otNodes = new List<OTNode>();
            System.debug('BROWSENODE: Processing Response');
            if(responseStatus == P2POTConstants.HTTP_OK){
	            System.debug('BROWSENODE: Listed Successfully');
	            System.debug(this.responseText);
                Map<String, Object> response =   (Map<String, Object>) JSON.deserializeUntyped(this.responseText);
                List<Object> results = (List<Object>) response.get('results');
                for(Object o : results){
                    Map<String, Object> data = (Map<String, Object>) o;
                    Map<String, Object> node = (Map<String, Object>) data.get('data');
                    Map<String, Object> properties = (Map<String, Object>) node.get('properties');
                    Boolean container = (Boolean) properties.get('container');
                    otNodes.add(new OTNode((String) properties.get('name'), (Integer) properties.get('id'), (Boolean) properties.get('container'), (String) properties.get('mime_type'), (Integer) properties.get('size')));
                    System.debug('NODE = '
                                 + 'name=' + properties.get('name') + ', ' 
                                 + ', id=' + properties.get('id')
                                 + ', isContainer=' + properties.get('container') 
                                 + ', mimetype=' + properties.get('mime_type') 
                                 + ', size=' + properties.get('size'));
                }
            } else {
                System.debug('BROWSENODE: ERROR Failed ' + responseStatus);
            }
        }
    }
    
    public class P2POTNodeContentResponseParser extends P2POTResponseParser {
        public P2POTNodeContentResponseParser(AWSC_ServiceResource parent){ super(parent); }
        protected override void processResponse(){
            System.debug('NODECONTENT: Processing Response');
            if(responseStatus == P2POTConstants.HTTP_OK){
	            System.debug('NODECONTENT: Downloaded Successfully:' + this.responseBlob);
                System.debug('CHECK IF BLOB exists: ' + (this.responseBlob != null));
            } else {
                System.debug('NODECONTENT: ERROR Failed ' + responseStatus);
            }
        }
    }
    
    public class P2POTRestClient extends AWSC_RestClient{
        
        public P2POTRestClient(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
            super(serviceLocator, authProvider);
            if(Test.isRunningTest()){
            		authProvider = (P2POTAuthenticator) authProvider;
                //@XXX Just for coverage! 
                authProvider.checkLoggedIn();
                authProvider.authenticate();
                serviceLocator.version();
                serviceLocator.setEndpoint(null);
                //Inject the mock response generator for the framework
	            injectTestProxy(new P2POTMockImpl());
            }
        }

        /**
         * build the POST request
         */
        protected override HttpRequest buildPost(AWSC_Request request, String path) {
            AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
            System.debug('path :: ' + path);
            URL uri = buildUri(path);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(uri.toExternalForm());
            req.setMethod('POST');
            P2POTRequestParam otParams = (P2POTRequestParam)restRequest.getParams();

            //@TODO - check
            //buildMultiPartBody created with formPart and filePart with boundry and footer
            
			req.setBodyAsBlob(otParams.buildMultiPartBody());
			
			// request headers created with Content-Type and Content-Length.
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + otParams.boundry);
			req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));

            return req;
        }
    }
    
    public abstract class P2POTRestServiceResource extends AWSC_RestServiceResource {
        
        //Hook to hold any callback action data from ResponseParsing
        private AWSC_ResponseParserVisitor visitor;
        
        private P2POTAuthenticator authenticator;
        
        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected virtual override AWSC_RequestBuilder getRequestBuilder() {
            return new P2POTRequestBuilder(this);
        }
                
        /** return the service locator */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new P2POTServiceConfig();
            }
            return serviceLocator;
        }
        
        /** return the authentication strategy */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            if(null == authenticator)
                authenticator = new P2POTAuthenticator();
                
            return authenticator;
        }
               
        public P2POTRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
            super(params);
            this.client = new P2POTRestClient(this.serviceLocator, this.authProvider);
            this.visitor = visitor;
        }        
        public String nodeName(){
            P2POTRequestParam otParams = (P2POTRequestParam)requestParams;
            return otParams.nodeName;
        }

        /**
         * default method is GET
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
            
            getAuthenticationStrategy().authenticate();
            
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
    * '/nodes/'                             - POST To Upload a File
    * '/nodes/{id}/nodes'                   - GET - Browser List of Files/Folders/Nodes
    * '/nodes/{id}'                         - GET Specific File Download
    */
    public class P2POTCreateNodeResource extends P2POTRestServiceResource {
        public P2POTCreateNodeResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return '/nodes/'; }
        /** return the service response for Files Upload resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2POTCreateNodeResponseParser(this);
        }
        public override AWSC_Request.RequestMethod httpMethod(){
            return AWSC_Request.RequestMethod.POST;
        }
    }    
    public class P2POTBrowseNodeResource extends P2POTRestServiceResource {
        public P2POTBrowseNodeResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return '/nodes/' + nodeName() + '/nodes/'; }
        /** return the service response for Files List resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2POTBrowseNodeResponseParser(this);
        }
        /** One file per line in plain text with CRLF separator*/
        public override String acceptHeader() {
            return 'text/plain'; 
        }
    }
    public class P2POTNodeContentResource extends P2POTRestServiceResource {
        public P2POTNodeContentResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return '/nodes/' + nodeName() + '/content?action=open'; }
        /** return the service response for Files Download resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2POTNodeContentResponseParser(this);
        }
    }
    
    /**
     * Unified interface endpoint for invoking the callout to OT
     * This method will switch between the callout resources based on passed parameter
     */
    
     public Enum OT_REQUEST_TYPE {
            CREATENODE,
            NODECONTENT,
            BROWSENODE
     }

    public class P2POTRequestParam{
    		public String ctype;
        public String nodeName; //parent id in case of upload
        public Blob fileBlob;
        public String fileData;
        public String fileName;
        public String boundry;
        public OT_REQUEST_Type requestType;
        public Integer fileType = P2POTConstants.NODE_FILE_TYPE; //FileType (as opposed to Folder Type)

        public Blob buildMultiPartBody(){
        	
        		Blob contents = null;
        		
            boundry = '----ArxxusFormBoundary' + EncodingUtil.convertToHex(crypto.generateAesKey(256)).substring(0, 16);
            String footer = '--' + boundry + '--';
            
            /* form header and contents */
            String formh = '--' + boundry + '\r\nContent-Disposition: form-data; name="body"';
            String formhe = EncodingUtil.base64Encode(Blob.valueOf(formh + '\r\n\r\n'));
            
			String formb = '{"name":"' + fileName + '", "type":' + Integer.valueOf(fileType) + ', "parent_id":' + Integer.valueOf(nodeName) + '}\r\n';			
			String formbe = EncodingUtil.base64Encode(Blob.valueOf(formb));
            
            /* file header and contents */
            String fileh = '--' + boundry + '\r\nContent-Disposition: form-data; name="file"; filename="' + fileName
            						+ '"\r\nContent-Type: application/octet-stream';
			String filehe = EncodingUtil.base64Encode(Blob.valueOf(fileh + '\r\n\r\n'));
			String filebe = EncodingUtil.base64Encode(fileBlob);
			
            /* align form header and body as per rules of boundry */
            while(formhe.endsWith('=')){
                formh+=' ';
                formhe = EncodingUtil.base64Encode(Blob.valueOf(formh+'\r\n\r\n'));
            }
            
            String last4Bytes = formbe.substring(formbe.length()-4,formbe.length());
            if(last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                formbe = formbe.substring(0,formbe.length()-4) + last4Bytes;
            } else if(last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                formbe = formbe.substring(0,formbe.length()-4) + last4Bytes;
            } else {
            }
            
            /* align file header and body as per rules of boundry  also align footer as per manipulation in the file body i.e. contents just before footer */
            while(filehe.endsWith('=')){
                fileh+=' ';
                filehe = EncodingUtil.base64Encode(Blob.valueOf(fileh+'\r\n\r\n'));
            }
			
            last4Bytes = filebe.substring(filebe.length()-4,filebe.length());
            if(last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0,2) + '0K';
                filebe = filebe.substring(0,filebe.length()-4) + last4Bytes;
            } else if(last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0,3) + 'N';
                filebe = filebe.substring(0,filebe.length()-4) + last4Bytes;
                footer = '\n' + footer;
            } else {
                    footer = '\r\n' + footer;
            }
            
            /* assemble everything as blog and return the actual body as blob. */
			String footere = EncodingUtil.base64Encode(Blob.valueOf(footer));
			contents = EncodingUtil.base64Decode(formhe + formbe + filehe + filebe + footere);
            
            return contents;
        }        
        
    }
    
    public void callOTApp(OT_REQUEST_TYPE requestType, AWSC_ResponseParserVisitor visitor, P2POTRequestParam requestParams){
        //should throw an exception if no query for found
        if(requestType == null){
            throw new AWSC_Exception('No OT requestType value set. Unable to understand which query to fire.');
        }
        P2POTRestServiceResource resource;
        if(requestType == OT_REQUEST_TYPE.CREATENODE){
            if(null == requestParams || String.isEmpty(requestParams.nodeName) || String.isEmpty(requestParams.fileData)){
                throw new AWSC_Exception('No nodeName/fileData value set in param. Unable to understand what to Upload.');
            }
            requestParams.requestType = OT_REQUEST_TYPE.CREATENODE;
            resource = new P2POTAppClient.P2POTCreateNodeResource(requestParams, visitor);
        }else if(requestType == OT_REQUEST_TYPE.BROWSENODE){
            if(null == requestParams || String.isEmpty(requestParams.nodeName)){
                throw new AWSC_Exception('No nodeName/fileData value set in param. Unable to understand what to Browse.');
            }
            requestParams.requestType = OT_REQUEST_TYPE.BROWSENODE;
            resource = new P2POTAppClient.P2POTBrowseNodeResource(requestParams, visitor);
        }else if(requestType == OT_REQUEST_TYPE.NODECONTENT){
            if(null == requestParams || String.isEmpty(requestParams.nodeName)){
                throw new AWSC_Exception('No fileName value set in param. Unable to understand which node to Download.');
            }
            requestParams.requestType = OT_REQUEST_TYPE.NODECONTENT;            
            resource = new P2POTAppClient.P2POTNodeContentResource(requestParams, visitor);
        }
        resource.defensiveInvoke();
        return;
    }
}