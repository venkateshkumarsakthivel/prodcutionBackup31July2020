/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 *  Rest response definition used for http comms with the service
 */

public class AWSC_ServiceRestResponse extends AWSC_Response{
    
    /**
     * create an instance of the rest response
     */
    public AWSC_ServiceRestResponse(String endpoint, String responseText, Integer statusCode, String contentType) {
        super(endpoint, responseText, statusCode, contentType);
    }

    public AWSC_ServiceRestResponse(String endpoint, HttpResponse httpResponse, Integer statusCode, String contentType) {
        super(endpoint, httpResponse, statusCode, contentType);
    }
    
}