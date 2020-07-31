/**
* @name P2POSRClientDetails
* @usage this class will hold attributes required by client details parameters within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRClientDetails {
	public P2POSRIndividualClient individual { get; set; }
	public P2POSRCompanyClient company { get; set; }
	
	/* default constructor */
	public P2POSRClientDetails()  {}
	
	/* constructor with attributes  to populate */
	public P2POSRClientDetails(P2POSRIndividualClient individual, P2POSRCompanyClient company)  {
		this.individual = individual;
		this.company = company;
	}
    
    public String toXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        	if(null != this.individual) xmlStreamWriter.writeCharacters(this.individual.toXML('individual'));
        	if(null != this.company) xmlStreamWriter.writeCharacters(this.company.toXML('company'));
		
		xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml;
    }
}