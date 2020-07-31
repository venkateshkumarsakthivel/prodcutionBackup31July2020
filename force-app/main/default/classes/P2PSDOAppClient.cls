/**
 * SDO App Client 
 * Defines and Exposes the services required for DVD 
 * by P2P commissioner & Auth. Service Providers 
 */
public class P2PSDOAppClient {

    @TestVisible
    private static Boolean TEST_FOR_ERROR = false;

    public class P2PSDOAppAuthStrategy implements AWSC_AuthenticationStrategy {
    
       /*Default overrides */
        public Boolean checkLoggedIn() { return true; }
        public Boolean authenticate() { return true; }
        
       /**Self signed cert for use with RMS API for Mutual Auth*/
        public final String P2P_RMS_MA_CERT_NAME;
        
        private final String userPass;
        
        /**
        * @TODO Load from settings
        */ 
        public P2PSDOAppAuthStrategy(){
           userPass = Label.RMS_Checks_UserName + ':' + Label.RMS_Checks_Password;
           P2P_RMS_MA_CERT_NAME = [SELECT Certificate_Name__c 
                                   FROM SDO_Configuration__mdt limit 1].Certificate_Name__c;
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
    
    public class P2PSDOAppServiceConfig implements AWSC_ServiceLocator {
        
        /**
         * Service Gateway endpoint
         * End point for SDO App: RMS API
         */ 

        //private final String baseUrl  = 'https://st-servicegateway.rms.nsw.gov.au';
        //@TODO - load from custom settings
        public P2PSDOAppServiceConfig(){
        }
        
        public void setEndpoint(String endpoint) {
            //this.endpoint = baseUrl + basePath + version();
        }

        public String endpoint() {
            return [SELECT Endpoint__c 
                    FROM SDO_Configuration__mdt limit 1].Endpoint__c;
        }
    
        public String version() {
           return '';  
        }
    }
    
    /**
     * Request Builder for DVD App Query to RMS
     */
    public class P2PSDOAppRequestBuilder implements AWSC_RequestBuilder {
        
        private AWSC_ServiceResource parent;
         
        public P2PSDOAppRequestBuilder(AWSC_ServiceResource parent) {
            this.parent = parent;
        }
       
        public AWSC_Request buildRequest(Object reqParams) {
            AWSC_Request request; 
            //REST - POST
            //Params should be of type DVD_Query__c
            if((reqParams != null) && (reqParams instanceof DVD_Query__c)) {
                request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
                request.method = AWSC_Request.RequestMethod.POST;

                DVD_Query__c sdoQueryParams = (DVD_Query__c)reqParams;
                Object queryParams = RMSSDORequestEnvelope.build(sdoQueryParams);
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

    public abstract class P2PSDOAppResponseParser implements AWSC_ResponseParser {
         
        protected final String STATUS_ERROR = 'ERROR';
        protected final String STATUS_SUCCESS = 'SUCCESS';
        protected final String CODE_DATA_VALIDATION = 'DATA VALIDATION';
        protected final String CODE_SYSTEM_ERROR = 'SYSTEM ERROR';

        private AWSC_ServiceResource parent;

        private DVD_Query__c updatedQuery;
        private DVD_Entity__c updatedEntity;

        public DVD_Query__c getUpdatedQuery(){ return updatedQuery;}
        public DVD_Entity__c getUpdatedEntity() { return updatedEntity;}

        public P2PSDOAppResponseParser(AWSC_ServiceResource parent) {
            this.parent = parent;
        }

        public void parseResponse(AWSC_Response response) {
            parseResponse(null, response);
        }

         public void parseResponse(AWSC_Request request, AWSC_Response response) {
            System.debug('====='+response.getResponseText());
            Integer responseStatus = response.getResponseStatus();
            String responseText = response.getResponseText();
            /*  if(responseStatus != 200 || responseStatus != 400 || String.isEmpty(responseText)) {
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
                //RMSSDOResponseEnvelope rre = (RMSSDOResponseEnvelope)JSON.deserializeStrict(responseText, RMSSDOResponseEnvelope.class);
                RMSSDOResponseEnvelope rre = (RMSSDOResponseEnvelope)JSON.deserializeStrict(responseText, RMSSDOResponseEnvelope.class);
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
                try{
                    
                    RMSSDOResponseEnvelope rre = (RMSSDOResponseEnvelope)JSON.deserializeStrict(responseText, RMSSDOResponseEnvelope.class);
                    messageCode = rre.getMessageCode();
                    messageDesc = rre.getMessageDescription();
                    rmsResp = JSON.serialize(rre);
                }catch(Exception rmsResponseEx){
                    messageCode = 'System Error';
                    messageDesc = 'Deserialisation Error in RMS Response';
                    rmsResp = 'Unable to deserialise RMS Response';
                }
                AWSC_ServiceRestRequest sRequest = (AWSC_ServiceRestRequest)request;
                RMSSDORequestEnvelope params = (RMSSDORequestEnvelope)sRequest.getParams();

                RMSSDORequestEnvelope.RMSRequestBody requestBody = params.getBody();
                

                Id dvdQueryId = requestBody.queryParam.Id;

                DVD_Query__c dvdQuery = [SELECT Id, DVD_Entity__c, DVD_Ext_Transaction_ID__c, 
                                                Overall_Result__c, Result_Code__c, DVD_Query_For__c, P2P_Eligibility__c,
                                                Result_Message__c 
                                         FROM DVD_Query__c 
                                         WHERE Id = :dvdQueryId];
                //STATUS_ERROR : DATA VALIDATION | SYSTEM ERROR
                dvdQuery.Overall_Result__c = STATUS_ERROR;
                dvdQuery.Eligibility_Status__c = null;
                dvdQuery.Traffic_Light_Indicator__c = 'Unknown';
                dvdQuery.SDO_Check_Status__c = 'Unknown';
                dvdQuery.Criminal_Charge_Check_Status__c  = 'Unknown';
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
        protected void processResponse(RMSSDOResponseEnvelope rre){
            FINAL String ELIGIBILITY_STATUS_FAIL = 'FAIL';
            FINAL String ELIGIBILITY_STATUS_PASS = 'PASS';
            FINAL String ELIGIBILITY_STATUS_DATA_VALIDATION = 'DATA_VALIDATION';
            
            FINAL String SDO_STATUS_FAIL = 'FAIL';
            FINAL String SDO_STATUS_PASS = 'PASS';
            FINAL String SDO_STATUS_DATA_VALIDATION = 'DATA_VALIDATION';
            
            FINAL String CC_STATUS_FAIL = 'FAIL';
            FINAL String CC_STATUS_PASS = 'PASS';
            FINAL String CC_STATUS_DATA_VALIDATION = 'DATA_VALIDATION';
            
            Id dvdQueryId = rre.getQueryId();
            Id dvdQueryType = rre.getQueryType();
            DVD_Query__c dvdQuery = [SELECT Id, DVD_Entity__c, DVD_Ext_Transaction_ID__c,PTCode_Active_Start_Date__c,PTCode_Last_Termination_Date__c,
                                        Overall_Result__c, Result_Code__c, DVD_Query_For__c, P2P_Eligibility__c,
                                        Result_Message__c 
                                     FROM DVD_Query__c 
                                     WHERE Id = :dvdQueryId];
            dvdQuery.DVD_Ext_Transaction_ID__c = rre.getTransactionId();
            dvdQuery.Overall_Result__c = rre.getOverallStatus();
            if(dvdQuery.Overall_Result__c == STATUS_SUCCESS){
                
                system.debug('PT codes');
                // Pt codes start
                 String ActiveStartDate = rre.getactiveStartDate();
                //getactiveStartDate
                if(ActiveStartDate != null){
                    Date PTCodeActiveStartDate = Date.valueOf(ActiveStartDate);
                    dvdQuery.PTCode_Active_Start_Date__c = PTCodeActiveStartDate;
                } 
                else {
                  dvdQuery.PTCode_Active_Start_Date__c=null;  
                    
                }
                String LastTerminationDate = rre.getlastTerminationDate();
                if(LastTerminationDate != null){
                    Date PTCodeLastTerminationDate = Date.valueOf(LastTerminationDate);
                    dvdQuery.PTCode_Last_Termination_Date__c = PTCodeLastTerminationDate;
                }
                else {
                   dvdQuery.PTCode_Last_Termination_Date__c = null; 
                    
                }
               system.debug('Active start date  '+ dvdQuery.PTCode_Active_Start_Date__c);
               system.debug('Termination date  '+ dvdQuery.PTCode_Last_Termination_Date__c);
			   
                // pt code end

                String licenceCheckStatus = rre.getLicenceCheckStatus();
                if(licenceCheckStatus == ELIGIBILITY_STATUS_PASS){
                    dvdQuery.Traffic_Light_Indicator__c = 'Green';
                    dvdQuery.Eligibility_Status__c = 'Y';
                } else if(licenceCheckStatus == ELIGIBILITY_STATUS_FAIL){
                    dvdQuery.Traffic_Light_Indicator__c = 'Red';
                    dvdQuery.Eligibility_Status__c = 'N';
                } else {
                    dvdQuery.Traffic_Light_Indicator__c = 'White';
                    dvdQuery.Eligibility_Status__c = 'N';
                }
                // hotfix date: Aug 18 split tenure
                //String tenureCheckStatus = rre.getLicenceCheckStatus();
                String tenureCheckStatus = rre.getTenureCheckStatus();
                //getTenureCheckStatus
                if(tenureCheckStatus == ELIGIBILITY_STATUS_PASS){
                    dvdQuery.NSW_Tenure_Check__c = 'Green';
                } else if(tenureCheckStatus == ELIGIBILITY_STATUS_FAIL){
                    dvdQuery.NSW_Tenure_Check__c = 'Red';
                } else {
                    dvdQuery.NSW_Tenure_Check__c = 'White';
                }
                
                String sdoCheckResponse = rre.getDrivingOffenceStatus();
                System.debug('sdo: '+rre.getDrivingOffenceStatus());
                if(sdoCheckResponse == SDO_STATUS_PASS){
                    dvdQuery.SDO_Check_Status__c = 'Green';
                } else if(sdoCheckResponse == SDO_STATUS_FAIL){
                    dvdQuery.SDO_Check_Status__c = 'Red';
                } else {
                    dvdQuery.SDO_Check_Status__c = 'White';
                }
                String ccCheckResponse = rre.getCriminalChargeCheckStatus();
                System.debug('Criminal Charge: '+rre.getCriminalChargeCheckStatus());
                if(ccCheckResponse == CC_STATUS_PASS){
                    dvdQuery.Criminal_Charge_Check_Status__c = 'Green';
                } else if(ccCheckResponse == CC_STATUS_FAIL){
                    dvdQuery.Criminal_Charge_Check_Status__c = 'Red';
                } else {
                    dvdQuery.Criminal_Charge_Check_Status__c = 'White';
                }
            } else {
                //STATUS_ERROR : DATA VALIDATION | SYSTEM ERROR
                dvdQuery.Traffic_Light_Indicator__c = 'Unknown';
                dvdQuery.SDO_Check_Status__c = 'Unknown';
                dvdQuery.Criminal_Charge_Check_Status__c  = 'Unknown';
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
        protected abstract DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSSDOResponseEnvelope rre);
    }
    public class P2PSDOAppLicenceResponseParser extends P2PSDOAppResponseParser {

        public P2PSDOAppLicenceResponseParser(AWSC_ServiceResource parent){
            super(parent);
        }
        protected override DVD_Entity__c updateEntity(DVD_Query__c dvdQuery, RMSSDOResponseEnvelope rre){
            System.debug('Updating Response for Driver Request into Driver');
            DVD_Entity__c dvdEntity = [SELECT Id, Licence_Check__c, Transaction_Id__c,PTCode_Active_Start_Date__c,PTCode_Last_Termination_Date__c, 
                                            Last_DVD_Check_date__c, DVD_Status__c, P2P_Eligibility__c,
                                          Date_of_Birth__c, Last_Name__c, Drivers_Licence_Number__c, Criminal_Check__c
                                       FROM DVD_Entity__c 
                                       WHERE Id = :dvdQuery.DVD_Entity__c];
            dvdEntity.Licence_Check__c = dvdQuery.Traffic_Light_Indicator__c;
            dvdEntity.NSW_Tenure_Check__c = dvdQuery.NSW_Tenure_Check__c;  
            dvdEntity.Serious_Driving_Offence__c = dvdQuery.SDO_Check_Status__c;
            dvdEntity.Criminal_Check__c = dvdQuery.Criminal_Charge_Check_Status__c;
            dvdEntity.Transaction_Id__c = dvdQuery.DVD_Ext_Transaction_ID__c;
            dvdEntity.Last_DVD_Check_date__c = System.now();
            dvdEntity.DVD_Status__c = dvdQuery.Overall_Result__c;
            dvdEntity.PTCode_Active_Start_Date__c = dvdQuery.PTCode_Active_Start_Date__c;
            dvdEntity.PTCode_Last_Termination_Date__c = dvdQuery.PTCode_Last_Termination_Date__c;
            return dvdEntity;
        }
    }
    
    /**
     * Visitor to sweep response data into one container for bulk update
     */
    public class P2PSDOAppResponseParserVisitor implements AWSC_ResponseParserVisitor{

        private List<DVD_Query__c> updatedQueries;
        private List<DVD_Entity__c> updatedEntities;
        private Boolean isRetried = false;
        
        public P2PSDOAppResponseParserVisitor(){
            updatedQueries = new List<DVD_Query__c>();
            updatedEntities = new List<DVD_Entity__c>();
        }
        
        public P2PSDOAppResponseParserVisitor(Boolean isRetried){
            this();
            this.isRetried = isRetried;
        } 
        private void addQuery(DVD_Query__c q){ if(q != null) updatedQueries.add(q); }
        private void addEntity(DVD_Entity__c e){ if(e != null) updatedEntities.add(e); }

        public void visit(AWSC_ResponseParser responseParser){
            System.debug('Visitor: Adding Query & Entity to list for bulk updates ');
            P2PSDOAppResponseParser p2pResponseParser = (P2PSDOAppResponseParser)responseParser;
            
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
            System.debug('updatedQueries: '+updatedQueries);
            System.debug('updatedEntities: '+updatedEntities);
            if(!updatedQueries.isEmpty()) {
                update updatedQueries;
            }
            if(!updatedEntities.isEmpty()) {
                update updatedEntities;
            }
            System.debug('Visitor: Bulk updated Query & Entity');
        }
    }
    
    public abstract class P2PSDOAppRestServiceResource extends AWSC_RestServiceResource {
        
        //Hook to hold any callback action data from ResponseParsing
        private AWSC_ResponseParserVisitor visitor;

        //Methods from Service Resource     
        /**
         * return the service request builder 
         * request builder - to be provided by specific resource implementation
         */
        protected override AWSC_RequestBuilder getRequestBuilder() {
            return new P2PSDOAppRequestBuilder(this);
        }
                
        /**
         * return the service locator
         */
        public override AWSC_ServiceLocator getServiceLocator() {
            if(serviceLocator == null) {
                serviceLocator = new P2PSDOAppServiceConfig();
            }
            return serviceLocator ;
        }
        
        /**
         * return the authentication strategy
         */
        protected override AWSC_AuthenticationStrategy getAuthenticationStrategy() {
            return new P2PSDOAppAuthStrategy();
        }
    
        //constructors
        public P2PSDOAppRestServiceResource() {
            super();
        }
        public P2PSDOAppRestServiceResource(Object params) {
            super(params);
        }        
        public P2PSDOAppRestServiceResource(Object params, AWSC_ResponseParserVisitor visitor) {
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
                response = new RMSSDOAPIMockImpl().execute((AWSC_ServiceRestRequest)request);
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
    public class P2PSDOAppLicenceResource extends P2PSDOAppRestServiceResource {
        public P2PSDOAppLicenceResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
        /** return the relative uri path to the resource */
        public override String getResourcePath(){ return ''; /*Label.RMS_Licence_Resource_Path;*/ }
        /** return the service response for licence resource implementation */
        protected override AWSC_ResponseParser getResponseParser(){
            return new P2PSDOAppLicenceResponseParser(this);
        }
    }    
    
    /**
     * Unified interface endpoint for invoking the callout to RMS
     * This method will switch between the callout resources based on passed parameter DVD_Query__c
     */
    public void callSDOApp(DVD_Query__c queryParam, AWSC_ResponseParserVisitor visitor) {
        String queryType = queryParam.DVD_Query_For__c;
        //should throw an exception if no query for found
        if(String.isEmpty(queryType)) {
            throw new AWSC_Exception('No DVD_Query_For value set in param. Unable to understand which query to fire.');
        }
        P2PSDOAppRestServiceResource resource = new P2PSDOAppClient.P2PSDOAppLicenceResource(queryParam, visitor);
        resource.defensiveInvoke();
        return;
    }
}