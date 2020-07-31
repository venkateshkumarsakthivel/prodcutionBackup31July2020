/**
* @name P2POSRCompanyClient
* @usage this class will hold attributes required by company client details parameters within clientDetails attribute within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRCompanyClient {
    public String name { get; set; } /* maximum length 250 characters. */
    public String contactName { get; set; } /* Optional, maximum length 50 characters. */
    public String acn { get; set; } /* Optional, maximum length 9 characters, Pattern: [0-9]{9,9} */
    public String arbn { get; set; } /* Optional, maximum length 9 characters, Pattern: [0-9]{9,9} */
    
    /* default constructor */
    public P2POSRCompanyClient()  {}
    
    /* constructor with attributes  to populate */
    public P2POSRCompanyClient(String name, String contactName, String acn, String arbn)  {
        if(String.isNotBlank(name)) {
             this.name = (name.Length() < 251) ?  name : name.substring(0, 250); }
        if(String.isNotBlank(contactName)) {
            this.contactName = (contactName.Length() < 51) ?  contactName : contactName.substring(0, 50); }
        if(String.isNotBlank(acn)) {
            this.acn = (acn.Length() < 10) ?  acn : acn.substring(0, 9); }
        if(String.isNotBlank(arbn)) {
            this.arbn = (arbn.Length() < 10) ?  arbn : arbn.substring(0, 9); }
            
        System.debug(LoggingLevel.INFO, 'Name: ' + name);
        System.debug(LoggingLevel.INFO, 'Contact Name: ' + contactName);
        System.debug(LoggingLevel.INFO, 'ACN: ' + acn);
        System.debug(LoggingLevel.INFO, 'ARBN: ' + arbn);
    }
    
    public String toXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        
        if(String.isNotBlank(this.name))  {
            xmlStreamWriter.writeStartElement(null, 'name', null); xmlStreamWriter.writeCharacters(this.name); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.contactName))  {
            xmlStreamWriter.writeStartElement(null, 'contactName', null); xmlStreamWriter.writeCharacters(this.contactName); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.acn))  {
            xmlStreamWriter.writeStartElement(null, 'acn', null); xmlStreamWriter.writeCharacters(this.acn); xmlStreamWriter.writeEndElement();             
        }
        if(String.isNotBlank(this.arbn))  {
            xmlStreamWriter.writeStartElement(null, 'arbn', null); xmlStreamWriter.writeCharacters(this.arbn); xmlStreamWriter.writeEndElement();
        }
        
        xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHTML4();
        xmlStreamWriter.close();
        return xml;
    }
}