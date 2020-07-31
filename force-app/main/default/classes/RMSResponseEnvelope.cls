/**
 * RMS Response Structure 
 * JSON Response to P2P DVD Calls :
 */
public class RMSResponseEnvelope {
    
    //Header
    @TestVisible
    private RMSRequestHeader header;
    
    @TestVisible
    private ResponseStatusMessages statusMessages;
    //Body
    @TestVisible
    private RMSResponseBody body;
    
    //for mock testing
    public void setHeader(RMSRequestHeader header){
        this.header = header;
    }
    public void setStatusMessages(ResponseStatusMessages statusMessages){
        this.statusMessages = statusMessages;
    }
    
    public void setBody(RMSResponseBody body){
        this.body = body;
    }
    
    
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
    
    public String getAisInspectionDate(){
        return body.lastPassedAISInspectionDate;
    }
    
    public String getEligibilityStatus() {
        if(body.vehicleEligibilityStatus != null){
            return body.vehicleEligibilityStatus;
        } else {
            return null;
        }
        /*
        if(body.product.vehicleAssessment != null) {
            return body.product.vehicleAssessment.eligibilityStatus;
        }else if(body.product.licenceAssessment != null) {
            return body.product.licenceAssessment.eligibilityStatus;
        }else{
            return null;
        }
        */
    }
    
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
    
    //RMS Transaction Id String
    public String getExternalTransactionId(){
        return body.getQueryId();
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

    public class VehicleAssessmentProduct{
        
        //@XXX - check typo on vehicle/vechicle
        RMSParameters.VehicleParameter vechicleParameter;
        
        @TestVisible
        String eligibilityStatus;
    }
    public class LicenceAssessmentProduct{
        RMSParameters.LicenceParameter licenceParameter;
        @TestVisible
        String eligibilityStatus;
        RMSParameters.ClassPart[] licenceAssessmentDetails;
    }
    
    public class RMSResponseBody{
        /*
        String assessmentType;
        RMSParameters.QueryPart query;
        @TestVisible
        ResponseProduct product;
        public String getQueryId(){return query.Id;}
        */
        private String transactionId;
        private String vehicleEligibilityStatus;
        private String lastPassedAISInspectionDate;
        
        public String getQueryId(){return transactionId;}
    }
    
    public class ResponseProduct{
        
        @TestVisible
        private LicenceAssessmentProduct licenceAssessment;
        @TestVisible
        private VehicleAssessmentProduct vehicleAssessment;
    }
    
}