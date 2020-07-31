/*
* Schedualer class which runs on 21th of every month to Submit assessment details to Revenue NSW.
* Calls createAssessment api method.
* Criteria:
* Assessment Type = "Assessment"
* Status = "Issued"
* Payment Due Date is on 26th of current month or first business day after 26th.

Modified : 16 Jan 2020: Venkatesh : Made the payment due date dynamic, accesing date from the custom setting.
*/
global with sharing class P2POSRCreateAssessmentBatchable implements Database.Batchable<P2POSRRequestParameter>, Database.Stateful, Database.AllowsCallouts {
    
    private BusinessHours businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
    
    //private List<P2POSRCUAssessmentResponseParserVisitor> p2POSRCUAssessmentResponseParserVisitors {get; set;}
    private List<P2POSRAssessmentResponse> p2POSRAssessmentResponses {get; set;}
    Map<String, String> levyAssessmentIdVsRequestParameter {get; set;}
    Map<String, String> levyAssessmentIdVsRequestType {get; set;}
    
    public P2POSRCreateAssessmentBatchable() {
        //this.p2POSRCUAssessmentResponseParserVisitors = new List<P2POSRCUAssessmentResponseParserVisitor>();
        this.p2POSRAssessmentResponses = new List<P2POSRAssessmentResponse>();
        this.levyAssessmentIdVsRequestParameter = new Map<String, String>();
        this.levyAssessmentIdVsRequestType = new Map<String, String>();
    }
    
    private static P2POSRClient.OSR_REQUEST_TYPE type()  {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_CREATE_ASSESSMENT_REQUEST;
    }
    
    global Iterable<P2POSRRequestParameter> start(Database.BatchableContext batchableContext) {
        
        List<P2POSRRequestParameter> listP2POSRRequestParameters = new List<P2POSRRequestParameter>();
        
        // Build Query to Get Assessment records
        
        // Get payment due date from custom settings
        AssesmentPaymentDueDate__c payDueDate = AssesmentPaymentDueDate__c.getInstance();
        Decimal dueDate = payDueDate.PaymentDuedate__c;
        system.debug('dueDate---------->'+integer.valueof(dueDate));
        
        // Get 26th of current month
        Date businessPaymentDueDayCurrentMonth = System.today();
        businessPaymentDueDayCurrentMonth = Date.newInstance(businessPaymentDueDayCurrentMonth.year(), businessPaymentDueDayCurrentMonth.month(), integer.valueof(dueDate));
        system.debug('businessPaymentDueDayCurrentMonth---------->'+businessPaymentDueDayCurrentMonth);
        // Check if date is business day else return next business day
        businessPaymentDueDayCurrentMonth = getBusinessDayOfCurrentMonth(businessPaymentDueDayCurrentMonth);
        businessPaymentDueDayCurrentMonth = Date.newInstance(businessPaymentDueDayCurrentMonth.year(), businessPaymentDueDayCurrentMonth.month(), businessPaymentDueDayCurrentMonth.day());
        
        System.debug(LoggingLevel.INFO, '== P2POSRCreateAssessmentBatchable businessPaymentDueDayCurrentMonth ==' + businessPaymentDueDayCurrentMonth);
        
        String assessmentStatusIssued = GlobalConstants.ASSESSMENT_STATUS_ISSUED;
        String assessmentTypeAssessment = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT;
        
        String strQuery = 'SELECT Id, Name, Status__c, Assessment_Type__c, Payment_Due_Date__c, '
            + 'Account__r.Customer_Number__c, Total_Levy_Amount__c, Period_Start_Date__c, Period_End_Date__c, '
            + 'TSP_Assessment_Number__c, BSP_Assessment_Number__c, TSP_Levy_Amount__c, BSP_Levy_Amount__c, '
            + 'Taxpayer_Registration__r.Booking_Service_Provider_Number__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c '
            + 'FROM Assessment__c '
            + 'WHERE Status__c = : assessmentStatusIssued ' 
            + 'AND Revenue_Assessment_Number_TSP__c = \'\' AND Revenue_Assessment_Number_BSP__c = \'\' ' +
            + 'AND Payment_Due_Date__c = : businessPaymentDueDayCurrentMonth';
        
        System.debug(LoggingLevel.INFO, '== P2POSRCreateAssessmentBatchable Generated Query ==' + strQuery);
        
        // Get Assessment Records
        List<Assessment__c> listAssessments = database.query(strQuery);
        
        System.debug('Assessment List: '+listAssessments);
        
        // Build P2POSRAssessment records from Assessment__c records and set into P2POSRRequestParameters 
        P2POSRAssessment assessmentForBspAuthorisation;
        P2POSRAssessment assessmentForTspAuthorisation;
        P2POSRAssessments p2POSRAssessments;
        P2POSRRequestParameter p2pOSRRequestParameter; 
        
        for(Assessment__c assessmentRecord : listAssessments) {
            
            Date reportingPeriodStartDate = assessmentRecord.Period_Start_Date__c;
            Date reportingPeriodEndDate = assessmentRecord.Period_End_Date__c;
            
            // Rebate Approved - Annual Assessment Scenario
            if(reportingPeriodStartDate.month() != reportingPeriodEndDate.month()) {
                reportingPeriodStartDate = reportingPeriodEndDate.toStartOfMonth();
            }
            
            p2POSRAssessments = new P2POSRAssessments();
            
            // We can have two Authorisations TSP and BSP linked to TaxPayer associated with Assessment
            if(assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__c != NULL) {
                assessmentForTspAuthorisation = new P2POSRAssessment();
                assessmentForTspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                assessmentForTspAuthorisation.regnType = 'TT';
                assessmentForTspAuthorisation.levyAssessmentID = assessmentRecord.TSP_Assessment_Number__c;
                assessmentForTspAuthorisation.amountPayable = assessmentRecord.TSP_Levy_Amount__c;
                assessmentForTspAuthorisation.dueDate = String.valueOf(assessmentRecord.Payment_Due_Date__c);
                assessmentForTspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                assessmentForTspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                
                p2POSRAssessments.assessmentForTspAuthorisation = assessmentForTspAuthorisation;
            }
            
            if(assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__c != NULL) {
                assessmentForBspAuthorisation = new P2POSRAssessment();
                assessmentForBspAuthorisation.TfNSWProviderNumber = assessmentRecord.Account__r.Customer_Number__c;
                assessmentForBspAuthorisation.regnType = 'TB';
                assessmentForBspAuthorisation.levyAssessmentID = assessmentRecord.BSP_Assessment_Number__c;
                assessmentForBspAuthorisation.amountPayable = assessmentRecord.BSP_Levy_Amount__c;
                assessmentForBspAuthorisation.dueDate = String.valueOf(assessmentRecord.Payment_Due_Date__c);
                assessmentForBspAuthorisation.reportingPeriodStartDate = String.valueOf(reportingPeriodStartDate);
                assessmentForBspAuthorisation.reportingPeriodEndDate = String.valueOf(reportingPeriodEndDate);
                
                p2POSRAssessments.assessmentForBspAuthorisation = assessmentForBspAuthorisation;
            } 
            
            p2pOSRRequestParameter = new P2POSRRequestParameter();
            p2pOSRRequestParameter.p2pOSRAssessments = p2POSRAssessments;
            listP2POSRRequestParameters.add(p2pOSRRequestParameter);
        }
        System.debug(LoggingLevel.INFO, '== P2POSRCreateAssessmentBatchable listP2POSRRequestParameters size ==' + listP2POSRRequestParameters.size());
        return listP2POSRRequestParameters;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<P2POSRRequestParameter> scope)  {
        
        P2POSRClient p2POSRClient;
        P2POSRCUAssessmentResponseParserVisitor visitor;
        
        try {
            
            for(P2POSRRequestParameter p2POSRRequestParameter : scope)  {
                visitor = new P2POSRCUAssessmentResponseParserVisitor();
                p2POSRClient = new P2POSRClient();
                p2POSRClient.call(P2POSRCreateAssessmentBatchable.type(), visitor, p2POSRRequestParameter);
                //this.p2POSRCUAssessmentResponseParserVisitors.add(visitor);
                this.p2POSRAssessmentResponses.addAll(visitor.p2POSRAssessmentResponses);
                for (P2POSRAssessmentResponse response : visitor.p2POSRAssessmentResponses) {
                    levyAssessmentIdVsRequestParameter.put(response.levyAssessmentID, visitor.requestParameters);
                    levyAssessmentIdVsRequestType.put(response.levyAssessmentID, visitor.requestType);
                }
            }
            
        } catch(Exception ex)  {
            System.debug(LoggingLevel.ERROR, '== P2POSRCreateAssessmentBatchable Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRCreateAssessmentBatchable Exception ==' + ex.getStackTraceString());
        }
    }
    
    /** perform DMLs based on status and response data available in each of response visitor for OSR requests. */
    global void finish(Database.BatchableContext batchableContext) {
        
        /*for(P2POSRCUAssessmentResponseParserVisitor visitor : this.p2POSRCUAssessmentResponseParserVisitors)  {
            visitor.finalize();
        }*/
        P2POSRCUAssessmentResponseParserVisitor.finalize(this.p2POSRAssessmentResponses, this.levyAssessmentIdVsRequestParameter, this.levyAssessmentIdVsRequestType);
        
    }
    
    // Get first business day on or after 26th of current month
    public Date getBusinessDayOfCurrentMonth(Date twentySixthOfCurrentMonth) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, twentySixthOfCurrentMonth);
        
        if(isInBusinessHours) {
            return twentySixthOfCurrentMonth;
        } else {
            twentySixthOfCurrentMonth = twentySixthOfCurrentMonth.addDays(1);
            return getBusinessDayOfCurrentMonth(twentySixthOfCurrentMonth);
        }
    }
}