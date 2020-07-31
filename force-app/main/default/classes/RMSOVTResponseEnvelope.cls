/**
 * RMS Response Structure 
 * JSON Response to P2P OVT Calls 
 * Author- pranoti.patil@arxxus.com
 */

public with sharing class RMSOVTResponseEnvelope {
	public RMSOVTResponseEnvelope() {
		
	}

	    @TestVisible
    private RMSRequestHeader header;
    
    @TestVisible
    private ResponseStatusMessages statusMessages;
    
    
    //for mock testing
    public void setHeader(RMSRequestHeader header){
        this.header = header;
    }
    public void setStatusMessages(ResponseStatusMessages statusMessages){
        this.statusMessages = statusMessages;
    }
    
       
    //Message id = Case.Id
    public String getQueryId(){
        return header.getQueryId();
    }
    //Message type = DVD_Query__c.DVD_Query_For__c
    //public String getQueryType(){
        //return header.getQueryType();
    //} 
    
    //ERROR|SUCCESS
    public String getOverallStatus(){
        return statusMessages.overallStatus;
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
}