/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * Rest service resource definition used for http comms with the service
 */

public abstract class AWSC_RestServiceResource extends AWSC_ServiceResource{

    /**
     * default constructor
     */
    public AWSC_RestServiceResource(){
        this(null);
    }
    
    /**
     * create an instance of the RestService resource
     */
    public AWSC_RestServiceResource(Object reqParams){
        this.authProvider = getAuthenticationStrategy();
        this.serviceLocator = getServiceLocator();
        this.requestParams = reqParams;
        this.client = new AWSC_RestClient(this.serviceLocator, this.authProvider);
    }

}