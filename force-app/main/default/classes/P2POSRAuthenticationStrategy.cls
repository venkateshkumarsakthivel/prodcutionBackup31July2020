/**
* @name P2POSRAuthenticationStrategy
* @usage this class will take care of authentication of the request, to set SSL certificates in OSR case.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRAuthenticationStrategy implements AWSC_AuthenticationStrategy  {
    /*Default overrides */
    public Boolean checkLoggedIn() { return true; }
    public Boolean authenticate() { return true; }

    
    /** @TODO Load from settings */ 
    public P2POSRAuthenticationStrategy(){}
    
    /** Load and set certificates into the request for Client Authentication */
    public void decorateRequestWithCredential(HttpRequest request) {
    	Revenue_NSW_Config__mdt rnswConfiguration = P2POSRConfiguration.get();
    	request.setClientCertificateName(rnswConfiguration.Certificate__c);
    }
}