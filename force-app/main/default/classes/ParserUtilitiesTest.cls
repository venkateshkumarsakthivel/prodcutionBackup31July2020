@IsTest
public class ParserUtilitiesTest {

    @IsTest
    public static void checkforString(){
        Object num = 100;
        Object flag = true;
        Test.startTest();
        	String numToString = ParserUtilities.convertToString(num);
        	String booleanToString = ParserUtilities.convertToString(flag);
        Test.stopTest();
        
        System.assertEquals(numToString, '100');
        System.assertEquals(booleanToString, 'true');
    }
    
    @IsTest
    public static void checkDateParser(){
        Date currentdate = System.today();
        
        Test.startTest();
        	String dateString = ParserUtilities.convertToString(currentDate);
            Date parsedDate = ParserUtilities.parseDate(dateString);
        Test.stopTest();
        
        System.assertEquals(currentDate, parsedDate);
    }
    
    @IsTest
    public static void checkDateTimeParser(){
        DateTime currentdatetime = System.now();
        
        Test.startTest();
        	String datetimeString = ParserUtilities.convertToString(currentdatetime);
            DateTime parsedDate = ParserUtilities.parseDateTime(datetimeString);
        Test.stopTest();
        
    }
    
    @IsTest
    public static void checkDecimalParser(){
        String str = '0';  
        Double fl = 0.0;
        String blank = '';
        Test.startTest();
        	Decimal num = ParserUtilities.parseDecimal(str);
            Decimal num2 = ParserUtilities.parseDecimal(fl);
            Decimal num3 = ParserUtilities.parseDecimal(blank);
        Test.stopTest();
        
        System.assertEquals(num, 0);
        System.assertEquals(num2, 0);
        System.assertEquals(num3, 0);
    }
    
    @IsTest
    public static void parseJSON(){
        String jsonString = '{"name":"Geetesh", "age":31, "city":"New York"}';
        Test.startTest();
          Map<String, Object> jsonObject = ParserUtilities.parseJsonString(jsonString);
          Map<String, Object> parsedJson = ParserUtilities.parseJsonObject(jsonObject);
        Test.stopTest();
        
        System.assertEquals(jsonObject.get('name'), 'Geetesh');
        System.assertEquals(parsedJson, jsonObject);
    }
}