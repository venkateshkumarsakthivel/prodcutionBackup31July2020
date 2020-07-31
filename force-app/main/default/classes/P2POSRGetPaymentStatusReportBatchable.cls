/*
* Scheduler class which runs on daily basis at 04:00 am.
* Calls GetPaymentStatusReportRequest api method.
*/
global class P2POSRGetPaymentStatusReportBatchable implements Database.Batchable<P2POSRRequestParameter>, Database.Stateful, Database.AllowsCallouts {
    
    public String reportDate { get; set; }
    public Integer requestPage { get; set; }
    public Integer totalRecordCount { get; set; }
    public Integer totalPageCount { get; set; }
    private List<OSRPaymentStatusReportParserVisitor> oSRPaymentStatusReportParserVisitors { get; set; }
    
    public P2POSRGetPaymentStatusReportBatchable (String reportDate, Integer totalRecordCount, Integer totalPageCount) {
        this.reportDate = reportDate;
        this.totalRecordCount = totalRecordCount;
        this.totalPageCount = totalPageCount;
        oSRPaymentStatusReportParserVisitors = new List<OSRPaymentStatusReportParserVisitor>();
    }
    
    private static P2POSRClient.OSR_REQUEST_TYPE type()  {
        return P2POSRClient.OSR_REQUEST_TYPE.OSR_GET_PAYMENT_STATUS_REPORT_REQUEST;
    }
    
    global Iterable<P2POSRRequestParameter> start(Database.BatchableContext batchableContext) {
        
        List<P2POSRRequestParameter> requestParameters = new List<P2POSRRequestParameter>();
        P2POSRRequestParameter p2POSRRequestParameter;
        for(Integer i = 0; i < this.totalPageCount; i++) {
            p2POSRRequestParameter = new P2POSRRequestParameter();
            p2POSRRequestParameter.paymentStatusReportDate = String.valueOf(reportDate);
            p2POSRRequestParameter.paymentStatusReportRequestPage = i + 1;
            requestParameters.add(p2POSRRequestParameter);
        }
        
        return requestParameters;
    }
    
    public void execute(Database.BatchableContext batchableContext, List<P2POSRRequestParameter> scope)  {
        
        OSRPaymentStatusReportParserVisitor visitor;
        P2POSRClient p2POSRClient;
        
        try {
            
            for(P2POSRRequestParameter p2POSRRequestParameter : scope)  {
                visitor = new OSRPaymentStatusReportParserVisitor();
                p2POSRClient = new P2POSRClient();
                p2POSRClient.call(P2POSRGetPaymentStatusReportBatchable.type(), visitor, p2POSRRequestParameter);
                this.oSRPaymentStatusReportParserVisitors.add(visitor);
            }
            
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusReportBatchable Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusReportBatchable Exception ==' + ex.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext batchableContext) {
        
        try {
            for(OSRPaymentStatusReportParserVisitor visitor : this.oSRPaymentStatusReportParserVisitors)  {
                visitor.finalize();
            }
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusReportBatchable Exception ==' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, '== P2POSRGetPaymentStatusReportBatchable Exception ==' + ex.getStackTraceString());
        }
    }
}