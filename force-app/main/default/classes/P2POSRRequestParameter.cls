/**
* @name P2POSRRequestParameter
* @usage abstract P2POSRRequestParameter class provides parameters to be passed to the request
* this will combination of request parameters in all required by OSR requests.
* @author Arxxus P2P developer team
*/
public class P2POSRRequestParameter {
    public String referenceId { get; set; }
    public P2POSRClient.OSR_REQUEST_TYPE requestType { get; set; }
    public P2POSRProviderDetail providerDetail { get; set; }
    public P2POSRAuthorisations providerAuthorisations { get; set; }
    public String tfNSWProviderNumber { get; set; }
    public P2POSRAssessment p2pOSRAssessment { get; set; }
    public P2POSRAssessments p2pOSRAssessments { get; set; }
    public String regnType { get; set; }
    public String startDate { get; set; }
    public String endDate { get; set; }
    public String includeAllVersion { get; set; }
    public String paymentStatusReportDate { get; set; }
    public Integer paymentStatusReportRequestPage { get; set; }
}