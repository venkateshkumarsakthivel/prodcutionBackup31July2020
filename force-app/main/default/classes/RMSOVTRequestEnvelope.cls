/**
 * RMS OVT Request Bean
 * 
 * Author- pranoti.patil@arxxus.com
 */

public with sharing class RMSOVTRequestEnvelope {
    
    private static Map<String, String> caseStatusVsRmsStatus = new Map<String, String>();
    
    static{
        caseStatusVsRmsStatus.put(GlobalConstants.CHARGE_RETAINED, Label.RMS_Overturn_Status_Active);
        caseStatusVsRmsStatus.put(GlobalConstants.CHARGE_CORRECTED, Label.RMS_Overturn_Status);
    }
    
    public RMSOVTRequestEnvelope() {
        
    }

    //Header
    @TestVisible
    private RMSRequestHeader header;
    //Body
    @TestVisible
    private RMSOVTRequestBody body;
     
    
    public RMSRequestHeader getHeader(){
        return header;
    }
    
    /** needed for error handling in App Client*/
    public RMSOVTRequestBody getBody(){
        return body;
    }
    /**
     * Switch on Param record type - load parameter 
     */
    
    private RMSOVTRequestEnvelope(Case caseParam){
        header = new RMSRequestHeader(caseParam,P2PRmsOvtConfigReader.getLocationId(),P2PRmsOvtConfigReader.getLocationType());
        header.setPriority((Integer)P2PRmsOvtConfigReader.getCallPriority());
        header.setClientId(P2PRmsOvtConfigReader.getClientId());
        header.setClientSystemId(P2PRmsOvtConfigReader.getClientSystemId());
        header.setChannelType(P2PRmsOvtConfigReader.getChannelType());

        body = new RMSOVTRequestBody(caseParam);   
    }
    /**
     * Factory method to create the required object
     */    
    public static RMSOVTRequestEnvelope build(Case caseParam){
        return new RMSOVTRequestEnvelope(caseParam);
    }
    
    
//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization
//////////////////////////////////////////////////////////////////////////////////
    //Request body definition
    public virtual class RMSOVTRequestBody{
        
        //private transient final String RMS_STATUS = 'INACTIVE';
        
        private String licenceNumber;
        private RMSOffenceDetails offenceDetails;  
        private String caseId;
        private String status;

        
        public transient Case caseParam;
        public RMSOVTRequestBody(Case caseParam){
            this.caseParam = caseParam;
            this.licenceNumber = caseParam.Australian_Driver_Licence_Number_Formula__c;
            this.offenceDetails=new RMSOffenceDetails(caseParam);
            //this.caseId=caseParam.id;
            this.caseId=caseParam.CaseNumber;
            this.status= caseStatusVsRmsStatus.get(caseParam.Decision__c);
        }
    }

    public class RMSOffenceDetails{
        private String criminalChargeNumber;
        private String offenceRefNum;
        private String lawPartCode;
        public RMSOffenceDetails(Case caseParam){
            this.criminalChargeNumber=caseParam.Charge_Code_Identifier_Formula__c;
            this.offenceRefNum=caseParam.Offence_Code__c;
            this.lawPartCode=caseParam.Law_Part_Code__r.Name;
        }
    }  
}