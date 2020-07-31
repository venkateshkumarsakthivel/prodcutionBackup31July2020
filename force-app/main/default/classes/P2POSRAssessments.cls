/**
* @name P2POSRAssessments
* @usage this will hold tsp and bsp variations of Authorisation related to Tax Payer associated with Assessment to be passed as parameters to request
* @auhtor Arxxus P2P developer team
*/
public class P2POSRAssessments {
    public P2POSRAssessment assessmentForTspAuthorisation { get; set; }
    public P2POSRAssessment assessmentForBspAuthorisation { get; set; }
    
    public P2POSRAssessments() {}
    
    public P2POSRAssessments(P2POSRAssessment assessmentForTspAuthorisation, P2POSRAssessment assessmentForBspAuthorisation) {
        this.assessmentForTspAuthorisation = assessmentForTspAuthorisation;
        this.assessmentForBspAuthorisation = assessmentForBspAuthorisation;
    }
    
    public String toXML(String wrapperTag)  {
        String xml;
        
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();       
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        
        if(null != this.assessmentForTspAuthorisation)  {
            xmlStreamWriter.writeCharacters(this.assessmentForTspAuthorisation.toXML('assessmentForTspAuthorisation'));
        }
        if(null != this.assessmentForBspAuthorisation)  {
            xmlStreamWriter.writeCharacters(this.assessmentForBspAuthorisation.toXML('assessmentForBspAuthorisation'));
        }
        
        xmlStreamWriter.writeEndElement();   
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml; 
    }
}