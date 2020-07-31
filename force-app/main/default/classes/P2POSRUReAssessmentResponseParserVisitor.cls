/**
* @name P2POSRUReAssessmentResponseParserVisitor
* @usage this class will be called from once response is parsed by callout framework, this class is responsible to parse
* XML and popluate this.p2POSRAssessmentResponse variable, once parsing and population is completed.  response variable is passed
* finalize method will be called from batchable finish to perform DMLs and logging.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRUReAssessmentResponseParserVisitor implements AWSC_ResponseParserVisitor {
    
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    public List<P2POSRAssessmentResponse> p2POSRAssessmentResponses { get; private set; }
    public P2POSRAssessmentResponse p2POSRAssessmentResponse { get; private set; }
    private String requestParameters { get; set; }
    public Decimal bspAmountPaid { get; set; }
    public Decimal tspAmountPaid { get; set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.requestParameters = String.valueOf(parser.getOriginal().getRequestParameters());
        p2POSRAssessmentResponses = new List<P2POSRAssessmentResponse>();
        
        this.preParse();
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
            
            Dom.XmlNode createORUpdateAssessmentResponseParentElement;
            
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                createORUpdateAssessmentResponseParentElement = xmlResponseElement; break;
            }
            
            for(Dom.XmlNode xmlResponseElement : createORUpdateAssessmentResponseParentElement.getChildElements())  {
                
                if(xmlResponseElement.getName().equalsIgnoreCase('assessmentResponse')) {
                    P2POSRAssessmentResponse p2POSRAssessmentResponse = new P2POSRAssessmentResponse();
                    p2POSRAssessmentResponse.responseXML = this.responseText;
                    p2POSRAssessmentResponse.type = createORUpdateAssessmentResponseParentElement.getName();
                    
                    if(200 == this.responseStatus) {
                        this.parse(xmlResponseElement, p2POSRAssessmentResponse);
                        p2POSRAssessmentResponse.status = 0 < p2POSRAssessmentResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                            : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
                    } else {
                        p2POSRAssessmentResponse.status = 'FAULT';
                        p2POSRAssessmentResponses.add(p2POSRAssessmentResponse);
                    }
                }
            }
            
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getStackTraceString());
        }
    }
    
    private void parse(Dom.XmlNode xmlResponseElementParam, P2POSRAssessmentResponse p2POSRAssessmentResponse) {
        try {
            Dom.XmlNode createORUpdateAssessmentResponse = xmlResponseElementParam;
            
            Dom.XmlNode xmlResponseParameterElement;
            for(Dom.XmlNode xmlResponseElement : createORUpdateAssessmentResponse.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('levyAssessmentID'))  {
                    p2POSRAssessmentResponse.levyAssessmentID = createORUpdateAssessmentResponse.getChildElement('levyAssessmentID', null).getText();
                } else if(xmlResponseElement.getName().equalsIgnoreCase('responseParameter'))  {
                    xmlResponseParameterElement = xmlResponseElement;
                }
            }
            
            Dom.XmlNode errorORAssessmentInfoElement;
            for(Dom.XmlNode xmlResponseElement : xmlResponseParameterElement.getChildElements())  {
                errorORAssessmentInfoElement = xmlResponseElement; 
                break;
            }
            
            if(errorORAssessmentInfoElement.getName().equalsIgnoreCase('assessmentInfo'))  {
                for(Dom.XmlNode xmlResponseElement : errorORAssessmentInfoElement.getChildElements())  {
                    if(xmlResponseElement.getName().equalsIgnoreCase('OSRAssessmentNumber'))  {
                        p2POSRAssessmentResponse.OSRAssessmentNumber = xmlResponseElement.getText();
                    } else if(xmlResponseElement.getName().equalsIgnoreCase('paymentOption'))  {
                        p2POSRAssessmentResponse.billerCode = xmlResponseElement.getChildElement('billerCode', null).getText();
                        p2POSRAssessmentResponse.reference = xmlResponseElement.getChildElement('reference', null).getText();
                        p2POSRAssessmentResponse.OSRCustomerId = xmlResponseElement.getChildElement('OSRCustomerID', null).getText();
                    }
                    
                }
            } else if(errorORAssessmentInfoElement.getName().equalsIgnoreCase('errors'))  {
                for(Dom.XmlNode xmlResponseElement : errorORAssessmentInfoElement.getChildElements())  {
                    if(xmlResponseElement.getName().equalsIgnoreCase('error'))  {
                        for(Dom.XmlNode xmlErrorElement : xmlResponseParameterElement.getChildElement('errors', null).getChildElements())  {
                            p2POSRAssessmentResponse.errors.add('errorId: ' + xmlErrorElement.getChildElement('errorID', null).getText() 
                                                                + 'errorMessage: ' + xmlErrorElement.getChildElement('errorMessage', null).getText());
                        }
                    }
                }
            }
            
            this.p2POSRAssessmentResponses.add(p2POSRAssessmentResponse);
            
            System.debug(LoggingLevel.INFO, '== P2POSRUReAssessmentResponseParserVisitor done One Assessment Response  ==' + p2POSRAssessmentResponse);
            
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor parse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor parse Exception ==' + xmlException.getStackTraceString());
        }
    }
    
    /**
    * this method will be called from finish context of batchable to finalize the DMLs
    */
    public void finalize()  {
        
        System.debug(LoggingLevel.INFO, '== P2POSRUReAssessmentResponseParserVisitor in finalize  ==' );
        
        Boolean isApplicationLogInserted = false;      
        final String RESPONSE_SUCCESS = 'Success';
        final String RESPONSE_ERROR = 'Error';
        
        Map<String,Assessment__c> assessmentsToUpdate = new Map<String,Assessment__c>();
        
        try {
            
            Map<String,Assessment__c> levyIdVsAssessment = new Map<String,Assessment__c>();
            Set<String> levyIds = new Set<String>();
            
            for(p2POSRAssessmentResponse p2POSRAssessmentResponse : p2POSRAssessmentResponses) { 
                levyIds.add(p2POSRAssessmentResponse.levyAssessmentID);
            }
            
            for(Assessment__c assessment : [SELECT Id, Name, BSP_Assessment_Number__c, TSP_Assessment_Number__c
                                            FROM Assessment__c 
                                            WHERE BSP_Assessment_Number__c IN : levyIds 
                                            OR TSP_Assessment_Number__c IN : levyIds]) 
            {
                if(assessment.BSP_Assessment_Number__c != null) {
                    levyIdVsAssessment.put(assessment.BSP_Assessment_Number__c, assessment);
                }
                
                if(assessment.TSP_Assessment_Number__c != null) {
                    levyIdVsAssessment.put(assessment.TSP_Assessment_Number__c, assessment);
                }
            }
            
            for(p2POSRAssessmentResponse p2POSRAssessmentResponse : p2POSRAssessmentResponses) {
                
                Assessment__c assessment = levyIdVsAssessment.get(p2POSRAssessmentResponse.levyAssessmentID);
                
                String responseMessage = System.now().format() + '\n' + 'Update Assessment : ';
                System.debug('p2POSRAssessmentResponse: '+p2POSRAssessmentResponse);
                
                // Update Assessment Record   
                assessment.Payment_Due_Date__c = System.today().addDays(7);
                assessment.BSP_Amount_Paid__c = bspAmountPaid;
                assessment.TSP_Amount_Paid__c = tspAmountPaid;
                
                if(p2POSRAssessmentResponse.status.equalsIgnoreCase('FAULT') || p2POSRAssessmentResponse.status.equalsIgnoreCase('Error'))  {
                    
                    if(!isApplicationLogInserted) {
                        isApplicationLogInserted = true;
                        ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                        applicationLogMessage.debugLevel = GlobalConstants.ERROR; 
                        applicationLogMessage.payload = this.requestParameters;
                        applicationLogMEssage.logCode = 'Revenue NSW Error';
                        applicationLogMessage.logMessage = p2POSRAssessmentResponse.responseXML;
                        applicationLogMessage.source = 'P2POSRUReAssessmentResponseParserVisitor'; 
                        applicationLogMessage.sourceFunction = 'finalize';
                        ApplicationLogUtility.logMessage(applicationLogMessage);   
                    }
                    
                    assessment.Revenue_Response_Type__c = RESPONSE_ERROR;
                    responseMessage += 'Error \n';
                    Integer index = 1;
                    for(String error : p2POSRAssessmentResponse.errors) {
                        responseMessage += index++ + '. ' + error.substringAfter('errorMessage:') + ' \n';
                    }
                    for(String fault : p2POSRAssessmentResponse.faults) {
                        responseMessage += index++ + '. ' + fault.substringAfter('faultstring:') + ' \n';
                    }
                    
                    assessment.Revenue_Response_Message__c = responseMessage;
                    
                    assessmentsToUpdate.put(assessment.Id,assessment); 
                    
                } else {
                    
                    // Successfully sent request and received response. Next -> update assessment     
                    
                    // Update OSRAssessmentNumber and Payment Referece Number
                    if(p2POSRAssessmentResponse.levyAssessmentID.startsWith('1')) {
                        assessment.Revenue_Assessment_Number_TSP__c = String.isNotBlank(p2POSRAssessmentResponse.OSRAssessmentNumber) 
                            ? p2POSRAssessmentResponse.OSRAssessmentNumber
                            : ''; 
                        
                        assessment.TSP_Payment_Reference_Number__c = String.isNotBlank(p2POSRAssessmentResponse.reference) 
                            ? p2POSRAssessmentResponse.reference
                            : ''; 
                    }
                    
                    if(p2POSRAssessmentResponse.levyAssessmentID.startsWith('2')) {
                        assessment.Revenue_Assessment_Number_BSP__c = String.isNotBlank(p2POSRAssessmentResponse.OSRAssessmentNumber) 
                            ? p2POSRAssessmentResponse.OSRAssessmentNumber
                            : ''; 
                        
                        assessment.BSP_Payment_Reference_Number__c = String.isNotBlank(p2POSRAssessmentResponse.reference) 
                            ? p2POSRAssessmentResponse.reference
                            : ''; 
                    }
                    
                    if(!(assessmentsToUpdate.containsKey(assessment.Id) && assessmentsToUpdate.get(assessment.Id).Revenue_Response_Type__c == RESPONSE_ERROR)) {
                       
                        assessment.Revenue_Response_Type__c = RESPONSE_SUCCESS;
                        assessment.Revenue_Response_Message__c = responseMessage + 'Success';
                        assessment.Status__c = GlobalConstants.Assessment_STATUS_SUBMITTED;
                    }
                    
                    if(!isApplicationLogInserted) {
                        isApplicationLogInserted = true;
                        ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                        applicationLogMessage.debugLevel = GlobalConstants.INFO; 
                        applicationLogMessage.payload = this.requestParameters;
                        applicationLogMEssage.logCode = 'Revenue NSW Success';
                        applicationLogMessage.logMessage = p2POSRAssessmentResponse.responseXML;
                        applicationLogMessage.source = 'P2POSRUReAssessmentResponseParserVisitor'; 
                        applicationLogMessage.sourceFunction = 'finalize';
                        ApplicationLogUtility.logMessage(applicationLogMessage);   
                    }
                    
                    assessmentsToUpdate.put(assessment.Id,assessment); 
                }
                
                System.debug('callouts made: '+Limits.getCallouts());
            }
            
            update assessmentsToUpdate.values();
            System.debug('== Assessments for update: ' + assessmentsToUpdate);
            
        } catch (Exception ex)  {
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor finalize Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRUReAssessmentResponseParserVisitor finalize Exception ==' + ex.getStackTraceString());
        }  
    }
}