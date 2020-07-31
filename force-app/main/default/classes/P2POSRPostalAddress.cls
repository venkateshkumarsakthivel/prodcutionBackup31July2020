/**
* @name P2POSRPostalAddress
* @usage this class will hold attributes required by Postal address parameters within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRPostalAddress {
    public String addressLine1 { get; set; } /* maximum length 50 characters. */
    public String addressLine2 { get; set; } /* maximum length 50 characters. Also options for request. */
    public String suburb { get; set; } /* maximum length 50 characters. */
    public String postCode { get; set; } /* maximum length 4 characters. */
    public String state { get; set; } /* maximum lenth 3 characters. Possible values [QLD, NSW, ACT, VIC, TAS, SA, WA, NT] */
    
    /* default constructor */
    public P2POSRPostalAddress() {}
    
    /* constructor to create instance of P2POSRProviderDetail with attribute population. */
    public P2POSRPostalAddress(String addressLine1, String addressLine2, String suburb, String postCode, String state)  {
        if(String.isNotBlank(addressLine1)) {
            if(addressLine1.Length() < 51) {
                this.addressLine1 =  addressLine1;
                this.addressLine2 = null;
            }else{
                this.addressLine1 =  addressLine1.substring(0, 50);
                this.addressLine2 =  addressLine1.substring(50, 50);
            }
        }
        if(String.isNotBlank(suburb)) {
            this.suburb = (suburb.Length() < 51) ?  suburb : suburb.substring(0, 50); }
        if(String.isNotBlank(postCode)) {
            this.postCode = ( postCode.Length() < 5) ?  postCode : postCode.substring(0, 4);}
        if(String.isNotBlank(state)) {
            this.state = (state.Length() < 4) ?  state : state.substring(0, 3);}
    }
    
    public String toXML(String wrapperTag)  {
        
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        if(String.isNotBlank(this.addressLine1))  {
        xmlStreamWriter.writeStartElement(null, 'addressLine1', null); xmlStreamWriter.writeCharacters(this.addressLine1); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.addressLine2))  {
            xmlStreamWriter.writeStartElement(null, 'addressLine2', null); xmlStreamWriter.writeCharacters(this.addressLine2); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.suburb))  {
            xmlStreamWriter.writeStartElement(null, 'suburb', null); xmlStreamWriter.writeCharacters(this.suburb); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.postCode))  {
        xmlStreamWriter.writeStartElement(null, 'postCode', null); xmlStreamWriter.writeCharacters(this.postCode); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.state))  {
        xmlStreamWriter.writeStartElement(null, 'state', null); xmlStreamWriter.writeCharacters(this.state); xmlStreamWriter.writeEndElement();
        }
        xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        return xml;   
    }
}