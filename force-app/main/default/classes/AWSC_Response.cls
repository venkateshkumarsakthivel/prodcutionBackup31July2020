/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * AWSC Response definition used for http comms with the service
 */

public virtual class AWSC_Response {

    /** The original response */
    @TestVisible
    protected HttpResponse httpResponse;
    
    /** response body */
    protected String responseText;
        
    /** http response status */
    public Integer responseStatus { public get; public set;}
    
    /** the content type */
    protected String contentType;
    
    /** the endpoint */
    protected String endpoint;
    
    /** whether response is error based on status */
    public Boolean error {public get; public set;}
    
    /**
     * return the response text
     */
    public String getResponseText() {
        return responseText;
    }
    
    public Blob getResponseBlob(){
        return this.httpResponse.getBodyAsBlob();
    }
    
    public HttpResponse getHttpResponse(){
        return this.httpResponse;
    }
    
    /**
     * set the response text
     */
    public void setResponseText(String responseText) {
        this.responseText = responseText;
    }
        
    /**
     * return the response status
     */
    public Integer getResponseStatus() {
        return responseStatus;
    }
    
    /**
     * set the response status
     */
    public void setResponseStatus(Integer responseStatus) {
        this.responseStatus = responseStatus;
    }
    
    /**
     * set the content-type
     */
    public void setContentType(String contentType){
        this.contentType = contentType;
    }
    
    /**
     * true if content type is json
     */
    public boolean isJson() {
        return (this.contentType != null && this.contentType.startsWithIgnoreCase('application/json'));
    }
    
    /**
     * true if content type is xml
     */
    public boolean isXml() {
        return (this.contentType != null && (this.contentType.startsWithIgnoreCase('application/xml') 
                                                || this.contentType.startsWithIgnoreCase('text/xml')));
    }        
    
    /**
     * return whether errored
     */
    public boolean isError() {
        return error;
    }
    
    /**
     * return whether the error is server side
     */
    public boolean isServerError() {
        return this.getResponseStatus() >= 500;
    }

    /**
     * return whether the error is server side
     */
    public boolean isClientError() {
        return (this.getResponseStatus() >= 400 && this.getResponseStatus() <= 500);
    }
    
    public AWSC_Response(String endpoint, String responseText, Integer statusCode, String contentType) {
        this.endpoint = endpoint;
        this.setResponseText(responseText);
        this.setResponseStatus(statusCode);
        this.setContentType(contentType);
    }

    public AWSC_Response(String endpoint, HttpResponse httpResponse, Integer statusCode, String contentType) {
        this.endpoint = endpoint;
        this.httpResponse = httpResponse;
        this.setResponseText(httpResponse.getBody());
        this.setResponseStatus(statusCode);
        this.setContentType(contentType);
    }
    
}