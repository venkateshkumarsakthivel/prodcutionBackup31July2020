/**
 * RMS DVD App Request Bean
 * 
 */
public class RMSRequestEnvelope {
    
    //Header
    @TestVisible
    private RMSRequestHeader header;
    //Body
    @TestVisible
    private RMSRequestBody body;
     
    
    public RMSRequestHeader getHeader(){
        return header;
    }
    
    /** needed for error handling in App Client*/
    public RMSRequestBody getBody(){
        return body;
    }
    /**
     * Switch on Param record type - load parameter 
     */
    private RMSRequestEnvelope(DVD_Query__c queryParam){
        header = new RMSRequestHeader(queryParam);
        if(queryParam.DVD_Query_For__c == 'Driver'){
            body = new LicenceRequestBody(queryParam);        
        }else if (queryParam.DVD_Query_For__c == 'Vehicle'){
            body = new VehicleRequestBody(queryParam);        
        }else {
            body = new AssessmentRequestBody(queryParam);        
        }
    }
    
    /**
     * Factory method to create the required object
     */    
    public static RMSRequestEnvelope build(DVD_Query__c queryParam){
        RMSRequestEnvelope envelope = new RMSRequestEnvelope(queryParam);
        return envelope;
    }
    
    
//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization
//////////////////////////////////////////////////////////////////////////////////
    //Request body definition
    public virtual class RMSRequestBody{
        
        protected transient final String CHECK_TYPE_ASSESSMENT = 'P2PMinimumStandardsAssessment';
        protected transient final String CHECK_TYPE_ELIGIBILITY = 'P2PMinimumStandardsEligibility';
        protected transient final String CHECK_TYPE_DEFAULT = 'P2PMinimumStandardsEligibility';
        
        protected transient String assessmentType = CHECK_TYPE_DEFAULT;
        protected RMSParameters.LicenceParameter licenceParameter; 
        protected RMSParameters.VehicleParameter vehicleParameter;
        protected RMSParameters.AssessmentParameter query;
        protected String plateNumber;
        protected String plateType;
        protected String chassisOrVIN;
        
        public transient DVD_Query__c queryParam;
        public RMSRequestBody(DVD_Query__c queryParam){
            this.queryParam = queryParam;
            this.plateNumber = String.isEmpty(queryParam.Plate_Number__c) ? null : queryParam.Plate_Number__c;
            this.plateType = String.isEmpty(queryParam.Plate_Type__c) ? null : queryParam.Plate_Type__c;
            this.chassisOrVIN = queryParam.VIN_Number_or_Chassis_Number__c;
        }
    }    
    public class LicenceRequestBody extends RMSRequestBody{
        private transient final String ID_TYPE_ROADS_LICENCING = 'RoadsRegistrationAndLicencing';
        private transient final String ASSESSMENT_TYPE = 'RoadsRegistrationAndLicencing';
        public LicenceRequestBody(DVD_Query__c queryParam){
            super(queryParam);
            this.assessmentType = CHECK_TYPE_ELIGIBILITY;
            this.licenceParameter = new RMSParameters.LicenceParameter(queryParam.Drivers_Licence_Number__c,
                                                        ID_TYPE_ROADS_LICENCING,
                                                        queryParam.Last_Name__c,
                                                        queryParam.Date_of_Birth__c,
                                                        ASSESSMENT_TYPE);            
        }
    }
    public class VehicleRequestBody extends RMSRequestBody{
        public VehicleRequestBody(DVD_Query__c queryParam){
            super(queryParam);
            this.assessmentType = CHECK_TYPE_ASSESSMENT;
            //this.vehicleParameter = new RMSParameters.VehicleParameter(queryParam.Plate_Number__c, queryParam.Plate_Type__c,
            //                                            queryParam.VIN_Number_or_Chassis_Number__c);
        }
    }
    public class AssessmentRequestBody extends RMSRequestBody{
        
        public AssessmentRequestBody(DVD_Query__c queryParam){
            super(queryParam);
            this.assessmentType = CHECK_TYPE_ASSESSMENT;
            this.query = new RMSParameters.AssessmentParameter(queryParam.DVD_Ext_Transaction_ID__c);
        }
    }
}