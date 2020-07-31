/**
* @name P2POSRIndividualClient
* @usage this class will hold attributes required by individual client details parameters within clientDetails attribute within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRIndividualClient {
    public String givenName { get; set; } /* maximum length 71 characters. primary c fname*/
    public String familyName { get; set; } /* maximum length 50 characters. lname*/
    public String birthDate { get; set; } /* pattern 2008-12-31 */
    public String driversLicenceNumber { get; set; } /* Optional, maximum length 20 characters, pattern [a-zA-Z0-9]* */
    public String driversLicenceState { get; set; } /* Optional, maximum length 3, Possible values [QLD, NSW, ACT, VIC, TAS, SA, WA, NT] */
    public String sex { get; set; } /* maximum length 1, possible values [M, F]*/
    
    /* default constructor */
    public P2POSRIndividualClient()  {}
    
    /* constructor with attributes  to populate */
    public P2POSRIndividualClient(String givenName, String familyName, String birthDate, String driversLicenceNumber, String driversLicenceState, String sex) {
        
        this.birthDate = birthDate;
        
        if(String.isNotBlank(givenName)) {
            this.givenName = givenName.Length() < 72 ?  givenName : givenName.substring(0, 71);
        }
        if(String.isNotBlank(familyName)) {
            this.familyName = (familyName.Length() < 51) ?  familyName : familyName.substring(0, 50);
        }
        if(String.isNotBlank(driversLicenceNumber)) {
            this.driversLicenceNumber = driversLicenceNumber.Length() < 21 ?  driversLicenceNumber : driversLicenceNumber.substring(0, 20);
        }
        if(String.isNotBlank(driversLicenceState)) {
            this.driversLicenceState = (String.isNotBlank(driversLicenceState) && driversLicenceState.Length() < 4) ?  driversLicenceState : driversLicenceState.substring(0, 3);
        }
        if(String.isNotBlank(sex)) {
            this.sex = (sex.Length() < 2) ?  sex : sex.substring(0, 1);
        }
     }
    
    public String toXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        
        if(String.isNotBlank(this.givenName))  {
        xmlStreamWriter.writeStartElement(null, 'givenName', null); xmlStreamWriter.writeCharacters(this.givenName); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.familyName))  {
        xmlStreamWriter.writeStartElement(null, 'familyName', null); xmlStreamWriter.writeCharacters(this.familyName); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.birthDate))  {
        xmlStreamWriter.writeStartElement(null, 'birthDate', null); xmlStreamWriter.writeCharacters(this.birthDate); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.driversLicenceNumber))  {
            xmlStreamWriter.writeStartElement(null, 'driversLicenceNumber', null); xmlStreamWriter.writeCharacters(this.driversLicenceNumber); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.driversLicenceState))  {
            xmlStreamWriter.writeStartElement(null, 'driversLicenceState', null); xmlStreamWriter.writeCharacters(this.driversLicenceState); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.sex))  {
            xmlStreamWriter.writeStartElement(null, 'sex', null); xmlStreamWriter.writeCharacters(this.sex); xmlStreamWriter.writeEndElement();
        }
        
        
        xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHTML4();
        xmlStreamWriter.close();
        return xml;
    }
}