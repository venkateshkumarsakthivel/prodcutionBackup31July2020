/** 
* @name P2POSRRPCServiceResource
* @usage this is abstract class with attributes and common execute method, all OSR rleated resources will 
* exetend this class to include visitor and mockImplementation of response for testing purpose
* @author Arxxus P2P developer team
*/

abstract public with sharing class P2POSRRPCServiceResource extends AWSC_RPCServiceResource  {
    protected AWSC_ResponseParserVisitor visitor;
    protected AWSC_Response OSRresponse;
    protected AWSC_ResponseParser responseParser;

    public P2POSRRPCServiceResource(Object parameters) {
        super(parameters);
    }
    
    public Object getRequestParameters() { return this.requestParams; }
    
    /**
    */
    public void execute()  {
        /** following lines will build request depending upon current resource instance and perform actual callout. */
        this.request = this.getRequestBuilder().buildRequest(this.requestParams);
        P2POSRClient.OSR_REQUEST_TYPE requestType = (P2POSRClient.OSR_REQUEST_TYPE) ((P2POSRRequestParameter) this.requestParams).requestType;
        if(Test.isRunningTest()) { this.authProvider.checkLoggedIn(); this.authProvider.authenticate();
			this.serviceLocator.version();
			this.serviceLocator.setEndpoint(null);
			this.OSRresponse = new P2POSRSOAPMockImplementation().execute(this.request, this.requestParams);
        } else { this.OSRresponse = this.client.request(this.request);
        }
        
        /** following lines will parse response and call visitor.visit to handle post call processing of response with DB or else. */
        this.responseParser = this.getResponseParser();
        this.responseParser.parseResponse(this.OSRresponse);
        this.responseParser.parseResponse(this.request, this.OSRresponse);
        this.responseParser.accept(this.visitor);

        }
}