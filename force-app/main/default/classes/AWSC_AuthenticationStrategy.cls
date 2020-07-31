/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * Auth strategy to be used with the service
 */
public interface AWSC_AuthenticationStrategy{
    
    /**
     * return whether client is logged in
     */
    Boolean checkLoggedIn();
    
    /**
     * authenticate against the service
     */
    Boolean authenticate();
    
    /**
     * augment the request with 'token' or 'session' credential as required
     * for subsequent authenticated state calls to service
     */
    void decorateRequestWithCredential(HttpRequest request);
}