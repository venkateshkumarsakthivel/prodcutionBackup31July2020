public class TypeCastUtility {

    
    public static Object typeCastField(Object fieldValue, String fieldType){
        
        switch on fieldType{
            when 'DATE' {
                return toDate(fieldValue);
            } 

            when 'DATETIME' {
                return toDateTime(fieldValue);
            }
            
            when 'CURRENCY' {
                return toDecimal(fieldValue);
            }
        }
            
        return fieldValue;
    }

    public static Object toDate(Object fieldValue){
        return  ParserUtilities.parseDate(fieldValue);
    }

    public static Object toDateTime(Object fieldValue){
        return ParserUtilities.parseDateTime(fieldValue);
    }
    
    public static Object toDecimal(Object fieldValue){
		return ParserUtilities.parseDecimal(fieldValue);
    }

}