/**
 * RMS Response Structure 
 * JSON Response to P2P DVD Calls :
 */
public class RMSSDOResponseEnvelope {
    
    //Header
    @TestVisible
    private RMSSDORequestHeader header;
    
    @TestVisible
    private ResponseStatusMessages statusMessages;
    //Body
    @TestVisible
    private RMSResponseBody body;
    
 //private PTCodeDetails PTCodeDetails;
    
    //for mock testing
    public void setHeader(RMSSDORequestHeader header){
        this.header = header;
    }
    public void setStatusMessages(ResponseStatusMessages statusMessages){
        this.statusMessages = statusMessages;
    }
    
    public void setBody(RMSResponseBody body){
        this.body = body;
    }
    // public void setPTCodeDetails(PTCodeDetails PTCodeDetails){
      //  this.PTCodeDetails = PTCodeDetails;
    //}
    
    //Message id = DVD_Query__c.Id
    public String getQueryId(){
        return header.getQueryId();
    }
    //Message type = DVD_Query__c.DVD_Query_For__c
    public String getQueryType(){
        return header.getQueryType();
    }
    
    //ERROR|SUCCESS
    public String getOverallStatus(){
        return statusMessages.overallStatus;
    }
    
    //RMS Transaction Id String
    public String getTransactionId(){
        return body.transactionId;
    }

    public String getLicenceCheckStatus() {
        return body.licenceCheckStatus;
    }
    
    public String getTenureCheckStatus() {
        return body.licenceTenureStatus;
    }
    
    public String getDrivingOffenceStatus() {
        return body.drivingOffenceStatus;
    }
    
    public String getCriminalChargeCheckStatus() {
        return body.criminalChargeStatus;
    }
    
    public String getactiveStartDate() {
       
        return body.PTCodeDetails!=null ?body.PTCodeDetails.activeStartDate:null;
        
    }
     public String getlastTerminationDate() {
       return body.PTCodeDetails!=null ?body.PTCodeDetails.lastTerminationDate:null;     
    }
    //public String getlastTerminationDate() {
       // return PTCodeDetails.lastTerminationDate;
   // }
       
    //if Error -> DATA VALIDATION | SYSTEM ERROR
    public String getMessageCode(){
        if(statusMessages.message == null || statusMessages.message.isEmpty()){
            return null;
        }
        return statusMessages.message[0].code;
    }
    //if Error -> Text Description
    public String getMessageDescription(){
        if(statusMessages.message == null || statusMessages.message.isEmpty()){
            return null;
        }
        return statusMessages.message[0].description;
    }
    
    

//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization/Deserialization
//////////////////////////////////////////////////////////////////////////////////
    //Response Structure definitions
    public class ResponseMessage{
        String severity;
        String code;
        String description;
    }
    
    //Overall Response Status messages 
    public class ResponseStatusMessages {
        @TestVisible
        String overallStatus;
        ResponseMessage[] message;
    }
    
    public class LicenceAssessmentProduct{
        RMSSDORequestEnvelope.RMSRequestBody licenceParameter;
        @TestVisible
        String eligibilityStatus;
        RMSSDOParameters.ClassPart[] licenceAssessmentDetails;
    }
    
    public class RMSResponseBody{
        String transactionId;
        String licenceCheckStatus;
        String drivingOffenceStatus;
        String safetyOffenceStatus;
        String criminalChargeStatus;
        String licenceTenureStatus;
        PTCodeClass PTCodeDetails;
    }
      public class PTCodeClass{
       String activeStartDate;
       String lastTerminationDate;
            
    }
}