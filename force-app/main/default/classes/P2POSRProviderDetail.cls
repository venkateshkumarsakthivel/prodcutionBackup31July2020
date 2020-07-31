/**
* @name P2POSRProviderDetail
* @usage this class will hold attributes required by createProviderAuthorisationRequest SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRProviderDetail {
    public String TfNSWProviderNumber { get; set; } /* maximum exclusive 9999999999 */ /* Account Customer Number */
    public String providerType { get; set; } /* possible values I or C */ 
    public String email { get; set; } /* Optional, maximum length 50 characters, pattern [^@]+@[^\.]+\..+ */
    public String tradingName { get; set; } /* Optional, maximum length 250 characters. */
    public P2POSRPostalAddress providerPostalAddress { get; set; }
    public P2POSRStreetAddress providerStreetAddress { get; set; } /* Optional */
    public String abn { get; set; } /* Optional, maximum length 11 characters, pattern [0-9]{11,11} */
    public P2POSRClientDetails clientDetails { get; set; }
    
    /* default constructor */
    public P2POSRProviderDetail()  {}
    
    /* constructor to create instance of P2POSRProviderDetail with attribute population. */
    public P2POSRProviderDetail(String TfNSWProviderNumber, String providerType, String email, String tradingName, P2POSRPostalAddress providerPostalAddress, P2POSRStreetAddress providerStreetAddress, String abn, P2POSRClientDetails clientDetails)  {
        this.TfNSWProviderNumber = TfNSWProviderNumber;
        this.providerType = providerType;
        this.email = email;
        this.tradingName = tradingName;
        this.providerPostalAddress = providerPostalAddress;
        this.providerStreetAddress = providerStreetAddress;
        if(String.isNotBlank(abn)) {
        	this.abn = (abn.Length() < 12) ?  abn : abn.substring(0, 11);
        }
        this.clientDetails = clientDetails;
    }
    
    public String toXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        	
        		if(String.isNotBlank(this.TfNSWProviderNumber))  {
	       			 xmlStreamWriter.writeStartElement(null, 'TfNSWProviderNumber', null); xmlStreamWriter.writeCharacters(this.TfNSWProviderNumber); xmlStreamWriter.writeEndElement();
                }
        		if(String.isNotBlank(this.providerType))  {
	       			 xmlStreamWriter.writeStartElement(null, 'providerType', null); xmlStreamWriter.writeCharacters(this.providerType); xmlStreamWriter.writeEndElement();
                }
	        	if(String.isNotBlank(this.email))  {
	        		xmlStreamWriter.writeStartElement(null, 'email', null); xmlStreamWriter.writeCharacters(this.email); xmlStreamWriter.writeEndElement();
	        	}
		        if(String.isNotBlank(this.tradingName))  {
	        		xmlStreamWriter.writeStartElement(null, 'tradingName', null); xmlStreamWriter.writeCharacters(this.tradingName); xmlStreamWriter.writeEndElement();
	        	}
		        if(null != this.providerPostalAddress)  {    
	           		xmlStreamWriter.writeCharacters(this.providerPostalAddress.toXML('providerPostalAddress'));
                }
                if(null != this.providerStreetAddress)  {
                    xmlStreamWriter.writeCharacters(this.providerStreetAddress.toXML('providerStreetAddress'));
                }
	        	if(String.isNotBlank(this.abn))  {
	        		xmlStreamWriter.writeStartElement(null, 'abn', null); xmlStreamWriter.writeCharacters(this.abn); xmlStreamWriter.writeEndElement();
	        	}
		        if(null != this.clientDetails)  {   
	           		xmlStreamWriter.writeCharacters(this.clientDetails.toXML('clientDetails'));
                }
        xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml;        
    }
}