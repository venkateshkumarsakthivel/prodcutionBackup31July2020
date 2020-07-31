/**
 * OT COntent Server ECMLink SOAP Service Client
 * 
 * OT ECM - SF Interaction Resource 
 * SOAP Client for SF Id to OT Node ID translation
 * 
 * Arxxus Webservice Client Framework
 * @author raghu
 */

/**
 * This needs to be invoked/instantiated with a valid auth token
 * It is recommended that instead of authenticating everytime, 
 * reuse the auth token with a TTL from the Platform/Session cache 
 * - Check if cache has valid token, 
 * - if(valid) - instantiate an AuthStrategy with the token
 * - else - fire a P2POTSoapAuthenticator up and use that as the AuthStrategy 
 */

/**
 * TODO: eventually
 * Use the platform cache as a SFId vs NodeId translation Map
 * in a LRU fashion in order to reduce the need for a translation call to OT
 * 
 * If the cache has it available, reuse the NodeId mapping, 
 * else fire the call, populate the cache and use the mapping 
 * 
 * Since the cache will be designed LRU (potentially) and also have a TTL, 
 * it can reduce upto 2 calls (auth+translate) to OT
 */ 
public class P2POTNodeIdResource  extends AWSC_RPCServiceResource {
    
    private AWSC_AuthenticationStrategy ecmAuthenticator;
    
    /**
    * OT Service Locator
    */
    public class P2POTNodeIdServiceConfig implements AWSC_ServiceLocator {
        
        public String endpoint;
        /**
        * set the endpoint explicitly
        */
        public void setEndpoint(String endpoint){
            this.endpoint = endpoint;
        }
        
        /**
        * provide the endpoint for the service
        */
        public String endpoint(){
            if(this.endpoint == null) {
                //TODO: fetch from Custom settings config
                this.endpoint = 'https://hostb.dema1.com/otsapxecm/services/ECMLink?wsdl';
            }
            return this.endpoint;
        }
        
        /**
        * provide the service version - for backward compatibility checks
        */
        public String version() {
            return '';
        }
    }
    
    //Methods from Service Resource
    /**
    * return the relative uri path to the resource
    */
    public override String getResourcePath(){
        //OT path
        return '';
    }
    
    /**
    * return the service request builder 
    * request builder - to be provided by specific resource implementation
    */
    protected override AWSC_RequestBuilder getRequestBuilder() {
        return new P2POTNodeIdRequestBuilder(this);
    }
    
    /**
    * return the service response parser 
    * response parser - to be provided by specific resource implementation
    */
    protected override AWSC_ResponseParser getResponseParser() {
        return new P2POTNodeIdResponseParser(this);
    }
    
    /**
    * return the service locator
    */
    public override AWSC_ServiceLocator getServiceLocator() {
        if(serviceLocator == null) {
            serviceLocator = new P2POTNodeIdServiceConfig();
        }
        return serviceLocator ;
    }
    
