public with sharing class P2POSRGetPaymentStatusReportResponse {
    
    public String reportDate { get; set; }
    public Integer totalRecordCount { get; set; }
    public Integer totalPageCount { get; set; }
    public Integer currentPage { get; set; }
    public List<P2POSRPaymentStatus> paymentStatusList { get; set; }
    public List<String> errors { get; set; }
    public String Status { get; set; }
    public String requestType { get; set; }
    public String responseXML { get; set; }
    
    public P2POSRGetPaymentStatusReportResponse() {
        this.errors = new List<String>();
        paymentStatusList = new List<P2POSRPaymentStatus>();
    }
}