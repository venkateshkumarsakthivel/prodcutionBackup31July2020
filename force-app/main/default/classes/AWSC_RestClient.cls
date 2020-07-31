/**
 * Copyright 2014 Arxxus Technology Partners Pty Ltd. All rights reserved.
 * Arxxus PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/*
 *  Rest client used for http comms with the service
 */
public virtual class AWSC_RestClient extends AWSC_Client {

    /**
     * Create an instance of the rest client    
     */
    public AWSC_RestClient(AWSC_ServiceLocator serviceLocator, AWSC_AuthenticationStrategy authProvider) {
        super(serviceLocator, authProvider);
    }
    

    /**
     * build the GET request
     */
    protected virtual override HttpRequest buildGet(AWSC_Request request, String path) {
        
        AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
        URL uri = buildUri(path, restRequest.getParams());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('GET');
        return req;
    }

    /**
     * build the POST request
     */
    protected virtual override HttpRequest buildPost(AWSC_Request request, String path) {

        AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
        URL uri = buildUri(path);
        String body = buildBody(restRequest.getParams());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }
    
    /**
     * build the DELETE request
     */
    protected virtual override HttpRequest buildDelete(AWSC_Request request, String path) {
        AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
        URL uri = buildUri(path);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setMethod('DELETE');
        return req;
    }    

    /**
     * build the Patch request
     */
    protected virtual override HttpRequest buildPatch(AWSC_Request request, String path) {

        AWSC_ServiceRestRequest restRequest = (AWSC_ServiceRestRequest)request;
        URL uri = buildUri(path);
        String body = buildBody(restRequest.getParams());
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        req.setHeader('X-HTTP-Method-Override','PATCH');
        req.setMethod('POST');
        req.setBody(body);
        return req;
    }
    
    /**
     * create a rest response object
     */
    protected override AWSC_Response createResponse(String endpoint, String responseText, 
                                                    Integer statusCode, String contentType) {
        return new AWSC_ServiceRestResponse(endpoint, responseText, statusCode, contentType);
    }

    protected override AWSC_Response createResponse(String endpoint, HttpResponse httpResponse, 
                                                    Integer statusCode, String contentType) {
        return new AWSC_ServiceRestResponse(endpoint, httpResponse, statusCode, contentType);
    }
    
    /**
     * build the POST entity body
     */
    protected override String buildBody(Object params) {
        String body = '';
        //if Map - set as KV pairs in url
        if(params instanceof Map<String, String>) {
            Map<String, String> reqParams = (Map<String, String>)params;            
            if (reqParams != null) {
                for (String key : reqParams.keySet()) {
                    try {
                        body += (body =='' ? '' : '&')
                                        + key + '=' + EncodingUtil.urlEncode(reqParams.get(key), 'UTF-8');
                    } catch (Exception e) {
                        System.debug(LoggingLevel.WARN, 'Error encoding param in POST body: ' + key + ':' + e);
                    }
                }
            }
        } else {
            //serialise the param and set it directly into body (suppressNull = true)
            body = JSON.serialize(params, true);
            //sample request
            //body = '{"header":{"messageId":"123","messageGroupId":"1234","messageRelatedId":"12345","createdTimestamp":"2016-04-08T09:00:00","expiryTimestamp":"2016-04-08T09:30:00","priority":4,"clientId":"P2PEligibilityCheck","clientSystemId":"P2PEligibilityCheck","channelType":"Online","requestor":[{"requestorId":"888","requestorType":"Staff","requestorIdType":"Staff","requestorGroupType":"requestorGroup"}],"location":[{"locationId":"Transport","locationType":"Branch"}],"extension":[{"name":"organisationCode","value":"${#TestCase#ext_val}"}]},"body":{"assessmentType":"P2PMimumStandardsEligibility","licenceParameter":{"id":"19246800","idType":"RoadsRegistrationAndLicencing","surname":"CAUCHI","dateOfBirth":"1985-02-07"}}}';
            System.debug(body);
        }
        return body;
    }

}