    /**
    * return the authentication strategy
    */
    protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
        return this.ecmAuthenticator;
    }
    
    
    //constructors
    
    public String nodeId;
    public void setNodeId(String nodeId){this.nodeId = nodeId;}
    public String getNodeId(){ return nodeId;}
    
    public P2POTNodeIdResource() {
        super();
        System.debug('Nodeid resource ctor - no params');
    }
    
    public P2POTNodeIdResource (Object reqParams) {
        super (reqParams);
        System.debug('Nodeid resource ctor - req params only');
    }
    
    public P2POTNodeIdResource (Object reqParams, AWSC_AuthenticationStrategy authStrategy) {
        //Auth Strategy
        this.ecmAuthenticator = authStrategy;
		this.authProvider = getAuthenticationStrategy();
        
        this.serviceLocator = getServiceLocator();
        this.requestParams = reqParams;
        this.client = new AWSC_RPCClient(this.serviceLocator, this.authProvider);
    }
    
    public  class P2POTNodeIdRequest extends AWSC_RPCRequest {
        
        /**
        * construct a new service rest request for the passed service resource
        */
        public P2POTNodeIdRequest(AWSC_ServiceResource serviceResource, AWSC_ServiceLocator serviceLocator) {
            super(serviceResource, serviceLocator, false);
        }
        
        /**
        * construct a new service rest request for the passed service resource
        */
        public P2POTNodeIdRequest(AWSC_ServiceResource serviceResource, 
                                  AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest) {
                                      super(serviceResource, serviceLocator, isAuthRequest);
                                  } 
        
        /**
        * TODO: fix more elegantly to reuse request/response paradigm for auth
        * requests also
        */
        public P2POTNodeIdRequest(AWSC_ServiceResource serviceResource, 
                                  AWSC_ServiceLocator serviceLocator, Boolean isAuthRequest, AWSC_Request.RequestMethod requestMethod) {
                                      super(serviceResource, serviceLocator, isAuthRequest, requestMethod);
                                  } 
    }     
    
    /*** OT Get NodeId Request Builder*/
    public class P2POTNodeIdRequestBuilder  implements AWSC_RequestBuilder {
        
        /** handle to outer class for instance variables */
        private AWSC_ServiceResource parent;
        
        /*** create a request builder for auth*/
        public P2POTNodeIdRequestBuilder(AWSC_ServiceResource parent) {
            this.parent = parent;
        }
        
        
        public AWSC_Request buildRequest(Object reqParams) {
            //fetch required params from the config
            P2POTNodeIdRequest request = new P2POTNodeIdRequest(parent, parent.getServiceLocator());
            request.method = AWSC_Request.RequestMethod.POST;
            String sfObjectId, sfOTObjectName;
            
            if(reqParams instanceof Map<String, String>) {
                Map<String, String> reqParamsMap = (Map<String, String>)reqParams;
                sfObjectId = reqParamsMap.get('SFOBJECTID');
                sfOTObjectName = reqParamsMap.get('OTOBJECTTYPENAME');
            } else {
                throw new AWSC_Exception('Invalid Request Params - required Map<String,String> with SF Object ID');
            }
            
            String reqBody =
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:api.ecm.opentext.com" xmlns:urn1="urn:ECMLink.service.livelink.opentext.com"> '
                + '   <soapenv:Header> '
                + '      <urn:OTAuthentication> '
                + '         <urn:AuthenticationToken>{OTCSTICKET_TOKEN}</urn:AuthenticationToken> '
                + '      </urn:OTAuthentication> '
                + '   </soapenv:Header> '
                + '  <soapenv:Body> '
                + '      <urn1:getWorkspaceNodeIds> '
                + '         <urn1:externalSystemId>{OT_SF_SYSTEM_ID}</urn1:externalSystemId> '
                + '         <urn1:businessObjects> '
                + '            <urn1:ExternalSystemId>{OT_SF_SYSTEM_ID}</urn1:ExternalSystemId> '
                + '            <urn1:ObjectId>{SF_OBJECT_ID}</urn1:ObjectId> '
                + '            <urn1:ObjectType>{OT_OBJECT_TYPE_NAME}</urn1:ObjectType> '
                + '        </urn1:businessObjects> '
                + '      </urn1:getWorkspaceNodeIds> '
                + '   </soapenv:Body> '
                + '</soapenv:Envelope> ';
            reqBody = reqBody.replace('{SF_OBJECT_ID}', sfObjectId);
            reqBody = reqBody.replace('{OT_SF_SYSTEM_ID}', 'P2P Salesforce Sandbox');
            reqBody = reqBody.replace('{OT_OBJECT_TYPE_NAME}', sfOTObjectName);
            request.setXMLBody(reqBody);
            
            request.contentType = 'text/xml';
            //TODO any other headers here...
            
            return request;
        }
    }
    
    //Response parser
    /** OT Get NodeId Response Parser */
    public class P2POTNodeIdResponseParser implements AWSC_ResponseParser {
        
        /** handle to outer class for instance variables */
        private AWSC_ServiceResource parent;
        
        /**
        * create a response parser for auth
        */
        public P2POTNodeIdResponseParser(AWSC_ServiceResource parent) {
            this.parent = parent;
        }
        
        
        /*** parse the response to validate authentication, get token etc */
        public void parseResponse(AWSC_Response response) {
            parseResponse(null, response);
        }
        
        
        private Dom.Document domDoc = new Dom.Document();
        
        /*** parse the response to validate authentication, get token etc*/
        public void parseResponse(AWSC_Request request, AWSC_Response response) {
            
            //XXX - unsafe  - check for error codes, status etc
            String responseText = response.getResponseText();
            System.debug('Response Body = ' + responseText);
            domDoc.load(responseText);
            Dom.XmlNode rootXmlNode = domDoc.getRootElement();
            
            //TODO
            //readup the OT Node Id from response
             String nodeId = extractWorkspaceNodeId(domDoc.getRootElement());
                          
             System.debug('Node Id =  ' + nodeId);
             ((P2POTNodeIdResource)this.parent).setNodeId(nodeId);
            
        }
        
         
        public String extractWorkspaceNodeId(Dom.XMLNode fromNode) {
            
            String nodeId = null;
            if (fromNode.getName().equalsIgnoreCase('getWorkspaceNodeIdsResult')) {
            	System.debug('Found Node Id');
                nodeId = fromNode.getText(); 
            }
        
	        for (Dom.XmlNode child: fromNode.getChildElements()) {
                System.debug('CHILD NAME = ' + child.getName());
	            if (child.getName().equalsIgnoreCase('getWorkspaceNodeIdsResult')) {
	               nodeId = child.getText();
                   break;
	            } else if(! child.getChildElements().isEmpty()){
	                nodeId = extractWorkspaceNodeId(child);
                    if(nodeId != null) break;
	            }
	        } 
            return nodeId;
        }        
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            //do nothing
        }
    }
    
}