/**
* @name P2POSRAssessment
* @usage this class will hold attributes required by P2POSRAssessment parameters within OSR SOAP request.
* @author Arxxus P2P Developer team
*/
public with sharing class P2POSRAssessment {
    
    public String TfNSWProviderNumber { get; set; }
    public String regnType { get; set; }
    public String levyAssessmentID { get; set; }
    public String OSRAssessmentNumber { get; set; }
    public Decimal amountPayable { get; set; }
    public Decimal amountCollected { get; set; }
    public Decimal netAmount { get; set; }
    public String dueDate { get; set; }
    public String reportingPeriodStartDate { get; set; }
    public String reportingPeriodEndDate { get; set; }
    public String levyStatus { get; set; } { this.levyStatus = 'DB'; }
    public String includeAllVersion { get; set; } { this.includeAllVersion = 'true'; }
    
    /** default constructor */ public P2POSRAssessment(){}
    /** constructor to populate attributes of the class, parameterized constructor */
    public P2POSRAssessment(String TfNSWProviderNumber, String regnType, String levyAssessmentID, String OSRAssessmentNumber, Decimal amountPayable, Decimal netAmount, String dueDate, String reportingPeriodStartDate, String reportingPeriodEndDate)  {
        this.TfNSWProviderNumber = TfNSWProviderNumber;
        this.regnType = regnType;
        this.levyAssessmentID = levyAssessmentID;
        this.OSRAssessmentNumber = OSRAssessmentNumber;
        this.amountPayable = amountPayable;
        this.netAmount = netAmount;
        this.dueDate = dueDate;
        this.reportingPeriodStartDate = reportingPeriodStartDate;
        this.reportingPeriodEndDate = reportingPeriodEndDate;
    }
    
    public String toXML(String wrapperTag)  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, 'TfNSWProviderNumber', null); xmlStreamWriter.writeCharacters(this.TfNSWProviderNumber); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'regnType', null); xmlStreamWriter.writeCharacters(this.regnType); xmlStreamWriter.writeEndElement();
        
        xmlStreamWriter.writeStartElement(null, wrapperTag, null);
        if(String.isNotBlank(this.levyAssessmentID))  {
            xmlStreamWriter.writeStartElement(null, 'levyAssessmentID', null); xmlStreamWriter.writeCharacters(this.levyAssessmentID); xmlStreamWriter.writeEndElement();
        }
        if(String.isNotBlank(this.OSRAssessmentNumber))  {
            xmlStreamWriter.writeStartElement(null, 'OSRAssessmentNumber', null); xmlStreamWriter.writeCharacters(this.OSRAssessmentNumber); xmlStreamWriter.writeEndElement();
        }
        if(this.amountPayable == null) {
            //Send amount payble as 0
            this.amountPayable = 0;
            xmlStreamWriter.writeStartElement(null, 'amountPayable', null); xmlStreamWriter.writeCharacters(this.amountPayable.setScale(2).toPlainString()); xmlStreamWriter.writeEndElement();
        } else {
            xmlStreamWriter.writeStartElement(null, 'amountPayable', null); xmlStreamWriter.writeCharacters(this.amountPayable.setScale(2).toPlainString()); xmlStreamWriter.writeEndElement();
        }
        if(this.netAmount != null)  {
            xmlStreamWriter.writeStartElement(null, 'netAmount', null); xmlStreamWriter.writeCharacters(this.netAmount.setScale(2).toPlainString()); xmlStreamWriter.writeEndElement();
        }
        xmlStreamWriter.writeStartElement(null, 'dueDate', null); xmlStreamWriter.writeCharacters(this.dueDate); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'reportingPeriodStartDate', null); xmlStreamWriter.writeCharacters(this.reportingPeriodStartDate); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'reportingPeriodEndDate', null); xmlStreamWriter.writeCharacters(this.reportingPeriodEndDate); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'levyStatus', null); xmlStreamWriter.writeCharacters(this.levyStatus); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml;
    }
    
    public String toGetAssessmentXML()  {
        String xml;
        Xmlstreamwriter xmlStreamWriter = new Xmlstreamwriter();
        xmlStreamWriter.writeStartElement(null, 'TfNSWProviderNumber', null); xmlStreamWriter.writeCharacters(this.TfNSWProviderNumber); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'regnType', null); xmlStreamWriter.writeCharacters(this.regnType); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'startDate', null); xmlStreamWriter.writeCharacters(this.reportingPeriodStartDate); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'endDate', null); xmlStreamWriter.writeCharacters(this.reportingPeriodEndDate); xmlStreamWriter.writeEndElement();
        xmlStreamWriter.writeStartElement(null, 'includeAllVersion', null); xmlStreamWriter.writeCharacters(this.includeAllVersion); xmlStreamWriter.writeEndElement();
        xml = xmlStreamWriter.getXmlString().unescapeHtml4();
        xmlStreamWriter.close();
        return xml;
    }
    
    public class P2POSRTransaction {
        public string transactionType { get; set; }
        public Decimal transactionAmount { get; set; }
        public string effectiveDate { get; set; }
        public string OSRAssessmentNumber { get; set; }
        public string assessmentPeriod { get; set; }
        public string description { get; set; }
        public string receiptID { get; set; }
        public string paymentType { get; set; }
        public string status { get; set; }
        
    }
}