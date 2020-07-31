abstract public with sharing class P2PRMSRestServiceResource extends AWSC_RestServiceResource {
	//Hook to hold any callback action data from ResponseParsing
	protected AWSC_ResponseParserVisitor visitor;
    protected AWSC_Response response;
    protected AWSC_ResponseParser responseParser;

        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected override AWSC_RequestBuilder getRequestBuilder() {
            return new P2PRMSOvtRequestBuilder(this);
        }

        public Object getRequestParameters() { return this.requestParams; }
                
        /**
         * return the service locator
         */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new P2PRMSOvtServiceConfig(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE);
            }
            return serviceLocator ;
        }
        
        /**
         * return the authentication strategy
         */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new P2PRMSOvtAuthStrategy(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE);
        }
    
        //constructors
        public P2PRMSRestServiceResource() {
            super();
        }
        public P2PRMSRestServiceResource(Object params) {
            super(params);
        }        
        public P2PRMSRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
            super(params);
            this.visitor = visitor;
        }   


        
        /**
         * fire the defensive (retry loaded) call to the service
         */
        public void execute(){
            request = getRequestBuilder().buildRequest(requestParams);
            if(Test.isRunningTest()) {
                response = new P2PRMSOvtMockImplementation().execute((AWSC_ServiceRestRequest)request);
            } else{
                response = client.request(request);
            }
            responseParser = getResponseParser();
            responseParser.parseResponse(request, response);
            //use the visitor to do the bulk database commits etc.
            responseParser.accept(this.visitor);
        }
}