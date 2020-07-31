/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 *  Abstract Webservice client used for http comms with the service
 *  Extending classes should implement specific Rest/SOAP structures as needed
 */
public abstract class AWSC_Client {

    public static final String VERSION = '1.0.0';
    
    /** the resource locator for the service */
    protected final AWSC_ServiceLocator serviceLocator;
    
    /** the auth provider for the service */
    protected final AWSC_AuthenticationStrategy authProvider;
    
    /** num retries */
    public Integer retryCount { public get; public set;}
    
    
    /** FOR TESTING */
    @TestVisible private AWSC_TestProxy testProxy; 
    public void injectTestProxy(AWSC_TestProxy testProxy) {this.testProxy = testProxy;}
    
    /**
     * Create an instance of the webservice client
     */
    public AWSC_Client(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
     
        this.serviceLocator = serviceLocator;
        this.authProvider = authProvider;
        
        //set default retry count to 3
        this.retryCount = 3;
    }

    /**
     * fire request to the service
     */
    public virtual AWSC_Response request(AWSC_Request awscRequest){
       
        HttpRequest request = setupRequest(awscRequest);
        String responseText;
        Blob responseBlob;
        Integer statusCode;
        String contentType;

        if (Test.isRunningTest()) {
            if(null != testProxy){
                return testProxy.execute(awscRequest);
            }else{
                //test mode - use generic test mock
                AWSC_TestHTTPMock.Response responseMock = AWSC_TestHTTPMock.getInstance().send(request);
                responseText = (responseMock.getBody()==null)?'':responseMock.getBody();
                statusCode = responseMock.getStatusCode();
                contentType = responseMock.getHeader('Content-Type');
            }
        } else {
            System.debug('Request = ' + request.getEndpoint() + ',\r\n' + request.getBody());
            System.debug('Content-Type :: ' + request.getHeader('Content-Type'));
            HttpResponse response = (new Http()).send(request);
            responseText = (response.getBody() == null) ? '' : response.getBody();
            statusCode = response.getStatusCode();
            contentType = response.getHeader('Content-Type');
            return createResponse(request.getEndpoint(), response, statusCode, contentType);
        }
        
        return createResponse(request.getEndpoint(), responseText, statusCode, contentType);
     }
    
     /**
      * create an instance of the AWSC response object
      */
     protected abstract AWSC_Response createResponse(String endpoint, String responseText, 
                                                    Integer statusCode, String contentType);

     protected abstract AWSC_Response createResponse(String endpoint, HttpResponse httpResponse, 
                                                    Integer statusCode, String contentType);

    
    /**
     * setup retry mechanism for defensive callouts
     */
    public AWSC_Response defensiveRequest(AWSC_Request awscRequest) {
        
        AWSC_Response response = null;
        for (Integer retry = 0; retry < this.retryCount; retry++) {
            response = request(awscRequest);
            if (response.isClientError()) {
                System.debug('AWSC API Client Error: '+response.getResponseText());
                throw new AWSC_Exception(response.toString());
            } else if (response.isServerError()) {
                //simply retry - log a warning here?
                System.debug(LoggingLevel.WARN, 'Server Error for request - ' + awscRequest.getEndpoint()); 
                continue;
            } else {
                return response;
            }
        }
        Integer errorCode = response == null ? -1 : response.getResponseStatus();
        throw new AWSC_Exception('Failed to request ' + awscRequest + ', Errorcode = ' + errorCode);
    }
    
