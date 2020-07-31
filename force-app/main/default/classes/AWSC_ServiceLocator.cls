/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * The Service Config class is used to provide the endpoints required 
 * by the service
 */

public interface AWSC_ServiceLocator{

    /**
     * set the endpoint explicitly
     */
    void setEndpoint(String endpoint);
    
    /**
     * provide the endpoint for the service
     */
    String endpoint();
    
    /**
     * provide the service version - for backward compatibility checks
     */
    String version();
}