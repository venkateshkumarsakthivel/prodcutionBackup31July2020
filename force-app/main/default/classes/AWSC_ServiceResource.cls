/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * The Service Resource type definition used to qualify a single resource
 * that is provided by the service
 */

public abstract class AWSC_ServiceResource{

    /** the rest client */
    protected AWSC_Client client;

    /** the rest request for this service */
    protected AWSC_Request request;
        
    /** service locator - to be provided by specific resource implementation */
    protected AWSC_ServiceLocator serviceLocator;
    
    /** the auth provider - to be provided by specific resource implementation  */
    protected AWSC_AuthenticationStrategy authProvider;
    
    protected Object requestParams;
    
    /**
     * return the relative uri path to the resource
     */
    public abstract String getResourcePath();
    
    /**
     * return the service request builder 
     * request builder - to be provided by specific resource implementation
     */
    protected abstract AWSC_RequestBuilder getRequestBuilder();
    
    /**
     * return the service response parser 
     * response parser - to be provided by specific resource implementation
     */
    protected abstract AWSC_ResponseParser getResponseParser();
    
    /**
     * return the service locator
     */
    public abstract AWSC_ServiceLocator getServiceLocator();
    
    /**
     * return the authentication strategy
     */
    protected abstract AWSC_AuthenticationStrategy getAuthenticationStrategy();

    
    /**
     * fire the call to the service
     */
    public virtual void invoke(){

        this.request = getRequestBuilder().buildRequest(requestParams);
        
        AWSC_Response response = client.request(request);

        AWSC_ResponseParser responseParser = getResponseParser();

        responseParser.parseResponse(request, response);
    }
   
}