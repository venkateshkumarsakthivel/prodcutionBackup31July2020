public class P2POSRReassessmentHandler {
    
    private List<P2POSRGetAssessmentResponseParserVisitor> p2POSRGetAssessmentResponseParserVisitors {get; set;}
    private List<P2POSRUReAssessmentResponseParserVisitor> P2POSRUReAssessmentResponseParserVisitors {get; set;}
    
    private Map<String,Decimal> assessmentNumberVSAmountCollected = new Map<String,Decimal>();
    
    public P2POSRClient.OSR_REQUEST_TYPE getRequest() {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_ASSESSMENT_REQUEST;
    }
    public P2POSRClient.OSR_REQUEST_TYPE updateRequest() {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_UPDATE_ASSESSMENT_REQUEST;
    }
    
    public List<Assessment__c> assessments;   
    
    public P2POSRReassessmentHandler(List<Assessment__c> assessments){
        this.p2POSRGetAssessmentResponseParserVisitors = new List<P2POSRGetAssessmentResponseParserVisitor>();
        this.P2POSRUReAssessmentResponseParserVisitors = new List<P2POSRUReAssessmentResponseParserVisitor>();
        this.assessments = assessments;
    }
    
    public void process() {
        
        try {
            //list of request parameters to fire get request
            List<P2POSRRequestParameter> osrGetRequestParameters = new List<P2POSRRequestParameter>();
            //list of request parameters to fire update request
            List<P2POSRRequestParameter> osrUpdateRequestParameters = new List<P2POSRRequestParameter>();
            
            //build request parameters for firing GET Request
            for(Assessment__c assessmentRecord : assessments) {
                
                Date reportingPeriodStartDate = assessmentRecord.Period_Start_Date__c;
                Date reportingPeriodEndDate = assessmentRecord.Period_End_Date__c;
                
                // Rebate Approved - Annual Assessment Scenario
                if(reportingPeriodStartDate.month() != reportingPeriodEndDate.month()) {
                    reportingPeriodStartDate = reportingPeriodEndDate.toStartOfMonth();
                }
                
                P2POSRAssessments p2POSRAssessments = new P2POSRAssessments();
                
                // We can have two Authorisations TSP and BSP linked to TaxPayer associated with Assessment
                if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != NULL) {
                    
                    P2POSRAssessment assessmentForTspAuthorisation = new P2POSRAssessment();
                    assessmentForTspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                    assessmentForTspAuthorisation.regnType = 'TT';
                    assessmentForTspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                    assessmentForTspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                    
                    p2POSRAssessments.assessmentForTspAuthorisation = assessmentForTspAuthorisation;
                }
                
                if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != NULL) {
                    
                    P2POSRAssessment assessmentForBspAuthorisation = new P2POSRAssessment();
                    assessmentForBspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                    assessmentForBspAuthorisation.regnType = 'TB';
                    assessmentForBspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                    assessmentForBspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                    
                    p2POSRAssessments.assessmentForBspAuthorisation = assessmentForBspAuthorisation;
                }
                
                P2POSRRequestParameter p2pOSRRequestParameter = new P2POSRRequestParameter();
                p2pOSRRequestParameter.p2pOSRAssessments = p2POSRAssessments;
                osrGetRequestParameters.add(p2pOSRRequestParameter);
            }
            
            System.debug(LoggingLevel.INFO, '== osrGetRequestParameters size ==' + osrGetRequestParameters.size());
            
            for(P2POSRRequestParameter requestParameter : OSRGetRequestParameters)  {
                P2POSRGetAssessmentResponseParserVisitor visitor = new P2POSRGetAssessmentResponseParserVisitor();
                P2POSRClient p2POSRClient = new P2POSRClient();
                p2POSRClient.call(getRequest(), visitor, requestParameter);
                this.p2POSRGetAssessmentResponseParserVisitors.add(visitor);
            }
            
            if(this.p2POSRGetAssessmentResponseParserVisitors != null) {
                for(P2POSRGetAssessmentResponseParserVisitor visitor : this.p2POSRGetAssessmentResponseParserVisitors) {
                    for(P2POSRGetAssessmentResponse response : visitor.finalize()) {
                        for(P2POSRAssessment osrAssessment : response.p2POSRAssessment) {
                            if(!assessmentNumberVSAmountCollected.containsKey(osrAssessment.OSRAssessmentNumber)) {
                                assessmentNumberVSAmountCollected.put(osrAssessment.OSRAssessmentNumber, osrAssessment.amountCollected);
                            } 
                        }
                    }
                }
            }
            
            System.debug(LoggingLevel.INFO, '== assessmentNumberVSAmountCollected ==' + assessmentNumberVSAmountCollected);
            
            // build request parameters for firing UPDATE Request
            for(Assessment__c assessmentRecord : assessments) {
                
                Date reportingPeriodStartDate = assessmentRecord.Period_Start_Date__c;
                Date reportingPeriodEndDate = assessmentRecord.Period_End_Date__c;
                
                // Rebate Approved - Annual Assessment Scenario
                if(reportingPeriodStartDate.month() != reportingPeriodEndDate.month()) {
                    reportingPeriodStartDate = reportingPeriodEndDate.toStartOfMonth();
                }
                
                P2POSRAssessments p2POSRAssessments = new P2POSRAssessments();
                
                // We can have two Authorisations TSP and BSP linked to TaxPayer associated with Assessment
                if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != NULL && 
                   assessmentNumberVSAmountCollected.containskey(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_TSP__c)) {
                       
                       P2POSRAssessment assessmentForTspAuthorisation = new P2POSRAssessment();
                       assessmentForTspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                       assessmentForTspAuthorisation.regnType = 'TT';
                       assessmentForTspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                       assessmentForTspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                       assessmentForTspAuthorisation.OSRAssessmentNumber = assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_TSP__c;
                       assessmentForTspAuthorisation.dueDate = String.valueOf( System.today().addDays(7));
                       assessmentForTspAuthorisation.netAmount = assessmentRecord.TSP_Levy_Amount__c - assessmentNumberVSAmountCollected.get(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_TSP__c);
                       assessmentForTspAuthorisation.amountPayable = assessmentRecord.TSP_Levy_Amount__c;
                       assessmentForTspAuthorisation.levyAssessmentID = assessmentRecord.TSP_Assessment_Number__c;
                       assessmentForTspAuthorisation.amountCollected = assessmentNumberVSAmountCollected.get(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_TSP__c);
                       
                       p2POSRAssessments.assessmentForTspAuthorisation = assessmentForTspAuthorisation;
                   }
                
                if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != NULL && 
                   assessmentNumberVSAmountCollected.containskey(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_BSP__c)) {
                       
                       P2POSRAssessment assessmentForBspAuthorisation = new P2POSRAssessment();
                       assessmentForBspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                       assessmentForBspAuthorisation.regnType = 'TB';
                       assessmentForBspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                       assessmentForBspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                       assessmentForBspAuthorisation.OSRAssessmentNumber = assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_BSP__c;
                       assessmentForBspAuthorisation.dueDate = String.valueOf(System.today().addDays(7));
                       assessmentForBspAuthorisation.netAmount = assessmentRecord.BSP_Levy_Amount__c - assessmentNumberVSAmountCollected.get(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_BSP__c);
                       assessmentForBspAuthorisation.amountPayable = assessmentRecord.BSP_Levy_Amount__c;
                       assessmentForBspAuthorisation.levyAssessmentID = assessmentRecord.BSP_Assessment_Number__c;
                       assessmentForBspAuthorisation.amountCollected = assessmentNumberVSAmountCollected.get(assessmentRecord.Related_Assessment__r.Revenue_Assessment_Number_BSP__c);
                       
                       p2POSRAssessments.assessmentForBspAuthorisation = assessmentForBspAuthorisation;
                   }
                
                P2POSRRequestParameter p2pOSRRequestParameter = new P2POSRRequestParameter();
                p2pOSRRequestParameter.p2pOSRAssessments = p2POSRAssessments;
                osrUpdateRequestParameters.add(p2pOSRRequestParameter);
            } 
            
            System.debug(LoggingLevel.INFO, '== osrUpdateRequestParameters==' + osrUpdateRequestParameters[0]);
            
            for(P2POSRRequestParameter requestParameter : osrUpdateRequestParameters) {
                
                System.debug('request parameters: ' + requestParameter);
                
                P2POSRUReAssessmentResponseParserVisitor visitor = new P2POSRUReAssessmentResponseParserVisitor();
                
                if(requestParameter.p2pOSRAssessments.assessmentForTspAuthorisation != null) {
                    visitor.tspAmountPaid = requestParameter.p2pOSRAssessments.assessmentForTspAuthorisation.amountCollected;
                    
                    // We dont need to send this param to RNSW 
                    requestParameter.p2pOSRAssessments.assessmentForTspAuthorisation.amountCollected = null;
                }
                if(requestParameter.p2pOSRAssessments.assessmentForBspAuthorisation != null) {
                    visitor.bspAmountPaid = requestParameter.p2pOSRAssessments.assessmentForBspAuthorisation.amountCollected;
                    
                    // We dont need to send this param to RNSW 
                    requestParameter.p2pOSRAssessments.assessmentForBspAuthorisation.amountCollected = null;
                }
                
                P2POSRClient p2POSRClient = new P2POSRClient();
                p2POSRClient.call(updateRequest(), visitor, requestParameter);
                this.P2POSRUReAssessmentResponseParserVisitors.add(visitor);
            }
            
            if(this.P2POSRUReAssessmentResponseParserVisitors != null) {
                for(P2POSRUReAssessmentResponseParserVisitor visitor : this.P2POSRUReAssessmentResponseParserVisitors) {
                    visitor.finalize();
                }
            }
            
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, '== Error Occured either in firing GET request or processing response received from GET request ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRReassessmentBatchable Exception ==' + ex.getStackTraceString());
        }
    }
}