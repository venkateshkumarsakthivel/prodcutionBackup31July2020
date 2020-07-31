/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 * Response parser definition
 * Specific SOAP/REST implementations for specific services to implement this as required
 */

public interface AWSC_ResponseParser {
    
    void parseResponse(AWSC_Request request, AWSC_Response response);

    void parseResponse(AWSC_Response response);
    
    void accept(AWSC_ResponseParserVisitor visitor);

    
}