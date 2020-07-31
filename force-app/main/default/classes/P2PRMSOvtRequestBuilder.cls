/**
     * Request Builder for OVT App Query to RMS
     */
public with sharing class P2PRMSOvtRequestBuilder implements AWSC_RequestBuilder {
	private AWSC_ServiceResource parent;
	public P2PRMSOvtRequestBuilder(AWSC_ServiceResource parent) {
		 this.parent = parent;
	}
	public AWSC_Request buildRequest(Object reqParams) {
			AWSC_Request request; 
			//REST - PATCH
			//Params should be of type Case
			if((reqParams != null) && (reqParams instanceof Case)) {
				request = new AWSC_ServiceRestRequest(parent, parent.getServiceLocator());
				request.method = AWSC_Request.RequestMethod.PATCH;

				Case caseParams = (Case)reqParams;
				Object queryParams = RMSOVTRequestEnvelope.build(caseParams);
				System.debug('****RMSRequestEnvelope****');
				System.debug(JSON.serialize(queryParams));
				

				((AWSC_ServiceRestRequest)request).setParams(queryParams);
			} else {
                throw new AWSC_Exception('Invalid Request Params - required type = Case');
			}
           
             request.contentType = 'application/json';
             //add any headers required here..
             return request;
         }
}