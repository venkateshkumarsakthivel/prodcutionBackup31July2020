/*
* Scheduler class which runs on daily basis at 04.00 am.
* Calls GetPaymentStatusRecordCount and GetPaymentStatusReportRequest api method.
*/
global with sharing class P2POSRGetPaymentStatusRCBatchable implements Database.Batchable<P2POSRRequestParameter>, Database.Stateful, Database.AllowsCallouts {

    private OSRPaymentStatusRCResponseParserVisitor paymentStatusRecordCountResponseParserVisitor {get; set;}
    private Date reportDate;
    
    public P2POSRGetPaymentStatusRCBatchable () {
        this(System.today().addDays(-1));
    }
    
    public P2POSRGetPaymentStatusRCBatchable (Date paymentDate) {
        this.reportDate = paymentDate;
        this.paymentStatusRecordCountResponseParserVisitor = new OSRPaymentStatusRCResponseParserVisitor();
    }
    
    private static P2POSRClient.OSR_REQUEST_TYPE type()  {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_RECORD_COUNT_REQUEST;
    }
    
    global Iterable<P2POSRRequestParameter> start(Database.BatchableContext batchableContext) {
        
        reportDate = Date.newInstance(reportDate.year(), reportDate.month(), reportDate.day());
        System.debug(LoggingLevel.INFO, '== P2POSRGetPaymentStatusRCBatchable Report Date ==' + String.valueOf(reportDate));            
        
        P2POSRRequestParameter p2POSRRequestParameter = new P2POSRRequestParameter();
        p2POSRRequestParameter.paymentStatusReportDate = String.valueOf(reportDate);
        
        List<P2POSRRequestParameter> requestParameters = new List<P2POSRRequestParameter>();
        requestParameters.add(p2POSRRequestParameter);
        
        return requestParameters;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<P2POSRRequestParameter> scope)  {
        
        P2POSRClient p2POSRClient;
        
        try {
            
            P2POSRRequestParameter p2POSRRequestParameter = scope.get(0);
             
            p2POSRClient = new P2POSRClient();
            p2POSRClient.call(P2POSRGetPaymentStatusRCBatchable.type(), this.paymentStatusRecordCountResponseParserVisitor, p2POSRRequestParameter);
            
        } catch(Exception ex)  {
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusRCBatchable Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusRCBatchable Exception ==' + ex.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext batchableContext) {
        P2POSRGetPaymentStatusReportResponse recordCountResponse = this.paymentStatusRecordCountResponseParserVisitor.p2POSRGetPaymentStatusReportResponse;
        
        System.debug(LoggingLevel.INFO, '== P2POSRGetPaymentStatusRCBatchable Response : Report Date ==' + recordCountResponse.reportDate);
        System.debug(LoggingLevel.INFO, '== P2POSRGetPaymentStatusRCBatchable Response : totalRecordCount ==' + recordCountResponse.totalRecordCount);
        System.debug(LoggingLevel.INFO, '== P2POSRGetPaymentStatusRCBatchable Response : totalPageCount ==' + recordCountResponse.totalPageCount);
        
        // TODO : Insert Application log for testing purpose only. Delete this afterwards
        Application_Log__c al = new Application_Log__c(Debug_Level__c = GlobalConstants.INFO, Log_Code__c = 'Revenue NSW Get Payment Status Report Record Count'
                                                       , Message__c = recordCountResponse.responseXML, Source__c = 'P2POSRGetPaymentStatusRCBatchable'
                                                       , Source_Function__c = 'finish', Reference_Id__c = String.valueOf(recordCountResponse.reportDate));
        Database.insert(al, false);
        
        if(recordCountResponse.totalRecordCount > 0) {
            
            P2POSRGetPaymentStatusReportBatchable p2POSRGetPaymentStatusReportBatchable
                = new P2POSRGetPaymentStatusReportBatchable(recordCountResponse.reportDate, recordCountResponse.totalRecordCount, recordCountResponse.totalPageCount);
            
            // We can total page count more than 100, we send Get Payment Status Report Request for each page.
            // Due to batch execution limits batch size is set to 1 here 
            Id ctxBatchId = Database.executeBatch(p2POSRGetPaymentStatusReportBatchable, Integer.valueOf(System.Label.Levy_RNSW_Integration_Batch_Size));
            if(!Test.isRunningTest()) {	FlexQueue.moveJobToFront(ctxBatchId);}
        }
    }
}