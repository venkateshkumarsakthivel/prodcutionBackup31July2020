/**
 * DVD App Client 
 * Defines and Exposes the services required for DVD 
 * by P2P commissioner & Auth. Service Providers 
 */
public class P2PDVDAppClient {

    @TestVisible
    private static Boolean TEST_FOR_ERROR = false;
    
    public class P2PDVDAppAuthStrategy implements AWSC_AuthenticationStrategy {
    
       /*Default overrides */
       public Boolean checkLoggedIn() { return true; }
       public Boolean authenticate() { return true; }
        
       /**Self signed cert for use with RMS API for Mutual Auth*/
       public final String P2P_RMS_MA_CERT_NAME;
        
        
       private final String userPass;
        
       /**
        * @TODO Load from settings
        */ 
       public P2PDVDAppAuthStrategy(){
           userPass = Label.RMS_Checks_UserName + ':' + Label.RMS_Checks_Password;
           P2P_RMS_MA_CERT_NAME = 'P2P_DVDApp_Client';
       }
        
       /**
        * Load and set certificates into the request 
        * for Client Authentication with RMS
        * Set any other headers - Basic Auth etc. required
        */
       public void decorateRequestWithCredential(HttpRequest request) {
           request.setClientCertificateName(P2P_RMS_MA_CERT_NAME);
           request.setTimeout(Integer.valueOf(Label.RMS_DVD_Check_Timeout));
           //Basic Auth
           String encodedUserPass = EncodingUtil.base64Encode(Blob.valueOf(userPass));
           request.setHeader('Authorization', 'Basic ' + encodedUserPass);
           return;
       }
    }
    
    public class P2PDVDAppServiceConfig implements AWSC_ServiceLocator {
        
        /**
         * Service Gateway endpoint
         * End point for DVD App: RMS API
         */ 
        private final String baseUrl  = Label.Rms_DVD_Check_Base_URL;
        private final String basePath = Label.Rms_DVD_Check_Base_Path;
        private final String version  = Label.Rms_DVD_Check_Version;

        //private final String baseUrl  = 'https://st-servicegateway.rms.nsw.gov.au';
        //@TODO - load from custom settings
        public P2PDVDAppServiceConfig(){
            //baseUrl = 
            //basePath =
            //version = 
        }
        
        public void setEndpoint(String endpoint) {
            //this.endpoint = baseUrl + basePath + version();
        }

        public String endpoint() {
            return baseUrl + basePath + version();
            //return 'https://st-servicegateway.rms.nsw.gov.au/mscp2pat1/checkEligibility/v1';
            //return 'https://st-apps.rms.nsw.gov.au/mscp2pst1/api/assesssment/retrieve/v1/retrieveP2PCustomerAssessment';
        }
    
        public String version() {
           return version;  
        }
    }
    
    /**
     * Request Builder for DVD App Query to RMS
     */
    public class P2PDVDAppRequestBuilder implements AWSC_RequestBuilder {
        
         private AWSC_ServiceResource parent;
         
         public P2PDVDAppRequestBuilder(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
       
         public AWSC_Request buildRequest(Object reqParams) {
             AWSC_Request request; 
             //REST - POST
             //Params should be of type DVD_Query__c
             if((reqParams != null) && (reqParams instanceof DVD_Query__c)) {
                 request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
                 request.method = AWSC_Request.RequestMethod.POST;

                 DVD_Query__c dvdQueryParams = (DVD_Query__c)reqParams;
                 Object queryParams = RMSRequestEnvelope.build(dvdQueryParams);
                 System.debug('****RMSRequestEnvelope****');
                 System.debug(JSON.serialize(queryParams));
                 ((AWSC_ServiceRestRequest)request).setParams(queryParams);
             } else {
                 throw new AWSC_Exception('Invalid Request Params - required type = DVD_Query__c');
             }
           
             request.contentType = 'application/json';
             //add any headers required here..
             return request;
         }
    }

    public abstract class P2PDVDAppResponseParser implements AWSC_ResponseParser {
         
