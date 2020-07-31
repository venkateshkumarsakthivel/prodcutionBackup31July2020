public class P2POSRGetAssessmentResponseParserVisitor implements AWSC_ResponseParserVisitor {
    
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    private String requestParameters { get; set; }
    public List<P2POSRGetAssessmentResponse> p2POSRGetAssessmentResponses { get; private set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        system.debug('In Response Parser Visitor');
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.requestParameters = String.valueOf(parser.getOriginal().getRequestParameters());
        p2POSRGetAssessmentResponses = new List<P2POSRGetAssessmentResponse>();
        this.preParse();
        
    }
    
    public List<P2POSRGetAssessmentResponse> finalize(){
        
        try {
            
            System.debug(LoggingLevel.INFO, '== P2POSRGetAssessmentResponseParserVisitor in finalize  ==' );
            
            return p2POSRGetAssessmentResponses;
            
            /*for(P2POSRGetAssessmentResponse p2POSRGetAssessmentResponse : p2POSRGetAssessmentResponses) { 
                
                if(p2POSRGetAssessmentResponse.Status.equalsIgnoreCase('FAULT') || p2POSRGetAssessmentResponse.Status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  
                {
                    return 'Error';
                } else {
                    return 'Success';
                }
            }*/
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, '== P2POSRGetAssessmentResponseParserVisitor finalize Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRGetAssessmentResponseParserVisitor finalize Exception ==' + ex.getStackTraceString());
        }  
        return null;
    }
    
    private void preParse() {
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
            
            //Dom.XmlNode xmlResponseParameterElement;
            Dom.XmlNode getAssessmentResponseParentElement;
            
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                getAssessmentResponseParentElement = xmlResponseElement; break;
            }
            
            for(Dom.XmlNode xmlResponseElement : getAssessmentResponseParentElement.getChildElements())  {
                
                if(xmlResponseElement.getName().equalsIgnoreCase('responseParameter')) {
                    P2POSRGetAssessmentResponse p2POSRGetAssessmentResponse = new P2POSRGetAssessmentResponse();
                    
                    p2POSRGetAssessmentResponse.responseXML = this.responseText;
                    p2POSRGetAssessmentResponse.type = getAssessmentResponseParentElement.getName();
                    
                    if(200 == this.responseStatus) {
                        p2POSRGetAssessmentResponse = this.parse(xmlResponseElement, p2POSRGetAssessmentResponse);
                        p2POSRGetAssessmentResponse.status = 0 < p2POSRGetAssessmentResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                            : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
                        p2POSRGetAssessmentResponses.add(p2POSRGetAssessmentResponse);
                    } else {
                        p2POSRGetAssessmentResponse.status = 'FAULT';
                        system.debug('Flault Assesment Is '+ p2POSRGetAssessmentResponse);
                        p2POSRGetAssessmentResponses.add(p2POSRGetAssessmentResponse);
                    }
                }
            }
            
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== P2POSRGetAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRGetAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getStackTraceString());
        }
    }    
    
    private P2POSRGetAssessmentResponse parse(Dom.XmlNode xmlResponseParameterElement, P2POSRGetAssessmentResponse p2POSRGetAssessmentResponse) {
        try {
            p2POSRGetAssessmentResponse = new P2POSRGetAssessmentResponse();
            for(Dom.XmlNode xmlResponseElement : xmlResponseParameterElement.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('TfNSWProviderNumber')) {
                    p2POSRGetAssessmentResponse.TfNSWProviderNumber = xmlResponseElement.getText();
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('regnType')) {
                    p2POSRGetAssessmentResponse.regnType = xmlResponseElement.getText();
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('startDate')) {
                    p2POSRGetAssessmentResponse.startDate = xmlResponseElement.getText();
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('endDate')) {
                    p2POSRGetAssessmentResponse.endDate = xmlResponseElement.getText();
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('assessments')) {
                    for(Dom.XmlNode xmlAssessmentElement : xmlResponseElement.getChildElements())  {
                        if(xmlAssessmentElement.getName().equalsIgnoreCase('assessment')) {
                            p2POSRGetAssessmentResponse.p2POSRAssessment.add(this.parseAssessments(xmlAssessmentElement));
                        }
                    }
                    
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('transactions')) {
                    for(Dom.XmlNode xmlTransactionElement : xmlResponseElement.getChildElements())  {
                        if(xmlTransactionElement.getName().equalsIgnoreCase('transaction')) {
                            p2POSRGetAssessmentResponse.p2POSRTransactions.add(this.parseTransactions(xmlTransactionElement));
                        }
                    }
                }
                else if(xmlResponseElement.getName().equalsIgnoreCase('errors')) {
                    for(Dom.XmlNode xmlErrorElement : xmlResponseParameterElement.getChildElement('errors', null).getChildElements())  {
                        p2POSRGetAssessmentResponse.errors.add('errorId: ' + xmlErrorElement.getChildElement('errorID', null).getText() 
                                                               + 'errorMessage: ' + xmlErrorElement.getChildElement('errorMessage', null).getText());
                    }
                }
            }
            //system.debug('Assesment Is '+ p2POSRGetAssessmentResponse);
            
            return p2POSRGetAssessmentResponse;
        } catch(Exception xmlException)  {
            System.debug(xmlException.getMessage());
            return null;
        } 
    }
    
    private P2POSRAssessment parseAssessments (Dom.XmlNode assessmentParent) {
        
        P2POSRAssessment p2POSRAssessment = new P2POSRAssessment();
        for(Dom.XmlNode assessmentNode : assessmentParent.getChildElements())  {
            if(assessmentNode.getName().equalsIgnoreCase('levyAssessmentID')) {
                p2POSRAssessment.levyAssessmentID = assessmentNode.getText();
            }
            else if(assessmentNode.getName().equalsIgnoreCase('OSRAssessmentNumber')) {
                p2POSRAssessment.OSRAssessmentNumber = assessmentNode.getText();
            }
            else if(assessmentNode.getName().equalsIgnoreCase('OSRAssessmentVersion')) {
                //p2POSRAssessment.levyAssessmentID = assessmentNode.getText();
            }
            else if(assessmentNode.getName().equalsIgnoreCase('amountPayable')) {
                p2POSRAssessment.amountPayable =  decimal.valueOf(assessmentNode.getText());
            }
            else if(assessmentNode.getName().equalsIgnoreCase('amountCollected')) {
                p2POSRAssessment.amountCollected = decimal.valueOf(assessmentNode.getText());
            }
            else if(assessmentNode.getName().equalsIgnoreCase('dueDate')) {
                p2POSRAssessment.dueDate = assessmentNode.getText();
            }
            else if(assessmentNode.getName().equalsIgnoreCase('reportingPeriodStartDate')) {
                p2POSRAssessment.reportingPeriodStartDate = assessmentNode.getText();
            }
            else if(assessmentNode.getName().equalsIgnoreCase('reportingPeriodEndDate')) {
                p2POSRAssessment.reportingPeriodEndDate = assessmentNode.getText();
            }
        }
        return p2POSRAssessment;
    }
    
    private P2POSRAssessment.P2POSRTransaction parseTransactions (Dom.XmlNode transactionParent) {
        P2POSRAssessment.P2POSRTransaction p2POSRTransaction = new P2POSRAssessment.P2POSRTransaction();
        
        for(Dom.XmlNode transactionNode : transactionParent.getChildElements())  {
            if(transactionNode.getName().equalsIgnoreCase('transactionType')) {
                p2POSRTransaction.transactionType = transactionNode.getText();
            }
            else if(transactionNode.getName().equalsIgnoreCase('transactionAmount')) {
                p2POSRTransaction.transactionAmount = decimal.valueOf(transactionNode.getText());  
            }
            else if(transactionNode.getName().equalsIgnoreCase('effectiveDate')) {
                p2POSRTransaction.effectiveDate = transactionNode.getText(); 
            }
            else if(transactionNode.getName().equalsIgnoreCase('OSRAssessmentNumber')) {
                p2POSRTransaction.OSRAssessmentNumber = transactionNode.getText();
            } 
            else if(transactionNode.getName().equalsIgnoreCase('assessmentPeriod')) {
                p2POSRTransaction.assessmentPeriod = transactionNode.getText();
            }
            else if(transactionNode.getName().equalsIgnoreCase('description')) {
                p2POSRTransaction.description = transactionNode.getText();
            }
            else if(transactionNode.getName().equalsIgnoreCase('receiptID')) {
                p2POSRTransaction.receiptID = transactionNode.getText();
            }
            else if(transactionNode.getName().equalsIgnoreCase('paymentType')) {
                p2POSRTransaction.paymentType = transactionNode.getText();
            }
            else if(transactionNode.getName().equalsIgnoreCase('status')) {
                p2POSRTransaction.status = transactionNode.getText();
            }
        }
        return p2POSRTransaction;
    }
    
    
}