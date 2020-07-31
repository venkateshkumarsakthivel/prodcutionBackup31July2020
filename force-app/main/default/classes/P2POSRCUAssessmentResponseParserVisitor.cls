/**
* @name P2POSRCUAssessmentResponseParserVisitor
* @usage this class will be called from once response is parsed by callout framework, this class is responsible to parse
* XML and popluate this.p2POSRAssessmentResponse variable, once parsing and population is completed.  response variable is passed
* finalize method will be called from batchable finish to perform DMLs and logging.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRCUAssessmentResponseParserVisitor implements AWSC_ResponseParserVisitor {
    
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    public String requestType { get; set; }
    public List<P2POSRAssessmentResponse> p2POSRAssessmentResponses { get; private set; }
    public P2POSRAssessmentResponse p2POSRAssessmentResponse { get; private set; }
    public String requestParameters { get; set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.requestType = String.valueOf(((P2POSRRequestParameter) parser.getOriginal().getRequestParameters()).requestType );
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
                        p2POSRAssessmentResponse = this.parse(xmlResponseElement, p2POSRAssessmentResponse);
                        p2POSRAssessmentResponse.status = 0 < p2POSRAssessmentResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                            : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
                        System.debug(LoggingLevel.INFO, '== P2POSRCUAssessmentResponseParserVisitor done One Assessment Response  ==' + p2POSRAssessmentResponse);
            			this.p2POSRAssessmentResponses.add(p2POSRAssessmentResponse);
                    } else {
                        p2POSRAssessmentResponse.status = 'FAULT';
                        this.parseFault(xmlResponseElement, p2POSRAssessmentResponse);
                    }
                }
            }
            
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor preParse Exception ==' + xmlException.getStackTraceString());
        }
    }
    
    private void parseFault(Dom.XmlNode xmlResponseElementParam, P2POSRAssessmentResponse p2POSRAssessmentResponse) {
        
        system.debug('111 xml element name >>' + xmlResponseElementParam.getName());
        Dom.XmlNode xmlFaultElement;
        for(Dom.XmlNode xmlResponseElement : xmlResponseElementParam.getChildElements())  {
            xmlFaultElement = xmlResponseElement; break;
        }
        system.debug('fault xml element name >>' + xmlFaultElement.getChildElement('faultcode', null).getText() );
        system.debug('fault xml element name >>' + xmlFaultElement.getChildElement('faultstring', null).getText() );
        p2POSRAssessmentResponse.faults.add('faultcode: ' + xmlFaultElement.getChildElement('faultcode', null).getText() 
                                                 + ' faultstring: ' + xmlFaultElement.getChildElement('faultstring', null).getText());
        p2POSRAssessmentResponses.add(p2POSRAssessmentResponse);
    }
    
    private P2POSRAssessmentResponse parse(Dom.XmlNode xmlResponseElementParam, P2POSRAssessmentResponse p2POSRAssessmentResponse) {
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
            
            return p2POSRAssessmentResponse;
        } catch(Exception xmlException) {
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor parse Exception ==' + xmlException.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor parse Exception ==' + xmlException.getStackTraceString());
			return null;        
        }
    }
    
    /**
    * this method will be called from finish context of batchable to finalize the DMLs
    */
    public static void finalize(List<P2POSRAssessmentResponse> p2POSRAssessmentResponses, Map<String, String> requestParameters, Map<String, String> requestTypes)  {
        
        System.debug(LoggingLevel.INFO, '== P2POSRCUAssessmentResponseParserVisitor in finalize  ==' );
        
        Boolean isApplicationLogInserted = false;
        Boolean isErrorResponseForTSPOrBSPAssessment = false;
        
        try {
            
            Set<String> levyAssessmentIds =  new Set<String>();
            Map<String, Assessment__c> rnswAssessmentNoVsAssessmentMap = new Map<String, Assessment__c>();
            Map<String, Assessment__c> assessmentsToUpdate = new Map<String, Assessment__c>();
            List<ApplicationLogMessage> logList = new List<ApplicationLogMessage>();
            
            for(p2POSRAssessmentResponse p2POSRAssessmentResponse : p2POSRAssessmentResponses) {
                if(String.isNotBlank(p2POSRAssessmentResponse.levyAssessmentID)) {
                    levyAssessmentIds.add(p2POSRAssessmentResponse.levyAssessmentID);
                }
            }
            
            for(Assessment__c assessment : [SELECT Id, Name, Status__c, Assessment_Type__c, Payment_Due_Date__c, Account__r.Customer_Number__c, 
                                            Total_Levy_Amount__c, Period_Start_Date__c, Period_End_Date__c, BSP_Assessment_Number__c, TSP_Assessment_Number__c FROM Assessment__c 
                                            WHERE BSP_Assessment_Number__c IN : levyAssessmentIds
                                            OR TSP_Assessment_Number__c IN : levyAssessmentIds]) {
                                                
           			if(String.isNotBlank(assessment.BSP_Assessment_Number__c)) {
                        rnswAssessmentNoVsAssessmentMap.put(assessment.BSP_Assessment_Number__c, assessment);
                    }
                                                
                    if(String.isNotBlank(assessment.TSP_Assessment_Number__c)) {
                        rnswAssessmentNoVsAssessmentMap.put(assessment.TSP_Assessment_Number__c, assessment);
                    }
            }
              
            for(p2POSRAssessmentResponse p2POSRAssessmentResponse : p2POSRAssessmentResponses) { 
                isErrorResponseForTSPOrBSPAssessment = false;
                isApplicationLogInserted = false;
                Assessment__c assessment = rnswAssessmentNoVsAssessmentMap.get(p2POSRAssessmentResponse.levyAssessmentID);
                
                if(assessmentsToUpdate.containsKey(assessment.Id)) {
                    assessment = assessmentsToUpdate.get(assessment.Id);
                }
                
                if(p2POSRAssessmentResponse.status.equalsIgnoreCase('FAULT') || p2POSRAssessmentResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
                    
                    isErrorResponseForTSPOrBSPAssessment = true;
                    
                    if(!isApplicationLogInserted) {
                        isApplicationLogInserted = true;
                        ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                        applicationLogMessage.debugLevel = GlobalConstants.ERROR; 
                        applicationLogMessage.payload = requestParameters.get(p2POSRAssessmentResponse.levyAssessmentID);
                        applicationLogMEssage.logCode = 'Revenue NSW Error';
                        applicationLogMessage.logMessage = p2POSRAssessmentResponse.responseXML;
                        applicationLogMessage.source = 'P2POSRCUAssessmentResponseParserVisitor'; 
                        applicationLogMessage.sourceFunction = 'finalize';
                        logList.add(applicationLogMessage);
                        //ApplicationLogUtility.logMessage(applicationLogMessage);   
                    }
                    
                } else {
                    
                    if(p2POSRAssessmentResponse.levyAssessmentID.startsWith('1')) {
                        assessment.Revenue_Assessment_Number_TSP__c = String.isNotBlank(p2POSRAssessmentResponse.OSRAssessmentNumber) 
                            ? p2POSRAssessmentResponse.OSRAssessmentNumber
                            : ''; 
                    }
                    
                    if(p2POSRAssessmentResponse.levyAssessmentID.startsWith('2')) {
                        assessment.Revenue_Assessment_Number_BSP__c = String.isNotBlank(p2POSRAssessmentResponse.OSRAssessmentNumber) 
                            ? p2POSRAssessmentResponse.OSRAssessmentNumber
                            : ''; 
                    }
                    
                    if(!isApplicationLogInserted) {
                        isApplicationLogInserted = true;
                        ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                        applicationLogMessage.debugLevel = GlobalConstants.INFO; 
                        applicationLogMessage.payload = requestParameters.get(p2POSRAssessmentResponse.levyAssessmentID);
                        applicationLogMEssage.logCode = 'Revenue NSW Success';
                        applicationLogMessage.logMessage = p2POSRAssessmentResponse.responseXML;
                        applicationLogMessage.source = 'P2POSRCUAssessmentResponseParserVisitor'; 
                        applicationLogMessage.sourceFunction = 'finalize';
                        logList.add(applicationLogMessage);
                        //ApplicationLogUtility.logMessage(applicationLogMessage);   
                    }
                }
                
                String revenueResponseMessage = System.now().format() + '\n' ;
                if(requestTypes.get(p2POSRAssessmentResponse.levyAssessmentID) == 'OSR_CREATE_ASSESSMENT_REQUEST') {
                    revenueResponseMessage += 'Create Assessment : ';
                } 
                else if(requestTypes.get(p2POSRAssessmentResponse.levyAssessmentID) == 'OSR_UPDATE_ASSESSMENT_REQUEST') {
                    revenueResponseMessage += 'Update Assessment : ';
                }
                
                if(isErrorResponseForTSPOrBSPAssessment) {
                    assessment.Status__c = GlobalConstants.Assessment_STATUS_ERROR;
                    assessment.Revenue_Response_Type__c = 'Error';
                    
                    revenueResponseMessage += ' Error \n';
                    Integer index = 1;
                    for(String error : p2POSRAssessmentResponse.errors) {
                        revenueResponseMessage += index++ + '. ' + error.substringAfter('errorMessage:') + ' \n';
                    }
                    for(String fault : p2POSRAssessmentResponse.faults) {
                        revenueResponseMessage += index++ + '. ' + fault.substringAfter('faultstring:') + ' \n';
                    }
                    
                    assessment.Revenue_Response_Message__c = revenueResponseMessage;
                } else {
                    assessment.Status__c = GlobalConstants.Assessment_STATUS_SUBMITTED;
                    assessment.Revenue_Response_Type__c = 'Success';
                    assessment.Revenue_Response_Message__c = revenueResponseMessage + 'Success';
                }
                
                assessmentsToUpdate.put(assessment.Id, assessment);
            }

            ApplicationLogUtility.logMessage(logList);              
            Database.update(assessmentsToUpdate.values(), false);
            
        } catch (Exception ex)  {
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor finalize Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRCUAssessmentResponseParserVisitor finalize Exception ==' + ex.getStackTraceString());
        }  
    }
}