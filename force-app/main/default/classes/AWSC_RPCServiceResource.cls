/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * RPC service resource definition used for http comms with the service
 */

public abstract class AWSC_RPCServiceResource extends AWSC_ServiceResource{

    /**
     * default constructor
     */
    public AWSC_RPCServiceResource(){
        this(null);
    }
    
    /**
     * create an instance of the RestService resource
     */
    public AWSC_RPCServiceResource(Object reqParams){
        this.authProvider = getAuthenticationStrategy();
        this.serviceLocator = getServiceLocator();
        this.requestParams = reqParams;
        this.client = new AWSC_RPCClient(this.serviceLocator, this.authProvider);
    }

}