    /**
     * Create the http request for the call
     */
    protected HttpRequest setupRequest(AWSC_Request awscRequest){
        
        String path = buildResourcePath(awscRequest);
        System.debug(path);
        HttpRequest request = buildMethod(awscRequest, path);

        request.setHeader('X-AWSC-Client', 'arxx-salesforce-' + VERSION);
        request.setHeader('User-Agent', 'arxx-salesforce/' + VERSION);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Charset', 'utf-8');
        
        System.debug('Is this an Auth Request? ' + awscRequest.isAuthRequest());
        //only decorate for non-auth requests...
        if(!awscRequest.isAuthRequest()) {
            //use auth strategy to inject required headers if needed...
            System.debug('Decorating the Auth Creds into Request');
            authProvider.decorateRequestWithCredential(request);
           // request.setHeader('Authorization', 'Basic ' + encoded session id ));
        }
        
        if(awscRequest.contentType != null) {
            request.setHeader('content-type', awscRequest.contentType);
        }
        
        if(awscRequest.headers != null) {
            for (String header : awscRequest.headers.keySet()) {
                request.setHeader(header, awscRequest.headers.get(header));
            }
        }
        
        return request;
    }
    
    /**
     * normalize the resource path and fully qualify with the service endpoint
     */
    protected String buildResourcePath(AWSC_Request awscRequest) {
        String path = awscRequest.getServiceResource().getResourcePath();
        String normalizedPath = path.toLowerCase();
        String sb = '';
        
        // if  FQ URI, use it as it is
        if (normalizedPath.startsWith('http://') || normalizedPath.startsWith('https://')){
            sb += path;
        } else {
            sb += serviceLocator.endpoint();
            System.debug(LoggingLevel.INFO, 'SB: ' + sb);
            if((sb.startsWithIgnoreCase('http://') || sb.startsWithIgnoreCase('https://')))  { 
                System.debug(LoggingLevel.INFO, 'SB starts with https');       
                if(!sb.endsWithIgnoreCase('/') && !normalizedPath.startsWith('/')){
                    sb += '/';    
                }
            } else if (!normalizedPath.startsWith('/')) {
                sb += '/';
            }
            sb += path;
            System.debug(LoggingLevel.INFO, 'Modified sb: ' + sb);
            if(sb.endsWithIgnoreCase('/') && !sb.containsIgnoreCase('filesForDownload')){
                sb = sb.substring(0, sb.length()-1);
            }
            System.debug(LoggingLevel.INFO, 'Final sb: ' + sb);
        }

        return sb;
    }
    
    /**
     * build the http request structure - url, query string
     */
    protected HttpRequest buildMethod (AWSC_Request request, String path) {
        
        if (request.method == AWSC_Request.RequestMethod.GET) {
            return buildGet(request, path);
        } else if (request.method == AWSC_Request.RequestMethod.POST) {
            return buildPost(request, path);
        } else if (request.method == AWSC_Request.RequestMethod.DELETE_X) {
            return buildDelete(request, path);
        } else if (request.method == AWSC_Request.RequestMethod.PATCH) {
            return buildPatch(request, path);
        } else {
            throw new AWSC_Exception('Unknown Method: ' + request.method);
        }
    }
    
    /**
     * build the GET request
     */
    protected abstract HttpRequest buildGet(AWSC_Request request, String path);

    /**
     * build the POST request
     */
    protected abstract HttpRequest buildPost(AWSC_Request request, String path);

    /**
     * DELETE request
     */
    protected abstract HttpRequest buildDelete(AWSC_Request request, String path);    

    /**
     * PATCH request
     */
    protected abstract HttpRequest buildPatch(AWSC_Request request, String path);   
    
    /**
     * build the URL for the passed path
     */
    protected URL buildUri(String path) {
        return buildUri(path, null); 
    }
    
    /**
     * build the URL for passed path and query string params
     */
    protected URL buildUri(String path, Object params) {
        Map<String, String> mParams;
        if(params instanceof Map<String, String>) {
            mParams = (Map<String, String>) params;
        }
        String sb = path;

        if (mparams != null && mParams.size() > 0) {
            sb += '?';
            sb += buildBody(params);
        }

        URL uri;
        try {
            uri = new URL(sb);
        } catch (Exception e) {
            throw new AWSC_Exception('Invalid uri: '+sb, e);
            system.debug('ErrorCause: '+e.getLineNumber() );
        }

        return uri;
    }
    
    /**
     * build the POST entity body
     */
    protected abstract String buildBody(Object params);
}