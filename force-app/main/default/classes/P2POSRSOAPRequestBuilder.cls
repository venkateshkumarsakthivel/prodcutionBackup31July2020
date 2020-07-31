/**
* @name P2POSRSOAPRequestBuilder
* @usage this abstract holds common soap envelop pre body and post body structure with security header
* security header will hold username and password configured in SF system as custom labels
* @author Arxxus P2P developer team
*/
abstract public class P2POSRSOAPRequestBuilder implements AWSC_RequestBuilder  {
        
        /** handle to outer class for instance variables */
        protected AWSC_ServiceResource parent { get; set; }
        protected String preFixRequestBodyTag { get; set; }
        protected String postFixRequestBodyTag { get; set; }
        protected String requestBody { get; set; }
        abstract public AWSC_Request buildRequest(Object requestParameters);

        /** SOAP request pre body structure with security header. */
        public String preFixXML()  {
            Revenue_NSW_Config__mdt rnswConfiguration = P2POSRConfiguration.get();
        	return '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' + 
                '<soapenv:Header><tns:security xmlns:tns="http://ptp.ws.mars.osr.nsw.gov.au/">' +
                '<username>' + rnswConfiguration.Username__c + '</username>' +
                '<password>' + rnswConfiguration.Password__c + '</password>' +
                '</tns:security></soapenv:Header><soapenv:Body>'; 
        }
        /** SOAP request post body structure with proper closure of envelop tags. */
        public String postFixXML()  { return '</soapenv:Body></soapenv:Envelope>';
        }

    
}