public class ParserUtilities {
	
    public static Map<String, Object> parseJsonString(String jsonContent){
       return ((Map<String, Object>)JSON.deserializeUntyped(jsonContent));
    }
    
    public static Map<String, Object> parseJsonObject(Object jsonContent){
       return ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonContent)));
    }
    
    //Converts object to string
    public static String convertToString(Object field){ 
        return String.valueOf(field);
    }
    
    public static Date parseDate(Object field){
       return (Date.valueOf(convertToString(field)));
    }
    
    public static DateTime parseDateTime(Object field){
       return (DateTime.valueOf(convertToString(field)));
    }
    
    public static Decimal parseDecimal(Object field){
        if(field == null || field == '')
            return 0;
        
        return (Decimal.valueOf(convertToString(field)));
    }
}