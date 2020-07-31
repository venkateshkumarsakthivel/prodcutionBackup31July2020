/**
* @name P2POSRAuthorisationResponseParserVisitor
* @usage this class will be called from once response is parsed by callout framework, this class is responsible to parse
* XML and popluate this.p2POSRAuthorisationResponse variable, once parsing and population is completed.  response variable is passed
* finalize method will be called from batchable finish to perform DMLs and logging.
* @author Arxxus P2P developer team
*/
public with sharing class P2POSRAuthorisationResponseParserVisitor implements AWSC_ResponseParserVisitor {
    public Integer responseStatus { get; set; }
    public String responseText { get; set; }
    public String requestType { get; set; }
    private String requestParameters { get; set; }
    public P2POSRAuthorisationResponse p2POSRAuthorisationResponse { get; private set; }
    public String tfNSWProviderNumber { get; private set; }
    public void visit(AWSC_ResponseParser responseParser) {
        P2POSRSOAPResponseParser parser = (P2POSRSOAPResponseParser) responseParser;
        this.responseStatus = parser.responseStatus;
        this.responseText = parser.responseText;
        this.tfNSWProviderNumber = ((P2POSRRequestParameter) parser.getOriginal().getRequestParameters()).tfNSWProviderNumber;
        this.tfNSWProviderNumber = String.isBlank(this.tfNSWProviderNumber) ? ((P2POSRRequestParameter) parser.getOriginal().getRequestParameters()).providerDetail.TfNSWProviderNumber 
            : this.tfNSWProviderNumber;
        this.requestType = String.valueOf(((P2POSRRequestParameter) parser.getOriginal().getRequestParameters()).requestType );
        this.requestParameters = String.valueOf(parser.getOriginal().getRequestParameters());
        this.p2POSRAuthorisationResponse = new P2POSRAuthorisationResponse();
        this.p2POSRAuthorisationResponse.responseXML = this.responseText;
        if(200 == this.responseStatus) { 
            if(this.responseText == '') {
                this.p2POSRAuthorisationResponse.status = 'FAULT';
            } else {
                this.parse();
                this.p2POSRAuthorisationResponse.status = 0 < this.p2POSRAuthorisationResponse.errors.size() ? GlobalConstants.REVENUE_NSW_STATUS_ERROR
                    : GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
            }
            
        } else {
            this.p2POSRAuthorisationResponse.status = 'FAULT';
            this.parseFault();
        }
    }
    
    private void parseFault() {
        try {
            System.debug(this.responseStatus);
            System.debug(this.responseText);
            Dom.Document xmlDocument = new Dom.Document(); xmlDocument.load(this.responseText);
            Dom.XmlNode xmlRootElement = xmlDocument.getRootElement();
            Dom.XmlNode xmlResponseBodyElement;
            for(Dom.XmlNode xmlRootChildElement : xmlRootElement.getChildElements())  {
                if(xmlRootChildElement.getName().equalsIgnoreCase('Body')) {
                    xmlResponseBodyElement = xmlRootChildElement;
                    break;
                }
            }
            
            Dom.XmlNode xmlFaultElement;
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                xmlFaultElement = xmlResponseElement; break;
            }
            
            this.p2POSRAuthorisationResponse.faults.add('faultcode: ' + xmlFaultElement.getChildElement('faultcode', null).getText() 
                                                        + ' faultstring: ' + xmlFaultElement.getChildElement('faultstring', null).getText());
        } catch(Exception xmlException)  {
            System.debug(xmlException.getMessage());
        }
    }
    
    private void parse() {
        
        try {
            System.debug(this.responseStatus);
            System.debug(this.responseText);
            Dom.Document xmlDocument = new Dom.Document(); xmlDocument.load(this.responseText);
            Dom.XmlNode xmlRootElement = xmlDocument.getRootElement();
            Dom.XmlNode xmlResponseBodyElement;
            for(Dom.XmlNode xmlRootChildElement : xmlRootElement.getChildElements())  {
                if(xmlRootChildElement.getName().equalsIgnoreCase('Body')) {
                    xmlResponseBodyElement = xmlRootChildElement;
                    break;
                }
            }
            Dom.XmlNode authorisationORproviderResponse;
            Dom.XmlNode xmlResponseParameterElement;
            Dom.XmlNode xmlauthorisationORproviderResponseParentElement;
            for(Dom.XmlNode xmlResponseElement : xmlResponseBodyElement.getChildElements())  {
                xmlauthorisationORproviderResponseParentElement = xmlResponseElement; break;
            }
            
            this.p2POSRAuthorisationResponse.type = xmlauthorisationORproviderResponseParentElement.getName();
            
            for(Dom.XmlNode xmlResponseElement : xmlauthorisationORproviderResponseParentElement.getChildElements())  {
                authorisationORproviderResponse = xmlResponseElement; break;
            }
            
            for(Dom.XmlNode xmlResponseElement : authorisationORproviderResponse.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('TfNSWProviderNumber'))  {
                    this.p2POSRAuthorisationResponse.tfNSWProviderNumber = authorisationORproviderResponse.getChildElement('TfNSWProviderNumber', null).getText();
                    this.tfNSWProviderNumber = String.isBlank(this.tfNSWProviderNumber) ? this.p2POSRAuthorisationResponse.tfNSWProviderNumber : this.tfNSWProviderNumber;
                } else if(xmlResponseElement.getName().equalsIgnoreCase('responseParameter'))  {
                    xmlResponseParameterElement = xmlResponseElement;
                }
            }
            
            for(Dom.XmlNode xmlResponseElement : xmlResponseParameterElement.getChildElements())  {
                if(xmlResponseElement.getName().equalsIgnoreCase('OSRCustomerID'))  {
                    this.p2POSRAuthorisationResponse.RNSWCustomerID = xmlResponseElement.getText();
                } else if(xmlResponseElement.getName().equalsIgnoreCase('errors'))  {
                    for(Dom.XmlNode xmlErrorElement : xmlResponseParameterElement.getChildElement('errors', null).getChildElements())  {
                        this.p2POSRAuthorisationResponse.errors.add('errorId: ' + xmlErrorElement.getChildElement('errorID', null).getText() 
                                                                    + ' errorMessage: ' + xmlErrorElement.getChildElement('errorMessage', null).getText());
                    }
                }
                
            }
            
        } catch(Exception xmlException)  {
            System.debug(xmlException.getMessage());
        }
    }
    
    /**
* this method will be called from finish context of batchable to finalize the DMLs
*/
    public Map<String, Sobject> finalize()  {
        Map<String, Sobject> updateOrInserts = new Map<String, SObject>();
        Tax_Payer_Registration__c taxPayerRegistration = null;
        Application_Log__c al = null;
        String revenueResponseMessage = System.now().format() + '\n' ;
        Boolean isValid = false;
        try {
            taxPayerRegistration = [SELECT Id, Revenue_NSW_Status__c, RNSWCustomerId__c, Levy_Rebate_Exempted__c, Date_Sent_to_Revenue__c, Sub_Status__c, IsProviderUpdate__c, IsAuthorisationUpdate__c, IsAuthorisationCancel__c
                                    , Taxi_Service_Provider_Number__c, Booking_Service_Provider_Number__c, IsBSPAuthorisationCreate__c, IsTSPAuthorisationCreate__c FROM Tax_Payer_Registration__c 
                                    WHERE Service_Provider_Name__r.Customer_Number__c = :this.tfNSWProviderNumber
                                    AND Revenue_NSW_Status__c = :GlobalConstants.REVENUE_NSW_STATUS_PENDING LIMIT 1];
            
            System.debug('this.p2POSRAuthorisationResponse : ' + this.p2POSRAuthorisationResponse);
            System.debug('taxPayerRegistration : ' + taxPayerRegistration.Id);
            
            if(!this.p2POSRAuthorisationResponse.status.equalsIgnoreCase('FAULT'))  {
                
                if(!this.p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
                    taxPayerRegistration.RNSWCustomerId__c = String.isNotBlank(this.p2POSRAuthorisationResponse.RNSWCustomerID) 
                        ? this.p2POSRAuthorisationResponse.RNSWCustomerID
                        : '';                    
          
               
                    // Changes done to fix P2PSUPPORT-140
                if(taxPayerRegistration.Sub_Status__c != GlobalConstants.SUB_STATUS_PENDING_P2P && taxPayerRegistration.Levy_Rebate_Exempted__c == TRUE  ){
                   taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_COMPLETED;
               }
                    
                    isValid = true;
                }
                
                taxPayerRegistration.Date_Sent_to_Revenue__c = System.now();
              System.debug('Rajni  ' + p2POSRAuthorisationResponse.status);  
                if(this.p2POSRAuthorisationResponse.type.equalsIgnoreCase('updateProviderResponse'))  {
                    taxPayerRegistration.IsProviderUpdate__c = false;
                    
                } else if(this.p2POSRAuthorisationResponse.type.equalsIgnoreCase('createAuthorisationResponse'))  {
                    taxPayerRegistration.IsBSPAuthorisationCreate__c = false;
                    taxPayerRegistration.IsTSPAuthorisationCreate__c = false;
                    
                } else if(this.p2POSRAuthorisationResponse.type.equalsIgnoreCase('updateAuthorisationResponse'))  {
                    taxPayerRegistration.IsAuthorisationUpdate__c = false;
                    
                } else if(this.p2POSRAuthorisationResponse.type.equalsIgnoreCase('cancelAuthorisationResponse'))  {
                    taxPayerRegistration.IsAuthorisationCancel__c = false;
                    // This is commented to fix PLEVY-774.
                    // Also this is no longer needed as we have modified queries to add all conditions which was not in place when this class was implemeted.
                    /*if(!this.p2POSRAuthorisationResponse.status.equalsIgnoreCase('FAULT') && !this.p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
                        if(!this.requestParameters.containsIgnoreCase('bspAuthorisation=null'))  {
                        taxPayerRegistration.Booking_Service_Provider_Number__c = null;
                        }
                        
                        if(!this.requestParameters.containsIgnoreCase('tspAuthorisation=null'))  {
                        taxPayerRegistration.Taxi_Service_Provider_Number__c = null;
                        }
                        }*/
                } 
                
                if(taxPayerRegistration.IsProviderUpdate__c == false && taxPayerRegistration.IsAuthorisationUpdate__c == false  && taxPayerRegistration.IsAuthorisationCancel__c == false 
                   && taxPayerRegistration.IsBSPAuthorisationCreate__c == false && taxPayerRegistration.IsTSPAuthorisationCreate__c == false) {
                       
                       if(this.p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_SUCCESS)) {
                           taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_SUCCESS;
                       }
                   }
                
                if(this.p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR)) {
                    taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_ERROR;
                }
                
            } else {
                taxPayerRegistration.Revenue_NSW_Status__c = GlobalConstants.REVENUE_NSW_STATUS_ERROR;
                taxPayerRegistration.Date_Sent_to_Revenue__c = System.now();
                //taxPayerRegistration.Sub_Status__c = GlobalConstants.SUB_STATUS_PENDING_P2P;
            }            
            
            if(this.requestType == 'OSR_CREATE_PROVIDER_AUTHORISATION_REQUEST') {
                revenueResponseMessage += 'Create Tax Payer Registration Request : ';
            } 
            else if(this.requestType == 'OSR_UPDATE_PROVIDER_AUTHORISATION_REQUEST') {
                revenueResponseMessage += 'Update Provider Request : ';
            }
            else if(this.requestType == 'OSR_CREATE_AUTHORISATION_REQUEST') {
                revenueResponseMessage += 'Create Authorisation Request : ';
            }            
            else if(this.requestType == 'OSR_UPDATE_AUTHORISATION_REQUEST') {
                revenueResponseMessage += 'Update Authorisation Request : '; 
            }
            else if(this.requestType == 'OSR_CANCEL_AUTHORISATION_REQUEST') {
                revenueResponseMessage += 'Cancel Authorisation Request : ';
            }
            
            if(this.p2POSRAuthorisationResponse.status.equalsIgnoreCase('FAULT') || this.p2POSRAuthorisationResponse.status.equalsIgnoreCase(GlobalConstants.REVENUE_NSW_STATUS_ERROR))  {
                al = new Application_Log__c(Debug_Level__c = GlobalConstants.ERROR, Integration_Payload__c = this.requestParameters, Log_Code__c = 'Revenue NSW Error'
                                            , Message__c = this.p2POSRAuthorisationResponse.responseXML, Source__c = 'P2POSRAuthorisationResponseParserVisitor'
                                            , Source_Function__c = 'finalize', Reference_Id__c = String.valueOf(taxPayerRegistration.Id));
                
                revenueResponseMessage += ' Error \n';
                Integer index = 1;
                for(String error : this.p2POSRAuthorisationResponse.errors) {
                    revenueResponseMessage += index++ + '. ' + error.substringAfter('errorMessage:') + ' \n';
                }
                for(String fault : this.p2POSRAuthorisationResponse.faults) {
                    revenueResponseMessage += index++ + '. ' + fault.substringAfter('faultstring:') + ' \n';
                }
                
                taxPayerRegistration.Revenue_Response_Message__c = revenueResponseMessage;
                taxPayerRegistration.Revenue_Response_Type__c = 'Error';
                
            } else {
                al = new Application_Log__c(Debug_Level__c = GlobalConstants.INFO, Integration_Payload__c = this.requestParameters, Log_Code__c = 'Revenue NSW Success'
                                            , Message__c = this.p2POSRAuthorisationResponse.responseXML, Source__c = 'P2POSRAuthorisationResponseParserVisitor'
                                            , Source_Function__c = 'finalize', Reference_Id__c = String.valueOf(taxPayerRegistration.Id));
                revenueResponseMessage += ' Success';
                taxPayerRegistration.Revenue_Response_Message__c = revenueResponseMessage;
                taxPayerRegistration.Revenue_Response_Type__c = 'Success';
            }
            
            updateOrInserts.put('tpr', taxPayerRegistration);
            updateOrInserts.put('al', al);
            return updateOrInserts;
        } catch (Exception recordNotFoundException)  {
            System.debug(recordNotFoundException.getMessage());
            System.debug(recordNotFoundException.getLineNumber());
            System.debug(recordNotFoundException.getStackTraceString());
            return null;
        }  
    }
}