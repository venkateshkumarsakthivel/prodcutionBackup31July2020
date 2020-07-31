public with sharing class P2PRMSOvtServiceConfig implements AWSC_ServiceLocator {
    P2PRMSClient.RMS_REQUEST_TYPE requestType;
    public P2PRMSOvtServiceConfig() {
        
    }
    public P2PRMSOvtServiceConfig(P2PRMSClient.RMS_REQUEST_TYPE requestType) {
        this.requestType=requestType;
    }

    public void setEndpoint(String endpoint) {
            //this.endpoint = baseUrl + basePath + version();
    }

    public String endpoint() {
        if(this.requestType==P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE){
            return P2PRmsOvtConfigReader.getEndpoint();
        }
        return null;                
    }
    
   public String version() {
        return '';  
    }
}