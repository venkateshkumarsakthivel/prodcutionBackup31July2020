/**
* @name P2POSR_SOAPServiceLocator
* @usage this class will perform populating SOAP service endpoint, version.  Instance of this class will be called
* by every OSR related resource to find SOAP service endpoint.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSR_SOAPServiceLocator implements AWSC_ServiceLocator {
    
    /** endpoint - should be the FQDN without additional service path */
    private String endpoint = null;
    
    /**set the endpoint explicitly to override config values runtime */
    public void setEndpoint(String endpoint){
        this.endpoint = endpoint;
    }
    
    /*** provide the endpoint for the sample webservice client implementation */
    public String endpoint() {
    	Revenue_NSW_Config__mdt rnswConfiguration = P2POSRConfiguration.get();
        this.endpoint = rnswConfiguration.Endpoint__c;
        return this.endpoint;
    }
    
    /*** provide the service version - for backward compatibility checks */
    public String version(){
        return '1.0.0';
    }
}