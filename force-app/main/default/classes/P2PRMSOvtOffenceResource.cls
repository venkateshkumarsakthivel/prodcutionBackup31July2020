public with sharing class P2PRMSOvtOffenceResource extends P2PRMSRestServiceResource {
	
	public P2PRMSOvtOffenceResource (Object reqParams, AWSC_ResponseParserVisitor visitor) { super (reqParams, visitor);}
    
    /** return the relative uri path to the resource */
    public override String getResourcePath(){ return ''; }
    
    /** return the service response for offence resource implementation */
    protected override AWSC_ResponseParser getResponseParser(){
        return new P2PRMSOvtResponseParser(this);
    }

     //public Object getRequestParameters() { return this.requestParams; }
}