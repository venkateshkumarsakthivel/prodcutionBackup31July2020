public with sharing class P2PRMSClient {
	public Enum RMS_REQUEST_TYPE{OVERTURN_CRIMINAL_OFFENCE}
	
	public P2PRMSRestServiceResource resource { get; set; }

	 public void call(RMS_REQUEST_TYPE requestType, AWSC_ResponseParserVisitor visitor, Case caseParam)  {
	 	try{
		 	if(requestType==RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE){
		 		resource=new P2PRMSOvtOffenceResource(caseParam,visitor);
		 	    resource.execute();
		 	}
	        return;
	    }
	    catch(Exception ex){
	    	System.debug('ex::::====='+ex);
	    	ApplicationLogUtility.logMessage('Error','P2PRMSClient','call',ex.getMessage(),ex);

	    	Case caseInstance=new Case();
            caseInstance.id=caseParam.Id;
            caseInstance.RMS_Response_DateTime__c=System.Now();
            Group sanction2=[SELECT Id FROM group Where Name ='Sanctions Level 2'];
            caseInstance.Status=GlobalConstants.LODGED_CASE_STATUS;
            caseInstance.Sub_Status__c=GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
            caseInstance.ownerId=sanction2.id;
            caseInstance.RMS_Response__c='Error :'+ ex.getMessage();
            update caseInstance;
			
	    	
	    }
	    finally{
	    	return;
	    }
	 }
}