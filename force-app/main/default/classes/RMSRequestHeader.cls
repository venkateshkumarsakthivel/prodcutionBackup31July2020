/**
 * REquest Header to use in RMS API Calls
 * This will be serialized to JSON
 * This will also be de-serialized from RMS Response
 */
public class RMSRequestHeader {

    @TestVisible
    private String messageId;        //1-62 chars
    private String messageGroupId;   //1-62 chars
    private String messageRelatedId; //1-62 chars
    private String createdTimestamp; //"2016-04-08T09:00:00"
    //private String expiryTimestamp; //"2016-04-08T09:30:00"
    private Integer priority;
    private String clientId;
    private String clientSystemId;
    private String channelType;
    private List<RMSRequestHeader.RMSRequestor> requestor;
    private List<RMSRequestHeader.RDVDlientLocation> location;
    private List<RMSRequestHeader.RMSHeaderExtension> extension;
    
    //Constants
    private transient final Integer CALL_PRIORITY = 0;        
    private transient final String CLIENT_ID = 'P2PREG'; //P2PPortalEligibilityCheck'
    private transient final String CHANNEL_TYPE = 'Branch';
    private transient final String RMS_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'hh:mm:ss';
    
    private String getFormattedDateTime(DateTime dt){
        return dt.format(RMS_DATETIME_FORMAT);
    }
    
    /** Utility methods */
    public List<RMSRequestHeader.RMSHeaderExtension> getExtension(){
        return extension;
    }
    
    public String getQueryId(){
        return messageId;
    }
    public String getQueryGroupId() {
        return messageGroupId;
    }
    public String getQueryType(){
        //from extensions
        List<RMSHeaderExtension> extns = extension;
        for(RMSHeaderExtension e: extns){
            if(e.name == NAME_REQUEST_TYPE){
                return e.value;
            }
        }        
        return null;
    }


    public void setPriority(Integer priority){
        this.priority=priority;
    }
    public void setClientId(String clientId){
        this.clientId=clientId;
    }
    public void setClientSystemId(String clientSystemId){
        this.clientSystemId=clientSystemId;
    }
    public void setChannelType(String channelType){
        this.channelType=channelType;
    }
    
    public RMSRequestHeader(DVD_Query__c queryParam){
        this.messageId = queryParam.Id;
        this.messageGroupId = queryParam.DVD_Query_Group__c;
        this.messageRelatedId = queryParam.DVD_Query_Group__c;
        this.createdTimestamp = getFormattedDateTime(System.now());//'2017-04-07T09:00:00'
        //this.expiryTimestamp = getFormattedDateTime(System.now().addHours(24));//'2017-04-07T09:30:00'
        this.priority = CALL_PRIORITY;
        this.clientId = CLIENT_ID;
        this.clientSystemId = CLIENT_ID;
        this.channelType = CHANNEL_TYPE;
        this.requestor = new RMSRequestHeader.RMSRequestor[]{new RMSRequestHeader.RMSRequestor(queryParam), 
                                new RMSRequestHeader.RMSRequestor(queryParam.DVD_Entity__r.Authorised_Service_Provider__r.Customer_Number__c,'Customer','Customer',null)};
        this.location = new RMSRequestHeader.RDVDlientLocation[]{new RMSRequestHeader.RDVDlientLocation(queryParam)};
//      this.extension = new RMSRequestHeader.RMSHeaderExtension[] { new RMSRequestHeader.RMSHeaderExtension(queryParam)};
        this.extension = buildRMSHeaderExtensions(queryParam);
    }  

    public RMSRequestHeader(Case caseInstance,String locationId,String locationType){
        this.messageId = caseInstance.Id;
        this.messageGroupId = caseInstance.ParentId;
        this.messageRelatedId = caseInstance.ParentId;
        this.createdTimestamp = getFormattedDateTime(System.now());
        
        //this.requestor = new RMSRequestHeader.RMSRequestor[]{new RMSRequestHeader.RMSRequestor(caseInstance.Employee_Number__c,'Customer','Staff',null)};
        this.requestor = new RMSRequestHeader.RMSRequestor[]{new RMSRequestHeader.RMSRequestor('TRNSPT','ExternalAgent','OrganisationCode',null)};
        this.location = new RMSRequestHeader.RDVDlientLocation[]{new RMSRequestHeader.RDVDlientLocation(locationId,locationType)};
    }      
    
//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization/Deseralization
//////////////////////////////////////////////////////////////////////////////////
    public class RMSRequestor {
        private final String requestorId;
        private final String requestorType;
        private final String requestorIdType;
        private final String requestorGroupType;
        
        private transient final String REQUESTOR_ID = 'TfNSW';
        private transient final String REQUESTOR_TYPE = 'ExternalAgent'; 
        private transient final String REQUESTOR_ID_TYPE = 'OrganisationCode';
        //private transient final String REQUESTOR_GROUP_TYPE  = 'requestorGroup';
        
        public RMSRequestor(DVD_Query__c queryParam){
            this.requestorId = REQUESTOR_ID; //@TODO : get this from the param - service provider id or org code
            this.requestorType = REQUESTOR_TYPE;
            this.requestorIdType = REQUESTOR_ID_TYPE;
            //this.requestorGroupType = REQUESTOR_GROUP_TYPE;
        }

         public RMSRequestor(String requestorId, String requestorType, String requestorIdType, String requestorGroupType){
            this.requestorId = requestorId;
            this.requestorType = requestorType;
            this.requestorIdType = requestorIdType;
            //this.requestorGroupType=requestorGroupType;
        }
    }
    public class RDVDlientLocation {
        private final String locationId;
        private final String locationType;
        
        private transient final String LOCATION_ID_P2P = 'P2P';
        private transient final String LOCATION_TYPE_P2P = 'Server';
        
        public RDVDlientLocation(DVD_Query__c queryParam){
            this.locationId = LOCATION_ID_P2P;
            this.locationType = LOCATION_TYPE_P2P;
        }

        public RDVDlientLocation(string locationId,String locationType){
            this.locationId = locationId;
            this.locationType = locationType;
        }
    }
    public class RMSHeaderExtension {
        public final String name;
        public final String value;
        
        public RMSHeaderExtension(String name, String value){
            this.name = name;
            this.value = value;
        }
    }    
    
    public transient final String NAME_ORG_CODE = 'organisationCode';
    public transient final String NAME_REQUEST_TYPE = 'requestType';
    public transient final String NAME_ENTITY_ID = 'entityId';
    
    private List<RMSHeaderExtension> buildRMSHeaderExtensions(DVD_Query__c queryParam) {
        List<RMSHeaderExtension> extns = new List<RMSHeaderExtension>();
        extns.add(new RMSHeaderExtension(NAME_ORG_CODE, Label.RMS_Org_Id)); //queryParam.Organisation_Code__c;
        extns.add(new RMSHeaderExtension(NAME_REQUEST_TYPE, queryParam.DVD_Query_For__c));
        //extns.add(new RMSHeaderExtension(NAME_ENTITY_ID, queryParam.DVD_Entity__c));
        return extns;
    }
    
}