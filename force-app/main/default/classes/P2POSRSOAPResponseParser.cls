/**
* @name P2POSRSOAPResponseParser
* @usage this class represent response parser for all OSR SOAP requests, this will populate request, response
* response status, and response body from actual callout response.  these attributes will then be used by visitors if available
* to perform post callout operations.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRSOAPResponseParser implements AWSC_ResponseParser  {

    private AWSC_ServiceResource parent;
    
    @TestVisible public String responseText { get; set; }
    @TestVisible public Integer responseStatus { get; set; }
    
    protected AWSC_Request request;
    protected AWSC_Response response;

    public P2POSRSOAPResponseParser(AWSC_ServiceResource parent) { this.parent = parent;
    }
    
    public P2POSRRPCServiceResource getOriginal () { return (P2POSRRPCServiceResource) this.parent; }
    
    /** interface implementation */
    public virtual void parseResponse(AWSC_Response response) { this.parseResponse(null, response);
    }

    /** this method populated class attributes */
    public virtual void parseResponse(AWSC_Request request, AWSC_Response response) {
        this.request = request;
        this.response = response;
        this.responseText = response.getResponseText();
        this.responseStatus = response.getResponseStatus();
        System.debug('status : ' + this.responseStatus + ' text : ' + this.responseText);
    }
    
    /** if visitor is passed to the caller, then this method will call the visit method to pass on post callout operations. */
    public void accept(AWSC_ResponseParserVisitor visitor){ if(visitor != null) visitor.visit(this);
    }
}