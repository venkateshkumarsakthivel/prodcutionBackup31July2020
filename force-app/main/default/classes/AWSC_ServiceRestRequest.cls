/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * Rest request definition used for http comms with the service
 */

public class AWSC_ServiceRestRequest extends AWSC_Request {
    
    /** the params for the request*/
    private Object params;
    
    /**
     * return the query params
     */
    public Object getParams() {
        return params;
    }
    
    /**
     * set the params
     */
    public void setParams(Object params) {
        this.params = params;
    }
    
    /**
     * construct a new service rest request for the passed service resource
     */
    public AWSC_ServiceRestRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
        this(serviceResource, serviceLocator, false);
    }

     /**
     * construct a new service rest request for the passed service resource
     */
    public AWSC_ServiceRestRequest(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest) {
         this(serviceResource, serviceLocator, isAuthRequest, AWSC_Request.RequestMethod.GET);
    } 

    /**
     * TODO: fix more elegantly to reuse request/response paradigm for auth
     * requests also
     */
    public AWSC_ServiceRestRequest(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest, AWSC_Request.RequestMethod requestMethod) {
         super(serviceResource, serviceLocator, isAuthRequest, requestMethod);
    } 
    
    /**
     * override with params specific to Rest Request
     */
    public override String  toString(){
        return 'Method: ' + method.name() + ', Endpoint: ' + getEndpoint() + ', Params: ' + params;
    }
}