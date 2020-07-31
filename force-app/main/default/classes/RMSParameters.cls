/**
 * Structure Definition for RMS Parameters
 * These will be present both in request & response
 */
public class RMSParameters {

//////////////////////////////////////////////////////////////////////////////////
//Data Structures for Serialization/Deseralization
//////////////////////////////////////////////////////////////////////////////////

    //Structures in body parts
    public class QueryPart{
        public String id;
    }
    
    public class ClassPart{
        // @serializedname('class') -> not supported in apex
        // to access this, the response JSON needs to perform a find/replace on 
        // '"class":' with '"propertyClass":'
        String propertyClass;
    }
    
    public class LicenceParameter{
        private String id;
        private String idType;
        private String surname;
        private String dateOfBirth;  //yyyy-MM-dd
        private String assessmentType;
        public LicenceParameter(String id, String idType, String surname, Date dateOfBirth, String assessmentType){
            this.id = String.isEmpty(id) ? null : id;
            this.idType = String.isEmpty(idType) ? null : idType;
            this.surname = String.isEmpty(surname) ? null : surname;
            this.dateOfBirth = (null == dateOfBirth) ? null : Datetime.newInstance(dateOfBirth.year(), dateOfBirth.month(),dateOfBirth.day()).format('yyyy-MM-dd');
        	this.assessmentType	= assessmentType;
        }
        
    }
    public class VehicleParameter{
        private String plateNumber;
		private String plateType;
		private String chassisOrVIN;
        public VehicleParameter(String plateNumber, String plateType, String chassisOrVIN) {
            this.plateNumber = String.isEmpty(plateNumber) ? null : plateNumber;
            this.plateType = String.isEmpty(plateType) ? null : plateType;
            this.chassisOrVIN = chassisOrVIN;
        }
    }
    public class AssessmentParameter {
		private String id;
        public AssessmentParameter(String id){
            this.id = String.isEmpty(id) ? null : id;
        }
    }
    
    
}