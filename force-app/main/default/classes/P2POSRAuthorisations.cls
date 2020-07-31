/**
* @name P2POSRAuthorisations
* @usage this will hold tsp and bsp variations of Authorisation to be passed as parameters to request
* @auhtor Arxxus P2P developer team
*/
public class P2POSRAuthorisations {
    public P2POSRAuthorisation tspAuthorisation { get; set; }
    public P2POSRAuthorisation bspAuthorisation { get; set; }
    
    public P2POSRAuthorisations() {}
    
    public P2POSRAuthorisations(P2POSRAuthorisation tspAuthorisation, P2POSRAuthorisation bspAuthorisation) {
        this.tspAuthorisation = tspAuthorisation;
        this.bspAuthorisation = bspAuthorisation;
    }
    
    public String toXML(String wrapperTag)  {
        String xml;
        System.debug(this.tspAuthorisation); System.debug(this.bspAuthorisation);
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();       
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        
        if(null != this.tspAuthorisation)  {
	       xmlStreamWriter.writeCharacters(this.tspAuthorisation.toXML('tspAuthorisation'));
        }
        if(null != this.bspAuthorisation)  {
	        xmlStreamWriter.writeCharacters(this.bspAuthorisation.toXML('bspAuthorisation'));
        }
        xmlStreamWriter.writeEndElement();   
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml; 
    }
}