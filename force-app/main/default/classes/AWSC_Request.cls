/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 *  Abstract Webservice Service Request used for http comms with the service
 *  Extending classes should implement specific Rest/SOAP structures as needed
 */
public virtual class AWSC_Request {
    
    /** the service endpoint locator */
    protected final AWSC_ServiceLocator locator;
        
    /** the service resource to be consumed or serviced */
    protected final AWSC_ServiceResource serviceResource;
    
    /** method type */
    public enum RequestMethod { GET, POST, DELETE_X, PATCH }
    
    /** set the method type */
    public RequestMethod method { public get; public set;}
    
    /** set the content type */
    public String contentType {public get; public set; }
    
    /** whether request type is auth */
    public Boolean isAuthRequest; 
    
    /** the headers to set for this RPC request */
    public Map<String, String> headers { public get; public set; }

    /**
     * whether this request type is auth
     */
    public Boolean isAuthRequest() {
        return isAuthRequest;
    }
    
    /** 
     * return the end point
     */
    public String getEndpoint() {
        return locator.endpoint();
    }
    
    /**
     * return the service resource
     */
    public AWSC_ServiceResource getServiceResource() {
        return serviceResource;
    }
    
    /**
     * construct a new service request for the passed service resource
     */
    public AWSC_Request(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
        this(serviceResource, serviceLocator, false, AWSC_Request.RequestMethod.GET);
    }
    
    /**
     * construct a new service request for passed service resource
     * specify if its an Auth request
     */
    public AWSC_Request(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest) {
        this(serviceResource, serviceLocator, isAuthRequest, AWSC_Request.RequestMethod.GET);
    } 

    /**
     * fully qualified constructor
     * TODO: fix more elegantly to reuse request/response paradigm for auth
     * requests also
     */
    public AWSC_Request(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest, AWSC_Request.RequestMethod requestMethod) {
        this.serviceResource = serviceResource;
        this.isAuthRequest = isAuthRequest;
        this.locator = serviceLocator;
        
        //default method = GET
        this.method = requestMethod;
        
    } 
    
    /**
     * String representation of the request
     */ 
    public virtual override String  toString(){
        return 'Method: ' + method.name() + ', Endpoint: ' + getEndpoint() ;
    }

}