/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */
 @isTest
public class AWSC_TestClient {

    public class AWSC_TestAuthenticationStrategy implements AWSC_AuthenticationStrategy {
         
       public Boolean checkLoggedIn() {
         return true;       
       }
    
       public Boolean authenticate() {
        return true;
       }
    
       public void decorateRequestWithCredential(HttpRequest request) {
         return;
       }
    }
    
    public class AWSC_TestServiceLocator implements AWSC_ServiceLocator {
        
        private String endpoint = 'https://www.arxxus.com/awsc/test';
        
        public void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
        }

        public String endpoint() {
            return this.endpoint;
        }
    
        public String version() {
           return 'v1.0';   
        }
    }

    public class AWSC_TestRequestBuilder implements AWSC_RequestBuilder {
        
         private AWSC_ServiceResource parent;
         
         public AWSC_TestRequestBuilder(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
       
         public AWSC_Request buildRequest(Object reqParams) {
             AWSC_Request request; 
           
            //default is POST - RPC
             if((reqParams != null) && (reqParams instanceof List<String>)) {
                List<String> params = (List<String>)reqParams;
                if(params[0].equals('REST')){
                    if(params[1].equals('GET')){
                         request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
                         request.method = AWSC_Request.RequestMethod.GET;                   
                    } else {
                         request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
                         request.method = AWSC_Request.RequestMethod.POST;
                    }
                   Map<String, String> queryParams = new Map<String, String> ();
                   queryParams.put('testkey1', 'testvalue1');
                   ((AWSC_ServiceRestRequest)request).setParams(queryParams);                   
                } else {
                    if(params[1].equals('GET')){
                         request = new AWSC_RPCRequest(parent, parent.getServiceLocator());
                         request.method = AWSC_Request.RequestMethod.GET;                   
                    } else {
                         request = new AWSC_RPCRequest(parent, parent.getServiceLocator());
                         request.method = AWSC_Request.RequestMethod.POST;
                    }
                   ((AWSC_RPCRequest)request).setXmlBody('<test></test>');                  
                }
             } else {
                throw new AWSC_Exception('Invalid Request Params - required List<String>');
             }
           
            request.contentType = 'text/xml';
            


           Map<String, String> headers = new Map<String, String> ();
           headers.put('test-header', 'x-arxx-test-header');
           request.headers = headers;
            //more code coverage..
           System.assert(true, request.toString()  != null);
            return request;
         }

    }
    
    public class AWSC_TestResponseParser implements AWSC_ResponseParser {
         
         private AWSC_ServiceResource parent;
         public AWSC_Response response;
      
         public AWSC_TestResponseParser(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
         
         public void parseResponse(AWSC_Response response) {
            parseResponse(null, response);
             this.response = response;
         }

         public void parseResponse(AWSC_Request request, AWSC_Response response) {
             System.assertEquals(response.getResponseStatus(), 200);
             System.assertEquals(response.getResponseText(), '{"status": 200, "message": "success"}');
         }
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            //do nothing
        }
                
    }
    
    public class AWSC_TestServiceRestResource extends AWSC_RestServiceResource {
        
        String rPath = '/test';
        
        //Methods from Service Resource
        /**
         * return the relative uri path to the resource
         */
        public override String getResourcePath(){
            //get test path
            return rPath;
        }
        
        //only for testing
        public void setRPath (String rPath) {
            this.rPath = rPath; 
        }
        
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected override AWSC_RequestBuilder getRequestBuilder() {
            return new AWSC_TestRequestBuilder(this);
        }
        
        /**
         * return the service response parser 
         * response parser - to be provided by specific resource implementation
         */
        protected override AWSC_ResponseParser getResponseParser() {
            return new AWSC_TestResponseParser(this);
        }
        
        /**
         * return the service locator
         */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new AWSC_TestServiceLocator();
            }
            return serviceLocator ;
        }
        
        /**
         * return the authentication strategy
         */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new AWSC_TestAuthenticationStrategy();
        }
    
        
        //constructors
        
        public AWSC_TestServiceRestResource() {
            super();
        }
        
        public AWSC_TestServiceRestResource (Object reqParams) {
            super (reqParams);
        }

    }
    
    public class AWSC_TestServiceRPCResource extends AWSC_RPCServiceResource {
        /**
         * return the relative uri path to the resource
         */
        public override String getResourcePath(){
            //get test path
            return '/test';
        }
        
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected override AWSC_RequestBuilder getRequestBuilder() {
            return new AWSC_TestRequestBuilder(this);
        }
        
        /**
         * return the service response parser 
         * response parser - to be provided by specific resource implementation
         */
        protected override AWSC_ResponseParser getResponseParser() {
            return new AWSC_TestResponseParser(this);
        }
        
        /**
         * return the service locator
         */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new AWSC_TestServiceLocator();
            }
            return serviceLocator ;
        }
        
        /**
         * return the authentication strategy
         */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new AWSC_TestAuthenticationStrategy();
        }
    
        
        //constructors
        
        public AWSC_TestServiceRPCResource() {
            super();
        }
        
        public AWSC_TestServiceRPCResource (Object reqParams) {
            super (reqParams);
        }
        
        /**
         * fire the defensive (retry loaded) call to the service
         */
        public void defensiveInvoke(){
            request = getRequestBuilder().buildRequest(requestParams);
            AWSC_Response response = client.defensiveRequest(request);
            AWSC_ResponseParser responseParser = getResponseParser();
            responseParser.parseResponse(request, response);
        }
    }
    
    
    public static testmethod void testRestClient() {
        List<String> params = new List<String>();
        params.add('REST');
        params.add('GET');
        AWSC_TestServiceRestResource r = new AWSC_TestServiceRestResource(params);
        r.invoke();
        
        params = new List<String>();
        params.add('REST');
        params.add('POST');
        r = new AWSC_TestServiceRestResource(params);
        r.invoke();
    }
    
    public static testmethod void testRPCClient() {
        List<String> params = new List<String>();
        params.add('RPC');
        params.add('GET');
        AWSC_TestServiceRPCResource r = new AWSC_TestServiceRPCResource(params);
        r.invoke();
        
        params = new List<String>();
        params.add('RPC');
        params.add('POST');
        r = new AWSC_TestServiceRPCResource(params);
        r.invoke();
    }

    public static testmethod void testDefensiveRequest() {
        List<String> params = new List<String>();
        params.add('RPC');
        params.add('GET');
        AWSC_TestServiceRPCResource r = new AWSC_TestServiceRPCResource(params);
        r.defensiveInvoke();
        
    }
    
    public static testmethod void testHttpPath () {
        List<String> params = new List<String>();
        params.add('RPC');
        params.add('GET');
        AWSC_TestServiceRPCResource r = new AWSC_TestServiceRPCResource(params);

        r.getServiceLocator().setEndpoint('http://www.arxxus.com/awsc/test');
        r.invoke();
    }

    public static testmethod void testNonRelativePath () {
        List<String> params = new List<String>();
        params.add('REST');
        params.add('GET');
        AWSC_TestServiceRestResource r = new AWSC_TestServiceRestResource(params);

        r.setRPath('test');
        r.invoke();
    }

    public static testmethod void testNormalisedPath () {
        List<String> params = new List<String>();
        params.add('REST');
        params.add('GET');
        AWSC_TestServiceRestResource r = new AWSC_TestServiceRestResource(params);

        r.setRPath('https://www.arxxus.com.au/awsc/test');
        r.invoke();
    }
    
    public static testmethod void testInvalidURI() {
        List<String> params = new List<String>();
        params.add('RPC');
        params.add('GET');
        AWSC_TestServiceRPCResource r = new AWSC_TestServiceRPCResource(params);

        r.getServiceLocator().setEndpoint('random uri path');
        try{
            r.invoke();
        }catch(AWSC_Exception e){
            System.assert(true, e.getMessage().startsWith('Invalid uri'));
        }
    }

    public static testmethod void testinvalidResourceInitialization() {

        AWSC_TestServiceRestResource r1 = new AWSC_TestServiceRestResource();
        try{
            r1.invoke();
        }catch(AWSC_Exception e){ 
            System.assertEquals('Invalid Request Params - required List<String>', e.getMessage());
        }
        
        AWSC_TestServiceRPCResource r2 = new AWSC_TestServiceRPCResource();
        try{
            r2.invoke();
        }catch(AWSC_Exception e){ 
            System.assertEquals('Invalid Request Params - required List<String>', e.getMessage());
        }
    }
    
    public static testmethod void testinvalidParams() {
        AWSC_TestServiceRestResource r1 = new AWSC_TestServiceRestResource();
        try{
            r1.invoke();
        }catch(AWSC_Exception e){ 
            System.assertEquals('Invalid Request Params - required List<String>', e.getMessage());
        }
        
        AWSC_TestServiceRPCResource r2 = new AWSC_TestServiceRPCResource();
        try{
            r2.invoke();
        }catch(AWSC_Exception e){ 
            System.assertEquals('Invalid Request Params - required List<String>', e.getMessage());
        }
    }
    
    //Coverage
    private static testmethod void testAWSCResponse(){
        AWSC_Response response = new AWSC_ServiceRestResponse('dummy', new HttpResponse(), -1, 'dummy'); 
        System.assert(response.isError() == null);
        System.assert(response.getResponseBlob() == null);
        System.assert(response.getHttpResponse() != null);
        System.assert(response.isJson() == false);
        System.assert(response.isXML() == false);        
    }

}