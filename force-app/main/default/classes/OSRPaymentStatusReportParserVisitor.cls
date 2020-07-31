public with sharing class OSRPaymentStatusReportParserVisitor implements AWSC_ResponseParserVisitor {
    
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    private String requestParameters { get; set; }
    public P2POSRGetPaymentStatusReportResponse p2POSRGetPaymentStatusReportResponse { get; private set; }
    public Map<String,P2POSRPaymentStatus>  oSRAssessmentNumberAndp2POSRPaymentStatusMap { get; set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.requestParameters = String.valueOf(parser.getOriginal().getRequestParameters());
        
        this.p2POSRGetPaymentStatusReportResponse = new P2POSRGetPaymentStatusReportResponse();
        this.p2POSRGetPaymentStatusReportResponse.responseXML = this.responseText;
        oSRAssessmentNumberAndp2POSRPaymentStatusMap = new Map<String,P2POSRPaymentStatus>();
        
        if(200 == this.responseStatus) {
            if(this.responseText == '') {
                this.p2POSRGetPaymentStatusReportResponse.status = 'FAULT';
            } else {
                this.parse();
                p2POSRGetPaymentStatusReportResponse.status = 0 < p2POSRGetPaymentStatusReportResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                    : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
            }
        } else {
            this.p2POSRGetPaymentStatusReportResponse.status = 'FAULT';
        }
    }
    
    public void parse() {
        
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
            
            Dom.XmlNode xmlResponseGetPaymentStatusReportResponseElement;
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                xmlResponseGetPaymentStatusReportResponseElement = xmlResponseElement; 
                break;
            }
            
            Dom.XmlNode xmlresponseDetailElement;
            for(Dom.XmlNode xmlResponseElement : xmlResponseGetPaymentStatusReportResponseElement.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('reportDate')) {
                    p2POSRGetPaymentStatusReportResponse.reportDate = xmlResponseElement.getText();
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('totalPageCount')) {
                    p2POSRGetPaymentStatusReportResponse.totalPageCount = Integer.valueOf(xmlResponseElement.getText());
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('currentPage')) {
                    p2POSRGetPaymentStatusReportResponse.currentPage = Integer.valueOf(xmlResponseElement.getText());
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('responseDetail')) {
                    xmlresponseDetailElement = xmlResponseElement;
                    break;
                }
            }
            
            for(Dom.XmlNode xmlRootChildElement : xmlresponseDetailElement.getChildElements())  {
                
                if(xmlRootChildElement.getName().equalsIgnoreCase('paymentStatusResponse')) {
                    for(Dom.XmlNode xmlPaymentStatusElement : xmlRootChildElement.getChildElements()) {
                        if(xmlPaymentStatusElement.getName().equalsIgnoreCase('paymentStatus')) {
                            p2POSRGetPaymentStatusReportResponse.paymentStatusList.add(this.parsePaymentStatus(xmlPaymentStatusElement));
                        }
                    }
                }
                if(xmlRootChildElement.getName().equalsIgnoreCase('errors')) {
                    for(Dom.XmlNode xmlErrorElement : xmlRootChildElement.getChildElements())  {
                        p2POSRGetPaymentStatusReportResponse.errors.add('errorId: ' + xmlErrorElement.getChildElement('errorID', null).getText() 
                                                                        + ' errorMessage: ' + xmlErrorElement.getChildElement('errorMessage', null).getText());
                    }
                }
            }
            
            System.debug(LoggingLevel.INFO, 'OSRPaymentStatusReportParserVisitor MAP Populated - ');
            for (String osrAssessmentNumber : oSRAssessmentNumberAndp2POSRPaymentStatusMap.keySet()) {
                System.debug('osrAssessmentNumber : ' + osrAssessmentNumber);
                System.debug('paymentStatus : ' + oSRAssessmentNumberAndp2POSRPaymentStatusMap.get(osrAssessmentNumber));
            }
            
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== OSRPaymentStatusReportParserVisitor parse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== OSRPaymentStatusReportParserVisitor parse Exception ==' + xmlException.getStackTraceString());
        }
    }
    
    private P2POSRPaymentStatus parsePaymentStatus(Dom.XmlNode xmlResponsePaymentStatusParentElement) {
        
        P2POSRPaymentStatus p2POSRPaymentStatus = new P2POSRPaymentStatus();
        
        for(Dom.XmlNode xmlResponsePaymentStatusElement : xmlResponsePaymentStatusParentElement.getChildElements())  {
            
            if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('TfNSWProviderNumber')) {
                p2POSRPaymentStatus.TfNSWProviderNumber = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('regnType')) {
                p2POSRPaymentStatus.regnType = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('levyAssessmentID')) {
                p2POSRPaymentStatus.levyAssessmentID = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('OSRAssessmentNumber')) {
                p2POSRPaymentStatus.OSRAssessmentNumber = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('amountCollected')) {
                p2POSRPaymentStatus.amountCollected = decimal.valueOf(xmlResponsePaymentStatusElement.getText());
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('reportDate')) {
                p2POSRPaymentStatus.reportDate = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('receiptId')) {
                p2POSRPaymentStatus.receiptId = xmlResponsePaymentStatusElement.getText();
            }
            else if(xmlResponsePaymentStatusElement.getName().equalsIgnoreCase('failureReason')) {
                p2POSRPaymentStatus.failureReason = xmlResponsePaymentStatusElement.getText();
            }
        }
        
        oSRAssessmentNumberAndp2POSRPaymentStatusMap.put(p2POSRPaymentStatus.OSRAssessmentNumber, p2POSRPaymentStatus);
        return p2POSRPaymentStatus;
    }
    
    public Map<String, Sobject> finalize() {
        
        Map<String, Sobject> updateOrInserts = new Map<String, SObject>(); 
        
        P2POSRPaymentStatus p2POSRPaymentStatus = new P2POSRPaymentStatus();
        
        List<Assessment__c> assessments = [SELECT Id, Name, Status__c, Assessment_Type__c, Payment_Due_Date__c, Account__r.Customer_Number__c, 
                                           Total_Levy_Amount__c, Period_Start_Date__c, Period_End_Date__c, Revenue_Assessment_Number_BSP__c, Revenue_Assessment_Number_TSP__c
                                           FROM Assessment__c 
                                           WHERE Revenue_Assessment_Number_BSP__c IN : oSRAssessmentNumberAndp2POSRPaymentStatusMap.keySet()
                                           OR Revenue_Assessment_Number_TSP__c IN : oSRAssessmentNumberAndp2POSRPaymentStatusMap.keySet() ];
        
        if(p2POSRGetPaymentStatusReportResponse.status.equalsIgnoreCase('FAULT') || p2POSRGetPaymentStatusReportResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
            
            Application_Log__c al = new Application_Log__c(Debug_Level__c = GlobalConstants.ERROR, Integration_Payload__c = this.requestParameters, Log_Code__c = 'Revenue NSW Error'
                                                           , Message__c = this.p2POSRGetPaymentStatusReportResponse.responseXML, Source__c = 'OSRPaymentStatusReportParserVisitor'
                                                           , Source_Function__c = 'finalize', Reference_Id__c = String.valueOf(p2POSRGetPaymentStatusReportResponse.reportDate));
            
            Database.insert(al, false); 
            
        } else {
            
            Application_Log__c al = new Application_Log__c(Debug_Level__c = GlobalConstants.INFO, Integration_Payload__c = this.requestParameters, Log_Code__c = 'Revenue NSW Success'
                                                           , Message__c = this.p2POSRGetPaymentStatusReportResponse.responseXML, Source__c = 'OSRPaymentStatusReportParserVisitor'
                                                           , Source_Function__c = 'finalize', Reference_Id__c = String.valueOf(p2POSRGetPaymentStatusReportResponse.reportDate));
            Database.insert(al, false); 
            
            for(Assessment__c assessment : assessments) {
                
                if(oSRAssessmentNumberAndp2POSRPaymentStatusMap.containsKey(assessment.Revenue_Assessment_Number_BSP__c)) {
                    p2POSRPaymentStatus = oSRAssessmentNumberAndp2POSRPaymentStatusMap.get(assessment.Revenue_Assessment_Number_BSP__c);
                }
                else if(oSRAssessmentNumberAndp2POSRPaymentStatusMap.containsKey(assessment.Revenue_Assessment_Number_TSP__c)) {
                    p2POSRPaymentStatus = oSRAssessmentNumberAndp2POSRPaymentStatusMap.get(assessment.Revenue_Assessment_Number_TSP__c);
                }
                
                String revenueResponseMessage = System.now().format() + '\n Get Payment Status Report : ';
                
                if(String.isNotBlank(p2POSRPaymentStatus.failureReason)) {
                    if(assessment.Status__c != GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED)
                        assessment.Status__c = GlobalConstants.Assessment_STATUS_ERROR;
                    assessment.Revenue_Response_Type__c = 'Error';
                    revenueResponseMessage = revenueResponseMessage + 'Error \n' + p2POSRPaymentStatus.failureReason;
                    assessment.Revenue_Response_Message__c = revenueResponseMessage;
                }
                else {
                    if(assessment.Status__c != GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED)
                        assessment.Status__c = GlobalConstants.Assessment_STATUS_Closed;
                    
                    assessment.Revenue_Response_Type__c = 'Success';
                    assessment.Revenue_Response_Message__c = revenueResponseMessage + 'Success';
                    
                    if(p2POSRPaymentStatus.regnType == 'TT') {
                        assessment.TSP_Revenue_Receipt_Id__c = p2POSRPaymentStatus.receiptId;
                    }
                    else if(p2POSRPaymentStatus.regnType == 'TB') {
                        assessment.BSP_Revenue_Receipt_Id__c = p2POSRPaymentStatus.receiptId;
                    }
                } 
            }
            Database.update(assessments, false);
        }
        
        return updateOrInserts;
    }
}