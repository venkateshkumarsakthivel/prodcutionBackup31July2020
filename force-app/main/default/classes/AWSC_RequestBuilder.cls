/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * Request builder definition
 * Specific SOAP/REST implementations for specific services to implement this as required
 */

public interface AWSC_RequestBuilder {
    
    AWSC_Request buildRequest(Object reqParams);

}