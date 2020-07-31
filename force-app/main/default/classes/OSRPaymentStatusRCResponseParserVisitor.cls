public with sharing class OSRPaymentStatusRCResponseParserVisitor implements AWSC_ResponseParserVisitor {
    
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    public String requestParameters { get; set; }
    public P2POSRGetPaymentStatusReportResponse p2POSRGetPaymentStatusReportResponse { get; private set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.requestParameters = String.valueOf(parser.getOriginal().getRequestParameters());
        
        this.p2POSRGetPaymentStatusReportResponse = new P2POSRGetPaymentStatusReportResponse();
        this.p2POSRGetPaymentStatusReportResponse.responseXML = this.responseText;
        
        if(200 == this.responseStatus) { 
            if(this.responseText == '') {
                this.p2POSRGetPaymentStatusReportResponse.status = 'FAULT';
            } else {
                this.parse();
                this.p2POSRGetPaymentStatusReportResponse.status = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
            }
            
        } else {
            this.p2POSRGetPaymentStatusReportResponse.status = 'FAULT';
        }
        
    }
    
    private void parse() {
        
        try {
            Dom.Document xmlDocument = new Dom.Document(); 
            xmlDocument.load(this.responseText);
            
            Dom.XmlNode xmlRootElement = xmlDocument.getRootElement();
            Dom.XmlNode xmlResponseBodyElement;
            for(Dom.XmlNode xmlRootChildElement : xmlRootElement.getChildElements())  {
                if(xmlRootChildElement.getName().equalsIgnoreCase('Body')) {
                    xmlResponseBodyElement = xmlRootChildElement;
                    break;
                }
            }
            
            Dom.XmlNode xmlGetPaymentStatusRecordCountResponse;
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                xmlGetPaymentStatusRecordCountResponse = xmlResponseElement; 
                break;
            }
            
            this.p2POSRGetPaymentStatusReportResponse.requestType = xmlGetPaymentStatusRecordCountResponse.getName();
            
            for(Dom.XmlNode xmlResponseElement : xmlGetPaymentStatusRecordCountResponse.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('reportDate'))  {
                    this.p2POSRGetPaymentStatusReportResponse.reportDate = xmlResponseElement.getText();
                } else if(xmlResponseElement.getName().equalsIgnoreCase('totalRecordCount'))  {
                    this.p2POSRGetPaymentStatusReportResponse.totalRecordCount = Integer.valueOf(xmlResponseElement.getText());
                } else if(xmlResponseElement.getName().equalsIgnoreCase('totalPageCount'))  {
                    this.p2POSRGetPaymentStatusReportResponse.totalPageCount = Integer.valueOf(xmlResponseElement.getText());
                } 
            }
            
        } catch(Exception xmlException)  {
            System.debug(LoggingLevel.ERROR, '== OSRPaymentStatusRCResponseParserVisitor parse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== OSRPaymentStatusRCResponseParserVisitor parse Exception ==' + xmlException.getStackTraceString());
        }
    }
}