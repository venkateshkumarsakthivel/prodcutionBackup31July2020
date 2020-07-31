/**
* @name P2POSRAssessmentResponse
* @usage this class hold attributes to store values from OSR SOAP request corresponds to assessment create, update
* @author Arxxus P2P developer team
*/
public class P2POSRAssessmentResponse {
    public String levyAssessmentID { get; set; }
    public String OSRAssessmentNumber { get; set; }
    public List<String> errors { get; set; }
    public List<String> faults { get; set; }
    public String type { get; set; }
    
    public String billerCode { get; set; }
    public String reference { get; set; }
    public String OSRCustomerId { get; set; }
    
    public String Status { get; set; }
    public String responseXML { get; set; }
    
    
    public P2POSRAssessmentResponse()  {
        this.errors = new List<String>();
        this.faults = new List<String>();
    }
}