         protected final String STATUS_ERROR = 'ERROR';
         protected final String STATUS_SUCCESS = 'SUCCESS';
         protected final String CODE_DATA_VALIDATION = 'DATA_VALIDATION';
         protected final String CODE_SYSTEM_ERROR = 'SYSTEM ERROR';
        
         private AWSC_ServiceResource parent;

         private DVD_Query__c updatedQuery;
         private DVD_Entity__c updatedEntity;

         public DVD_Query__c getUpdatedQuery(){ return updatedQuery;}
         public DVD_Entity__c getUpdatedEntity() { return updatedEntity;}
      
         public P2PDVDAppResponseParser(AWSC_ServiceResource parent) {
             this.parent = parent;
         }
         
         public void parseResponse(AWSC_Response response) {
            parseResponse(null, response);
         }

         public void parseResponse(AWSC_Request request, AWSC_Response response) {
             System.debug('====='+response.getResponseText());
             Integer responseStatus = response.getResponseStatus();
             String responseText = response.getResponseText();
                /*             if(responseStatus != 200 || responseStatus != 400 || String.isEmpty(responseText)) {
                                 //error in request/response
                                 System.debug(LoggingLevel.WARN, 'An error has occurred in the DVD Check: ' + responseText);
                                 throw new AWSC_Exception(responseStatus + ':' + responseText);
                             }
                */
             responseText = responseText.replaceAll('"class":','"propertyClass":');
             System.debug('responseTest');
             System.debug(responseText);
             try{
                 if(TEST_FOR_ERROR) Integer testForError = 1/0;
                 //Strict deserialization: if there are param mismatches, this will throw an exception
                 RMSResponseEnvelope rre = (RMSResponseEnvelope)JSON.deserializeStrict(responseText, RMSResponseEnvelope.class);
                 System.debug('==='+rre);
                 processResponse(rre);
             }catch(Exception ex){
                 System.debug(LoggingLevel.WARN, 'Error occurred processing RMS Response: ' + ex.getMessage());
                 handleError(request, responseText);
             }
         }
        
        /**
         * Update status to finish query and mark errors for RMS responses
         */ 
        protected void handleError(AWSC_Request request, String responseText){
            try{
                String messageCode = '';
                String messageDesc = '';
                String rmsResp = '';
                //Check if error is in deserialisation
                RMSResponseEnvelope rre;
                try{
                     rre = (RMSResponseEnvelope)JSON.deserializeStrict(responseText, RMSResponseEnvelope.class);
                     messageCode = rre.getMessageCode();
                     messageDesc = rre.getMessageDescription();
                     rmsResp = JSON.serialize(rre);
                }catch(Exception rmsResponseEx){
                     messageCode = 'System Error';
                     messageDesc = 'Deserialisation Error in RMS Response';
                     rmsResp = 'Unable to deserialise RMS Response';
                }
                
                AWSC_ServiceRestRequest sRequest = (AWSC_ServiceRestRequest)request;
                RMSRequestEnvelope params = (RMSRequestEnvelope)sRequest.getParams();
                
                RMSRequestEnvelope.RMSRequestBody requestBody = params.getBody();
                
                Id dvdQueryId = requestBody.queryParam.Id;
                DVD_Query__c dvdQuery = [SELECT Id, DVD_Entity__c, DVD_Ext_Transaction_ID__c, 
                                            Overall_Result__c, Result_Code__c, DVD_Query_For__c, P2P_Eligibility__c,
                                            Result_Message__c 
                                         FROM DVD_Query__c 
                                         WHERE Id = :dvdQueryId];
    
                //STATUS_ERROR : DATA VALIDATION | SYSTEM ERROR
                dvdQuery.Overall_Result__c = rre.getOverallStatus();
                dvdQuery.Eligibility_Status__c = null;
                dvdQuery.Traffic_Light_Indicator__c = 'Unknown';
                dvdQuery.Result_Code__c = messageCode;
                dvdQuery.Result_Message__c = messageDesc;
                dvdQuery.Response__c = rmsResp;
    
                dvdQuery.Query_Status__c = 'Completed';
    
                //set into state so visitor can loopback to access these
                updatedQuery = dvdQuery;
                updatedEntity = updateEntity(dvdQuery, null);
            }catch(Exception ex){
                System.Debug(LoggingLevel.ERROR, 'Unable to handle Error in RMS Response - ' + ex.getMessage());
            }
        }
        
