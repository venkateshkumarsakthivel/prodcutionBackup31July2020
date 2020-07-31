/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */
 
 /**
  * mock endpoint class 
  */
@isTest
 public class AWSC_TestHttpMock{

    private final static AWSC_TestHTTPMock instance = new AWSC_TestHTTPMock();
    
    public static AWSC_TestHTTPMock getInstance() { return AWSC_TestHTTPMock.instance; }
    
    private static Response response404 = new Response('{"status": 404, "message": "The requested resource was not found"}', 404);
    
    public Response send(HTTPRequest req) {
        System.debug('AWSC_TestHTTPMock::send() Request.Method: '+req.getMethod());
        System.debug('AWSC_TestHTTPMock::send() Request.Endpoint: '+req.getEndpoint());

        Response res = getResponse(req.getMethod(), req.getEndpoint());
        if (res==null) {
            res = response404;      
        }
        System.debug('AWSC_TestHTTPMock::send() Response.Body: '+res.getBody());

        return res;
    }
    
    
    /**
     * mock response - 
     * TODO: build map of responses to test endpoints...
     */
    private Response getResponse(String method, String endpoint){
        return new Response('{"status": 200, "message": "success"}', 200);   
    }
    
    
    /**
     * mock response class corresponsing to HttpResponse
     */
    public class Response {
        
        private String body;
        private final Map<String,String> headers = new Map<String,String>();
        private Integer statusCode;
        
        public Response(String body, Integer statusCode) {
            this.body = body;
            this.statusCode = statusCode;
            this.headers.put('Content-Type','application/json'); // default
        }
        
        public void setHeader(String key, String value)
        {
            this.headers.put(key,value);
        }
        
        public Integer getStatusCode() {
            return this.statusCode;
        }
        
        public String getBody() {
            return this.body;
        }
        
        public String getHeader(String name) {
            return headers.get(name);
        }
    }
}