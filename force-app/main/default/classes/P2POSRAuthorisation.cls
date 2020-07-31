/**
* @name P2POSRAuthorisation
* @usage this class will hold attributes required by authorisation parameters within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRAuthorisation {
    public String type { get; set; } /* maximum length 2, possible values [TT, TB] */
    public String effectiveDate { get; set; } /* Optional, pattern 2008-12-31 */
    public String BSB { get; set; } /* pattern [0-9]{6,6} */
    public String bankAccountNumber { get; set; } /* pattern [0-9]{3,9} */
    public String bankAccountName { get; set; } /* maximum length 32 characters. */
    public String contactName { get; set; } /* maximum length 50 characters. */
    public String contactPhone { get; set; } /* maximum length 15 characters, pattern ([0-9 ()+-/]){10,15} */
    public String contactEmail { get; set; } /* maximum length 50 characters, pattern [^@]+@[^\.]+\..+ */
    public P2POSRPostalAddress postalAddress { get; set; }
    public P2POSRStreetAddress streetAddress { get; set; } /* Optional */
    
    /* default constructor */
    public P2POSRAuthorisation() {}

    /* constructor with attributes  to populate */
    public P2POSRAuthorisation(String type, String effectiveDate, String BSB, String bankAccountNumber, String bankAccountName, String contactName, String contactPhone, String contactEmail, P2POSRPostalAddress postalAddress, P2POSRStreetAddress streetAddress)  {
            if(String.isNotBlank(type)) {
                this.type = (type.Length() < 3) ?  type : type.substring(0, 2); }
            this.effectiveDate = effectiveDate;
            if(String.isNotBlank(BSB)) {
                this.BSB = BSB.replaceAll('-', ''); this.BSB = (this.BSB.Length() <= 6) ?  this.BSB : this.BSB.substring(0, 6); }
            if(String.isNotBlank(bankAccountNumber)) {
                this.bankAccountNumber = (bankAccountNumber.Length() < 10) ?  bankAccountNumber : bankAccountNumber.substring(0, 9); }
            if(String.isNotBlank(bankAccountName)) {
                this.bankAccountName = (bankAccountName.Length() < 33) ?  bankAccountName : bankAccountName.substring(0, 32); }
            if(String.isNotBlank(contactName)) {
                this.contactName = (contactName.Length() < 51) ?  contactName : contactName.substring(0, 50); }
            if(String.isNotBlank(contactPhone)) {
                this.contactPhone = (contactPhone.Length() < 16) ?  contactPhone : contactPhone.substring(0, 15); }
            this.contactEmail = contactEmail;
            this.postalAddress = postalAddress;
            this.streetAddress = streetAddress;
    }
    
    public String toXML(String wrapperTag)  {
            String xml;
            Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
            xmlStreamWriter.writeStartElement(null, wrapperTag, null);
            if(String.isNotBlank(this.type))  {
            xmlStreamWriter.writeStartElement(null, 'type', null); xmlStreamWriter.writeCharacters(this.type); xmlStreamWriter.writeEndElement();
            }
            if(String.isNotBlank(this.effectiveDate))  {
                xmlStreamWriter.writeStartElement(null, 'effectiveDate', null); xmlStreamWriter.writeCharacters(this.effectiveDate); xmlStreamWriter.writeEndElement();             
            }
            if(String.isNotBlank(this.BSB))  {
                xmlStreamWriter.writeStartElement(null, 'BSB', null); xmlStreamWriter.writeCharacters(this.BSB); xmlStreamWriter.writeEndElement();
            }
            if(String.isNotBlank(this.bankAccountNumber))  {
                xmlStreamWriter.writeStartElement(null, 'bankAccountNumber', null); xmlStreamWriter.writeCharacters(this.bankAccountNumber); xmlStreamWriter.writeEndElement();
            }
            if(String.isNotBlank(this.bankAccountName))  {
                xmlStreamWriter.writeStartElement(null, 'bankAccountName', null); xmlStreamWriter.writeCharacters(this.bankAccountName); xmlStreamWriter.writeEndElement();
            }
            if(String.isNotBlank(this.contactName)){
                xmlStreamWriter.writeStartElement(null, 'contactName', null); xmlStreamWriter.writeCharacters(this.contactName); xmlStreamWriter.writeEndElement();            
            }
            if(String.isNotBlank(this.contactPhone)){
                xmlStreamWriter.writeStartElement(null, 'contactPhone', null); xmlStreamWriter.writeCharacters(this.contactPhone); xmlStreamWriter.writeEndElement();            
            }
            if(String.isNotBlank(this.contactEmail)){
                xmlStreamWriter.writeStartElement(null, 'contactEmail', null); xmlStreamWriter.writeCharacters(this.contactEmail); xmlStreamWriter.writeEndElement();            
            }
            if(null != this.postalAddress)  {
            xmlStreamWriter.writeCharacters(this.postalAddress.toXML('postalAddress'));
            }
            if(null != this.streetAddress)  {
                xmlStreamWriter.writeCharacters(this.streetAddress.toXML('streetAddress'));
            }
            
            xmlStreamWriter.writeEndElement();
            xml = xmlStreamWriter.getXmlString().unescapeHTML4();
            xmlStreamWriter.close();
            return xml;   
    }
    
    /* special type of XML entity to be created for cancel authorisation request. */
    public String cancelAuthorisationToXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        if(String.isNotBlank(this.type))  {
        xmlStreamWriter.writeStartElement(null, 'regnType', null); xmlStreamWriter.writeCharacters(this.type); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.effectiveDate))  {
            xmlStreamWriter.writeStartElement(null, 'effectiveDate', null); xmlStreamWriter.writeCharacters(this.effectiveDate); xmlStreamWriter.writeEndElement();             
        }
        xml = xmlStreamWriter.getXmlString().unescapeHTML4();
        xmlStreamWriter.close();
        return xml;        
    }
    
}