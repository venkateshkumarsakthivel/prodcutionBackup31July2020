/**
 * Structure Definition for RMS Parameters
 * These will be present both in request & response
 */
public class RMSSDOParameters {

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
    
    
}