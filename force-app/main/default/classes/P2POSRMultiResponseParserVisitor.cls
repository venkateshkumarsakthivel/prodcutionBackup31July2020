/**
* @name P2POSRMultiResponseParserVisitor
* @usage this class will be called from once response is parsed by callout framework, this class is responsible to parse
* XML and popluate this.p2POSRAuthorisationResponse variable, once parsing and population is completed.  response variable is passed
* finalize method will be called from batchable finish to perform DMLs and logging.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRMultiResponseParserVisitor implements AWSC_ResponseParserVisitor {
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    public List<P2POSRAuthorisationResponse> p2POSRAuthorisationResponses { get; private set; }
    public P2POSRAuthorisationResponse p2POSRAuthorisationResponse { get; private set; }
    public Dom.XmlNode xmlauthorisationORproviderResponseParentElement { get; private set; }
    public Dom.XmlNode authorisationORproviderResponse { get; private set; }
    public Dom.XmlNode xmlResponseParameterElement { get; private set; }
    
    public void visit(AWSC_ResponseParser responseParser) {
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        p2POSRAuthorisationResponses = new List<P2POSRAuthorisationResponse>();
        this.preParse();
    }
    private void preParse(){
        Dom.Document xmlDocument = new Dom.Document(); xmlDocument.load(this.responseText);
        Dom.XmlNode xmlRootElement = xmlDocument.getRootElement();
        Dom.XmlNode xmlResponseBodyElement;
        for(Dom.XmlNode xmlRootChildElement : xmlRootElement.getChildElements())  {
            if(xmlRootChildElement.getName().equalsIgnoreCase('Body')) {
                xmlResponseBodyElement = xmlRootChildElement;
                break;
            }
        }

        for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
            xmlauthorisationORproviderResponseParentElement = xmlResponseElement; break;
        }
        
        for(Dom.XmlNode xmlResponseElement:  xmlauthorisationORproviderResponseParentElement.getChildElements()) {
            
            if(xmlResponseElement.getName().equalsIgnoreCase('authorisationResponse')) {
                this.p2POSRAuthorisationResponse = new P2POSRAuthorisationResponse();
                this.p2POSRAuthorisationResponse.responseXML = this.responseText;
                if(200 == this.responseStatus) {
                   this.p2POSRAuthorisationResponse.status = 0 < this.p2POSRAuthorisationResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                        : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
                    this.parse(xmlResponseElement, this.p2POSRAuthorisationResponse);
                } else {
                    this.p2POSRAuthorisationResponse.status = 'FAULT';
                    this.p2POSRAuthorisationResponses.add(this.p2POSRAuthorisationResponse);
                }
            }
        }
    }
    
    private void parse(Dom.XmlNode xmlResponseElement, P2POSRAuthorisationResponse p2POSRAuthorisationResponse) {
        
        try {
            authorisationORproviderResponse = xmlResponseElement;
            p2POSRAuthorisationResponse.type = xmlauthorisationORproviderResponseParentElement.getName();
            
            for(Dom.XmlNode xmlResponseElement1 : authorisationORproviderResponse.getChildElements())  {
                if(xmlResponseElement1.getName().equalsIgnoreCase('TfNSWProviderNumber'))  {
                    p2POSRAuthorisationResponse.tfNSWProviderNumber = authorisationORproviderResponse.getChildElement('TfNSWProviderNumber', null).getText();
                } else if(xmlResponseElement1.getName().equalsIgnoreCase('responseParameter'))  {
                    xmlResponseParameterElement = xmlResponseElement1;
                }
            }
            
            for(Dom.XmlNode xmlResponseElement1 : xmlResponseParameterElement.getChildElements())  {
                if(xmlResponseElement1.getName().equalsIgnoreCase('OSRCustomerID'))  {
                    p2POSRAuthorisationResponse.RNSWCustomerID = xmlResponseElement1.getText();
                } else if(xmlResponseElement1.getName().equalsIgnoreCase('errors'))  {
                    for(Dom.XmlNode xmlErrorElement : xmlResponseParameterElement.getChildElement('errors', null).getChildElements())  {
                       p2POSRAuthorisationResponse.errors.add('errorId: ' + xmlErrorElement.getChildElement('errorID', null).getText() 
                                                                    + 'errorMessage: ' + xmlErrorElement.getChildElement('errorMessage', null).getText());
                    }
                }
                
            }
             system.debug('One Response>>>>' + p2POSRAuthorisationResponse);
             this.p2POSRAuthorisationResponses.add(p2POSRAuthorisationResponse);
        } catch(Exception xmlException)  {
            System.debug(xmlException.getMessage());
        }
    }
    
    /**
* this method will be called from finish context of batchable to finalize the DMLs
*/
    public void finalize()  {
        for(P2POSRAuthorisationResponse p2POSRAuthorisationResponse : p2POSRAuthorisationResponses){
            if(p2POSRAuthorisationResponse.status.equalsIgnoreCase('FAULT'))  {
                ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                applicationLogMessage.debugLevel = 'ERROR'; applicationLogMessage.payload = 'Request details sent to OSR';
                applicationLogMEssage.logCode = 'Revenue NSW Error';
                applicationLogMessage.logMessage = p2POSRAuthorisationResponse.responseXML;
                applicationLogMessage.source = 'P2POSRAuthorisationResponseParserVisitor'; applicationLogMessage.sourceFunction = 'finalize';
                ApplicationLogUtility.logMessage(applicationLogMessage);
            } else {
                Tax_Payer_Registration__c taxPayerRegistration = [SELECT Id, Revenue_NSW_Status__c, Levy_Rebate_Exempted__c, RNSWCustomerId__c, Date_Sent_to_Revenue__c, Sub_Status__c, IsProviderUpdate__c, IsAuthorisationUpdate__c, IsAuthorisationCancel__c
                                                                  FROM Tax_Payer_Registration__c 
                                                                  WHERE Service_Provider_Name__r.Customer_Number__c = :p2POSRAuthorisationResponse.tfNSWProviderNumber LIMIT 1];
                
             
                // change done to fix P2PSUPPORT-140
                if(taxPayerRegistration.Sub_Status__c != GlobalConstants.SUB_STATUS_PENDING_P2P && taxPayerRegistration.Levy_Rebate_Exempted__c == TRUE  ){
                   taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
                }
                taxPayerRegistration.RNSWCustomerId__c = String.isNotBlank(p2POSRAuthorisationResponse.RNSWCustomerID) 
                    ? p2POSRAuthorisationResponse.RNSWCustomerID
                    : '';
                
                taxPayerRegistration.Date_Sent_to_Revenue__c = System.now();
                system.debug(p2POSRAuthorisationResponse.status);
                taxPayerRegistration.Revenue_NSW_Status__c = true == p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_SUCCESS)
                    ? GlobalConstants.REVENUE_NSW_STATUS_SUCCESS : GlobalConstants.REVENUE_NSW_STATUS_ERROR;
                if(p2POSRAuthorisationResponse.type.equalsIgnoreCase('updateProviderResponse'))  {
                    taxPayerRegistration.IsProviderUpdate__c = false;
                } else if(p2POSRAuthorisationResponse.type.equalsIgnoreCase('updateAuthorisationResponse'))  {
                    taxPayerRegistration.IsAuthorisationUpdate__c = false;
                } else if(p2POSRAuthorisationResponse.type.equalsIgnoreCase('cancelAuthorisationResponse'))  {
                    taxPayerRegistration.IsAuthorisationCancel__c = false;
                }
                
                Database.update(taxPayerRegistration);
                
                if(p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
                    ApplicationLogMessage applicationLogMessage = new ApplicationLogMessage();
                    applicationLogMessage.debugLevel = 'ERROR'; applicationLogMessage.payload = 'Request details sent to OSR';
                    applicationLogMEssage.logCode = 'Revenue NSW Error';
                    applicationLogMessage.logMessage = p2POSRAuthorisationResponse.responseXML;
                    applicationLogMessage.source = 'P2POSRAuthorisationResponseParserVisitor'; applicationLogMessage.sourceFunction = 'finalize';
                    applicationLogMessage.referenceId = String.valueOf(taxPayerRegistration.Id);
                    ApplicationLogUtility.logMessage(applicationLogMessage);
                }            
            }
        }
    }
}