        /**
         * Update status into DVDQuery record
         * Update status into DVDEntity record
         */
        protected void processResponse(RMSResponseEnvelope rre){
            Id dvdQueryId = rre.getQueryId();
            Id dvdQueryType = rre.getQueryType();
            DVD_Query__c dvdQuery = [SELECT Id, DVD_Entity__c, DVD_Ext_Transaction_ID__c,
                                        Overall_Result__c, Result_Code__c, DVD_Query_For__c, P2P_Eligibility__c,
                                        Result_Message__c 
                                     FROM DVD_Query__c 
                                     WHERE Id = :dvdQueryId];
            dvdQuery.DVD_Ext_Transaction_ID__c = rre.getExternalTransactionId();
            dvdQuery.Overall_Result__c = rre.getOverallStatus();
            if(dvdQuery.Overall_Result__c == STATUS_SUCCESS && CODE_DATA_VALIDATION != rre.getMessageCode()){
                //this can still be Y or N (PASS or FAIL)
                dvdQuery.Eligibility_Status__c = rre.getEligibilityStatus();
                if(dvdQuery.Eligibility_Status__c == 'Y'){
                    dvdQuery.Traffic_Light_Indicator__c = 'Green';
                } else {
                    dvdQuery.Traffic_Light_Indicator__c = 'Red';
                }
                String inspectionDate = rre.getAisInspectionDate();
                if(inspectionDate != null){
                    Date lastInspectionDate = Date.valueOf(inspectionDate);
                    dvdQuery.Last_AIS_Inspection_Date__c = lastInspectionDate;
                }
            } else {
                //STATUS_ERROR : DATA VALIDATION
                dvdQuery.Eligibility_Status__c = null;
                dvdQuery.Traffic_Light_Indicator__c = 'White';
                dvdQuery.Result_Code__c = rre.getMessageCode();
                dvdQuery.Result_Message__c = rre.getMessageDescription();
            }
            
            dvdQuery.Query_Status__c = 'Completed';
            dvdQuery.Response__c = JSON.serialize(rre);

            //set into state so visitor can loopback to access these
            updatedQuery = dvdQuery;
            updatedEntity = updateEntity(dvdQuery, rre);
        }
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            if(visitor != null) visitor.visit(this);
        }
        protected abstract DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSResponseEnvelope rre);
    }
    public class P2PDVDAppLicenceResponseParser extends P2PDVDAppResponseParser {

        public P2PDVDAppLicenceResponseParser(AWSC_ServiceResource parent){
            super(parent);
        }
        protected override DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSResponseEnvelope rre){
            System.debug('Updating Response for Driver Request into Driver');
            DVD_Entity__c dvdEntity = [SELECT Id, Licence_Check__c, Transaction_Id__c, 
                                            Last_DVD_Check_date__c, DVD_Status__c, P2P_Eligibility__c,
                                          Date_of_Birth__c, Last_Name__c, Drivers_Licence_Number__c
                                       FROM DVD_Entity__c 
                                       WHERE Id = :dvdQuery.DVD_Entity__c];
            dvdEntity.Licence_Check__c = dvdQuery.Traffic_Light_Indicator__c;            
            dvdEntity.Transaction_Id__c = dvdQuery.DVD_Ext_Transaction_ID__c;
            dvdEntity.Last_DVD_Check_date__c = System.now();
            dvdEntity.DVD_Status__c = dvdQuery.Overall_Result__c;
            return dvdEntity;
        }
    }
    public class P2PDVDAppVehicleResponseParser extends P2PDVDAppResponseParser {
        public P2PDVDAppVehicleResponseParser(AWSC_ServiceResource parent){
            super(parent);
        }

        protected override DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSResponseEnvelope rre){
            System.debug('Updating Response for Vehicle Request into Vehicle');            
            DVD_Entity__c dvdEntity = [SELECT Id, Vehicle_Check__c, Transaction_Id__c, 
                                            Last_DVD_Check_date__c, DVD_Status__c, P2P_Eligibility__c
                                       FROM DVD_Entity__c 
                                       WHERE Id = :dvdQuery.DVD_Entity__c];
            
            dvdEntity.Vehicle_Check__c = dvdQuery.Traffic_Light_Indicator__c;
            dvdEntity.Last_AIS_Inspection_Date__c = dvdQuery.Last_AIS_Inspection_Date__c;
            dvdEntity.Transaction_Id__c = dvdQuery.DVD_Ext_Transaction_ID__c;
            dvdEntity.Last_DVD_Check_date__c = System.now();
            dvdEntity.DVD_Status__c = dvdQuery.Overall_Result__c;
            return dvdEntity;
        }
    }
    public class P2PDVDAppAssessmentResponseParser extends P2PDVDAppResponseParser {
        public P2PDVDAppAssessmentResponseParser(AWSC_ServiceResource parent){
            super(parent);
        }

        protected override DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSResponseEnvelope rre){
            System.debug('Not updating Entity for Assessment Query Response');
            return null;
        }
    }
    
    /**
     * Visitor to sweep response data into one container for bulk update
     */
    public class P2PDVDAppResponseParserVisitor implements AWSC_ResponseParserVisitor{

        private List<DVD_Query__c> updatedQueries;
        private List<DVD_Entity__c> updatedEntities;
        private Boolean isRetried = false;
        
        public P2PDVDAppResponseParserVisitor(){
            updatedQueries = new List<DVD_Query__c>();
            updatedEntities = new List<DVD_Entity__c>();
        }
        
        public P2PDVDAppResponseParserVisitor(Boolean isRetried){
            this();
            this.isRetried = isRetried;
        }
        
        private void addQuery(DVD_Query__c q){ if(q != null) updatedQueries.add(q); }
        private void addEntity(DVD_Entity__c e){ if(e != null) updatedEntities.add(e); }

        public void visit(AWSC_ResponseParser responseParser){
            System.debug('Visitor: Adding Query & Entity to list for bulk updates ');
            P2PDVDAppResponseParser p2pResponseParser = (P2PDVDAppResponseParser)responseParser;
            
            //TODO: DRIVER INELIGIBILITY CHECK HERE
            //Query for Driver in Ineligible_Drivers__c by DOB, LName & DL, Auth Status Start Date <=Today <= Auth Status Date 
            //If record exists -> mark FAIL, else PASS
            DVD_Query__c q = p2pResponseParser.getUpdatedQuery();
            DVD_Entity__c e = p2pResponseParser.getUpdatedEntity();
            
            List<Ineligible_Drivers__c> ineligibleDrivers = [SELECT Id FROM Ineligible_Drivers__c
                                                                WHERE Driver_Date_of_Birth__c = :e.Date_of_Birth__c
                                                                AND Driver_Last_Name__c = :e.Last_Name__c
                                                                AND Driver_Licence_Number__c = :e.Drivers_Licence_Number__c
                                                                AND Traffic_Light_Indicator__c = 'Fail'];
            
            q.P2P_Eligibility__c = ineligibleDrivers.size()>0 ? 'Fail' : 'Pass';
            q.Request_Retried__c = isRetried;

            System.debug('Q=' + e.Date_of_Birth__c + ',' + e.Last_Name__c + ',' + e.Drivers_Licence_Number__c + ',' + q.P2P_Eligibility__c);
            
            //mirror DVDQuery P2PElibility status to DVDEntity
            e.P2P_Eligibility__c = q.P2P_Eligibility__c;
            addEntity(e);
            addQuery(q);
            //System.debug('Visitor: Overall Status of Query: ' + p2pResponseParser.getUpdatedQuery().Overall_Result__c);
        }
        
        public void updateResponses() {
            if(!updatedQueries.isEmpty()) {
                update updatedQueries;
            }
            if(!updatedEntities.isEmpty()) {
                update updatedEntities;
            }
            System.debug('Visitor: Bulk updated Query & Entity');
        }
    }
    
    public abstract class P2PDVDAppRestServiceResource extends AWSC_RestServiceResource {
        

        //Hook to hold any callback action data from ResponseParsing
        private AWSC_ResponseParserVisitor visitor;

        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected override AWSC_RequestBuilder getRequestBuilder() {
            return new P2PDVDAppRequestBuilder(this);
        }
                
        /**
         * return the service locator
         */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new P2PDVDAppServiceConfig();
            }
            return serviceLocator ;
        }
        
        /**
         * return the authentication strategy
         */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new P2PDVDAppAuthStrategy();
        }
    
        
        //constructors
        public P2PDVDAppRestServiceResource() {
            super();
        }
        public P2PDVDAppRestServiceResource(Object params) {
            super(params);
        }        
        public P2PDVDAppRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
            super(params);
            this.visitor = visitor;
        }        
        
        
        /**
         * fire the defensive (retry loaded) call to the service
         */
        public void defensiveInvoke(){
            request = getRequestBuilder().buildRequest(requestParams);
            AWSC_Response response;
            if(Test.isRunningTest()) {
                response = new RMSDVDAPIMockImpl().execute((AWSC_ServiceRestRequest)request);
            } else{
                response = client.request(request);
                //@XXX - using mock directly 
                //response = new RMSDVDAPIMockImpl().execute((AWSC_ServiceRestRequest)request);
            }
            AWSC_ResponseParser responseParser = getResponseParser();
            responseParser.parseResponse(request, response);

            //use the visitor to do the bulk database commits etc.
            responseParser.accept(this.visitor);
        }
    }
    
    /**
    * Set the method endpoint 
    * '/License'             - for Eligibility Licence check
    * '/Registration'        - for Vehicle Registration check
    * '/RetrieveAssessment'  - for querying prev. DVD Transaction
    */
    public class P2PDVDAppLicenceResource extends P2PDVDAppRestServiceResource {
        public P2PDVDAppLicenceResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return ''; /*Label.RMS_Licence_Resource_Path;*/ }
        /** return the service response for licence resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PDVDAppLicenceResponseParser(this);
        }
    }
    public class P2PDVDAppRegistrationResource extends P2PDVDAppRestServiceResource {
        public P2PDVDAppRegistrationResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return Label.RMS_Registration_Resource_Path; }
        /** return the service response for licence resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PDVDAppVehicleResponseParser(this);
        }
    }
    public class P2PDVDAppRetrieveAssessmentResource extends P2PDVDAppRestServiceResource {
        public P2PDVDAppRetrieveAssessmentResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return Label.RMS_Assessment_Resource_Path; }
        /** return the service response for licence resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PDVDAppAssessmentResponseParser(this);
        }

    }   
    
    
    
    /**
     * Unified interface endpoint for invoking the callout to RMS
     * This method will switch between the callout resources based on passed parameter DVD_Query__c
     */
    
    private final String QUERY_TYPE_ELIGIBILITY = 'Driver';
    private final String QUERY_TYPE_REGISTRATION = 'Vehicle';
    private final String QUERY_TYPE_ASSESSMENT = 'Assessment';
    
    public void callDVDApp(DVD_Query__c queryParam, AWSC_ResponseParserVisitor visitor){
        String queryType = queryParam.DVD_Query_For__c;
        //should throw an exception if no query for found
        if(String.isEmpty(queryType)){
            throw new AWSC_Exception('No DVD_Query_For value set in param. Unable to understand which query to fire.');
        }
        P2PDVDAppRestServiceResource resource;
        if(queryType == QUERY_TYPE_ELIGIBILITY){
            resource = new P2PDVDAppClient.P2PDVDAppLicenceResource(queryParam, visitor);
        }else if(queryType == QUERY_TYPE_REGISTRATION){
            resource = new P2PDVDAppClient.P2PDVDAppRegistrationResource(queryParam, visitor);
        }else if(queryType == QUERY_TYPE_ASSESSMENT){
            resource = new P2PDVDAppClient.P2PDVDAppRetrieveAssessmentResource(queryParam, visitor);
        }
        resource.defensiveInvoke();
        return;
    }
}