/**
 * RMS SDO App Request Bean
 * 
 */
public class RMSSDORequestEnvelope {
    
    //Header
    @TestVisible
    private RMSSDORequestHeader header;
    //Body
    @TestVisible
    private RMSRequestBody body;
     
    
    public RMSSDORequestHeader getHeader(){
        return header;
    }
    
    /** needed for error handling in App Client*/
    public RMSRequestBody getBody(){
        return body;
    }
    /**
     * Switch on Param record type - load parameter 
     */
    private RMSSDORequestEnvelope(DVD_Query__c queryParam){
        header = new RMSSDORequestHeader(queryParam);
        body = new RMSRequestBody(queryParam);        
    }
    
    /**
     * Factory method to create the required object
     */    
    public static RMSSDORequestEnvelope build(DVD_Query__c queryParam){
        RMSSDORequestEnvelope envelope = new RMSSDORequestEnvelope(queryParam);
        return envelope;
    }
    
    
//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization
//////////////////////////////////////////////////////////////////////////////////
    //Request body definition
    public virtual class RMSRequestBody{
        
        protected transient final String CHECK_TYPE_ELIGIBILITY = 'P2PMinimumStandardsEligibility';
        private transient final String ID_TYPE_ROADS_LICENCING = 'RoadsRegistrationAndLicencing';
        private transient final String ASSESSMENT_TYPE = 'All';
        
        private String licenceNumber;
        private String dateOfBirth;  //yyyy-MM-dd       
        private String surname;
        private String idType;
        private String assessmentType;
        
        public transient DVD_Query__c queryParam;
        public RMSRequestBody(DVD_Query__c queryParam){
            this.queryParam = queryParam;
            //this.assessmentType = CHECK_TYPE_ELIGIBILITY; //String licenceNumber, Date dateOfBirth, String surname, String idType, String assessmentType
            this.licenceNumber = queryParam.Drivers_Licence_Number__c;
            this.dateOfBirth = (null == queryParam.Date_of_Birth__c) ? null : Datetime.newInstance(queryParam.Date_of_Birth__c.year(), queryParam.Date_of_Birth__c.month(),queryParam.Date_of_Birth__c.day()).format('yyyy-MM-dd');
			this.surname = queryParam.Last_Name__c;
            this.idType = ID_TYPE_ROADS_LICENCING;
            this.assessmentType	= ASSESSMENT_TYPE;
        }
    }    
   

}