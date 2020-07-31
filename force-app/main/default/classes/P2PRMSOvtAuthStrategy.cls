public with sharing class P2PRMSOvtAuthStrategy implements AWSC_AuthenticationStrategy{
    /*Default overrides */
        public Boolean checkLoggedIn() { return true; }
        public Boolean authenticate() { return true; }
        
       /**Self signed cert for use with RMS API for Mutual Auth*/
        public final String P2P_RMS_MA_CERT_NAME;
        
        private final String userPass;
        
         public P2PRMSOvtAuthStrategy(){}
        /**
        * @TODO Load from settings
        */ 
        public P2PRMSOvtAuthStrategy(P2PRMSClient.RMS_REQUEST_TYPE requestType){
           userPass = Label.RMS_Checks_UserName + ':' + Label.RMS_Checks_Password;
           if(requestType==P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE){
               P2P_RMS_MA_CERT_NAME = P2PRmsOvtConfigReader.getCertificateName();
           }
        }
        
       /**
        * Load and set certificates into the request 
        * for Client Authentication with RMS
        * Set any other headers - Basic Auth etc. required
        */
        public void decorateRequestWithCredential(HttpRequest request) {
            request.setClientCertificateName(P2P_RMS_MA_CERT_NAME);

           //Basic Auth
            String encodedUserPass = EncodingUtil.base64Encode(Blob.valueOf(userPass));
            request.setHeader('Authorization', 'Basic ' + encodedUserPass);
            return;
       }
}