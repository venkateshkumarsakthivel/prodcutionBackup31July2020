/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * RPC request definition used for http comms with the service
 */
public virtual class AWSC_RPCRequest extends AWSC_Request {

    /** the XML RPC Body */
    private String xmlBody;
    
    /**
     * return the XML body 
     */
    public String getXMLBody() {
        return this.xmlBody;
    }
    
    /**
     * Set the XML Body
     */
    public void setXMLBody(String xmlBody) {
        this.xmlBody = xmlBody;
    }
    
    /**
     * construct a new service rest request for the passed service resource
     */
    public AWSC_RPCRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
        this(serviceResource, serviceLocator, false);
    }

     /**
     * construct a new service RPC request for the passed service resource
     * Note: that the default method is POST for RPC requests...
     *       as opposed to GET for REST requests
     */
    public AWSC_RPCRequest(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest) {
         this(serviceResource, serviceLocator, isAuthRequest, AWSC_Request.RequestMethod.POST);
    }

    /**
     * TODO: fix more elegantly to reuse request/response paradigm for auth
     * requests also
     */
    public AWSC_RPCRequest(AWSC_ServiceResource serviceResource, 
                            AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest, AWSC_Request.RequestMethod requestMethod) {
         super(serviceResource, serviceLocator, isAuthRequest, requestMethod);
    } 
    
    /**
     * override with params specific to Rest Request
     */
    public override String  toString(){
        return 'Method: ' + method.name() + ', Endpoint: ' + getEndpoint() + ', Body: ' + xmlBody;
    }
}