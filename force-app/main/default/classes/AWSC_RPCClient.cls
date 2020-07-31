/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

public class AWSC_RPCClient extends AWSC_Client{

    /**
     * Create an instance of the rest client    
     */
    public AWSC_RPCClient(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
        super(serviceLocator, authProvider);
    }
    

    /**
     * build the GET request
     */
    protected override HttpRequest buildGet(AWSC_Request request, String path) {
        
        URL uri = buildUri(path);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('GET');
        return req;
    }

    /**
     * build the POST request
     */
    protected override HttpRequest buildPost(AWSC_Request request, String path) {

        AWSC_RPCRequest rpcRequest = (AWSC_RPCRequest)request;
        URL uri = buildUri(path);
        String body = buildBody(rpcRequest.getXMLBody());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }
    
    /**
     * build the DELETE request
     */
    protected override HttpRequest buildDelete(AWSC_Request request, String path) {
        URL uri = buildUri(path);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('DELETE');
        return req;
    }        
    
    /**
     * create a rest response object
     */
    protected override AWSC_Response createResponse(String endpoint, String responseText, 
                                                    Integer statusCode, String contentType) {
        return new AWSC_Response(endpoint, responseText, statusCode, contentType);
    }

    protected override AWSC_Response createResponse(String endpoint, HttpResponse httpResponse, 
                                                    Integer statusCode, String contentType) {
        return new AWSC_Response(endpoint, httpResponse, statusCode, contentType);
    }
    
    /**
     * build the POST entity body
     */
    protected override String buildBody(Object params) {
        
        if(! (params instanceof String)) {
            throw new AWSC_Exception('Invalid parameters passed for POST Body - need String');
        }
        
        return (String)params;
    }
    
    /**
     * build the POST request
     */
    protected virtual override HttpRequest buildPatch(AWSC_Request request, String path) {

        AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
        URL uri = buildUri(path);
        String body = buildBody(restRequest.getParams());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setHeader('X-HTTP-Method-Override','PATCH');
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }

}