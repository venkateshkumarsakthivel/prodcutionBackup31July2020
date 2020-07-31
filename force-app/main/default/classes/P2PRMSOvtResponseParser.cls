public with sharing class P2PRMSOvtResponseParser implements AWSC_ResponseParser {
	
	protected final String STATUS_ERROR = 'ERROR';
    protected final String STATUS_SUCCESS = 'SUCCESS';
	private AWSC_ServiceResource parent;
	private Case updatedCase;
      
	public Case getUpdatedCase(){ 
		return updatedCase;
	}
    
   public P2PRMSRestServiceResource getOriginal () { return (P2PRMSRestServiceResource) this.parent; } 

    public P2PRMSOvtResponseParser(AWSC_ServiceResource parent) {
        this.parent = parent;
    }

    public void parseResponse(AWSC_Response response) {
        parseResponse(null, response);
    }
	
	public void parseResponse(AWSC_Request request, AWSC_Response response) {
        System.debug('response.getResponseText()====='+response.getResponseText());
        System.debug('response====='+response);
        System.debug('request====='+request);
         System.debug('request.getServiceResource====='+request.getServiceResource());
         //System.debug('request.headers====='+request.getheaders());

        Integer responseStatus = response.getResponseStatus();
        String responseText = response.getResponseText();
        Integer responseStatusCode=response.getResponseStatus();
        responseText = responseText.replaceAll('"class":','"propertyClass":');
        System.debug('responseText====');
        System.debug(responseText);
        System.debug('responseStatusCod==='+responseStatusCode);
        try{
            

            ApplicationLogMessage applicationLogMessage1 = new ApplicationLogMessage();
            applicationLogMessage1.debugLevel = GlobalConstants.INFO; 
            //applicationLogMessage.payload = requestParameters.get(p2POSRAssessmentResponse.levyAssessmentID);
            applicationLogMEssage1.logCode = 'RMS Criminal Charge Correction Response :' + response.getResponseStatus();
            applicationLogMessage1.logMessage = response.getResponseText();
            applicationLogMessage1.source = 'P2PRMSOvtResponseParser'; 
            applicationLogMessage1.sourceFunction = 'parseResponse';
            

            ApplicationLogUtility.logMessage(applicationLogMessage1);  

            //Strict deserialization: if there are param mismatches, this will throw an exception
         	RMSOVTResponseEnvelope ovtResponseEnvelope = (RMSOVTResponseEnvelope)JSON.deserializeStrict(responseText, RMSOVTResponseEnvelope.class);
            System.debug('==='+ovtResponseEnvelope);
            processResponse(ovtResponseEnvelope,responseStatusCode);
        }catch(Exception ex){
            System.debug(LoggingLevel.WARN, 'Error occurred processing RMS OVT Response: ' + ex.getMessage());
            ApplicationLogUtility.logMessage(STATUS_ERROR,'P2PRMSOvtResponseParser','parseResponse',ex.getMessage(),ex);
            handleError(request, responseText);
        }
    }
        
        /**
         * Update status to finish query and mark errors for RMS responses
         */ 
        private void handleError(AWSC_Request request, String responseText){
            try{
                String rmsOvtResponse = '';
                //Check if error is in deserialisation                  
                RMSOVTResponseEnvelope ovtResponseEnvelope = (RMSOVTResponseEnvelope)JSON.deserializeStrict(responseText, RMSOVTResponseEnvelope.class);
                rmsOvtResponse = JSON.serialize(ovtResponseEnvelope);
            }catch(Exception ex){
            	System.Debug(LoggingLevel.ERROR, 'An error occurred processing RMS Criminal Charge Correction Response: ' + ex.getMessage());
                
                throw new AWSC_Exception('An error occurred processing RMS Criminal Charge Correction Response. '+ ex.getMessage());
            }
        }
        
        /**
         * Update status into case record
         *
         */
        private void processResponse(RMSOVTResponseEnvelope ovtResponseEnvelope,Integer responseStatusCode){
            
            Id caseId = ovtResponseEnvelope.getQueryId();
            
            System.debug('Overall status==='+ovtResponseEnvelope.getOverallStatus());
            if(ovtResponseEnvelope.getOverallStatus() == STATUS_SUCCESS){
                Case caseInstance=new Case();
                caseInstance.id=caseId;
                caseInstance.RMS_Response_DateTime__c=System.Now();
                caseInstance.Status=GlobalConstants.CLOSED_CASE_STATUS;
                caseInstance.Sub_Status__c=GlobalConstants.APPROVED_CASE_SUB_STATUS;
                caseInstance.RMS_Response__c=STATUS_SUCCESS+' '+responseStatusCode+': Charge corrected';
                //caseInstance.OwnerId= userinfo.getUserId();
                updatedCase = caseInstance;

            }else if(ovtResponseEnvelope.getOverallStatus() == STATUS_ERROR) {
                Case caseInstance=new Case();
                caseInstance.id=caseId;
                caseInstance.RMS_Response_DateTime__c=System.Now();
                case caseObj=[select id,ownerId from case where id=:caseId limit 1];
                Group sanction2=[SELECT Id FROM group Where Name ='Sanctions Level 2'];
                system.debug('errorDescription=='+ovtResponseEnvelope.getMessageDescription());
                system.debug('error code=='+ovtResponseEnvelope.getMessageCode());


                caseInstance.Status=GlobalConstants.LODGED_CASE_STATUS;
                caseInstance.Sub_Status__c=GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
                caseInstance.ownerId=sanction2.id;
                 system.debug('caseObj.ownerId=='+caseObj.ownerId);

            	if(responseStatusCode != null && responseStatusCode==428){
            		
                    caseInstance.RMS_Response__c=STATUS_ERROR+' '+responseStatusCode+' : Charge Number and Offence Code not found in DVD App.';
                }
            	else if(responseStatusCode != null && responseStatusCode==400){
            		
                    caseInstance.RMS_Response__c=STATUS_ERROR+' '+responseStatusCode+' : Cannot find an active record for this Law Part Code.';
                }
                else{
                    
                    caseInstance.RMS_Response__c=STATUS_ERROR+' '+responseStatusCode+' : '+ovtResponseEnvelope.getMessageDescription();
                }    
                 updatedCase = caseInstance;

            }

            system.debug('updatedCase==='+updatedCase);
            
            
        }
        
        public void accept(AWSC_ResponseParserVisitor visitor){
            if(visitor != null) visitor.visit(this);
        }
   
}