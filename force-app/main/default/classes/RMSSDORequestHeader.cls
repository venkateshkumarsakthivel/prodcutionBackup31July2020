/**
 * REquest Header to use in RMS API Calls
 * This will be serialized to JSON
 * This will also be de-serialized from RMS Response
 */
public class RMSSDORequestHeader {

    @TestVisible
    private String messageId;        //1-62 chars
    private String messageGroupId;   //1-62 chars
    private String messageRelatedId; //1-62 chars
    private String createdTimestamp; //"2016-04-08T09:00:00"
    private Integer priority;
    private String clientId;
    private String clientSystemId;
    private String channelType;
    private List<RMSSDORequestHeader.RMSRequestor> requestor;
    private List<RMSSDORequestHeader.RSDOClientLocation> location;
    
    //Constants
    private transient final Integer CALL_PRIORITY = 0;        
    private transient final String CLIENT_ID = 'P2PREG'; //P2PPortalEligibilityCheck'
    private transient final String CHANNEL_TYPE = 'Branch';
    private transient final String RMS_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'hh:mm:ss';
    
    private String getFormattedDateTime(DateTime dt){
        return dt.format(RMS_DATETIME_FORMAT);
    }
    
    public String getQueryId(){
        return messageId;
    }
    public String getQueryGroupId() {
        return messageGroupId;
    }
    public String getQueryType(){
        //from extensions
        return null;
    }
    
    public RMSSDORequestHeader(DVD_Query__c queryParam){
        this.messageId = queryParam.Id;
        this.messageGroupId = queryParam.DVD_Query_Group__c;
        this.messageRelatedId = queryParam.DVD_Query_Group__c;
        this.createdTimestamp = getFormattedDateTime(System.now());//'2017-04-07T09:00:00'
        this.priority = CALL_PRIORITY;
        this.clientId = CLIENT_ID;
        this.clientSystemId = CLIENT_ID;
        this.channelType = CHANNEL_TYPE;
        
        this.requestor = new RMSSDORequestHeader.RMSRequestor[]{new RMSSDORequestHeader.RMSRequestor(queryParam.DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c,'Customer','Customer')};
        //this.requestor = new RMSSDORequestHeader.RMSRequestor[]{new RMSSDORequestHeader.RMSRequestor('7834','Customer','Staff')};
        this.requestor.add(new RMSSDORequestHeader.RMSRequestor('TRNSPT','ExternalAgent','OrganisationCode'));
        this.location = new RMSSDORequestHeader.RSDOClientLocation[]{new RMSSDORequestHeader.RSDOClientLocation(queryParam)};
    }    
    
    //////////////////////////////////////////////////////////////////////////////////
    //Data Structures for Serialization/Deseralization
    //////////////////////////////////////////////////////////////////////////////////
    public class RMSRequestor {
        private final String requestorId;
        private final String requestorType;
        private final String requestorIdType;
        
        public RMSRequestor(DVD_Query__c queryParam){
            
        }
        public RMSRequestor(String REQUESTOR_ID, String REQUESTOR_TYPE, String REQUESTOR_ID_TYPE){
            this.requestorId = REQUESTOR_ID;
            this.requestorType = REQUESTOR_TYPE;
            this.requestorIdType = REQUESTOR_ID_TYPE;
        }
        
    }
    public class RSDOClientLocation {
        private final String locationType;
        private final String locationId;
        
        
        private transient final String LOCATION_ID = '12';
        private transient final String LOCATION_TYPE = 'Branch';
        
        public RSDOClientLocation(DVD_Query__c queryParam){
            this.locationId = LOCATION_ID;
            this.locationType = LOCATION_TYPE;
        }
    }
    
    
}