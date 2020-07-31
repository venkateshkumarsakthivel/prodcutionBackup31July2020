public class P2POSRGetAssessmentResponse {
 	 public String TfNSWProviderNumber { get; set; }
	 public String regnType { get; set; }
	 public String startDate { get; set; }
	 public String endDate { get; set; }
     public List<String> errors { get; set; }
     public String type { get; set; }
     public String Status { get; set; }
     public String responseXML { get; set; }
     public List<P2POSRAssessment> p2POSRAssessment { get; set; }
     public List<P2POSRAssessment.P2POSRTransaction> p2POSRTransactions { get; set; }
    
    public P2POSRGetAssessmentResponse () {
		this.errors = new List<String>();
        this.p2POSRAssessment = new List<p2POSRAssessment>();
        this.p2POSRTransactions = new List<P2POSRAssessment.P2POSRTransaction>();
    } 
}