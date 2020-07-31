/**
* @name P2POSRAuthorisationResponse
* @usage this class hold attributes to store values from OSR SOAP request corresponds to authorisation create, update, and cancel
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRAuthorisationResponse {
    public String tfNSWProviderNumber { get; set; } { this.tfNSWProviderNumber = ''; }
    public String RNSWCustomerID  { get; set; } { this.RNSWCustomerID = ''; }
    public List<String> errors { get; set; }
    public List<String> faults { get; set; }
    public String type { get; set; }
    public String Status { get; set; }
    public String responseXML { get; set; }
    
    public P2POSRAuthorisationResponse()  {
        this.errors = new List<String>();
        this.faults = new List<String>();
    }
}