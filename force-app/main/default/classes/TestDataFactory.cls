/*************************************************************************
 * Author:         Abhi Indulkar
 * Company:        Transport for NSW
 * Description:    Test Data factory
 
 * History
 * <Date>      <Authors Name>      <Brief Description of Change>
 * 27/07/2018  Abhi Indulkar       Created
 *************************************************************************/
@isTest
public class TestDataFactory {

    //static variables
    private static Map<String, Schema.SObjectType> gd;
    private static Schema.DescribeSObjectResult dsr;

    /**
     * createSObjects Create a new rows for a sObject with required field prefilled, values can be passed to non required field or to orverwrite
     * @param  sObjectAPIName  API Name of the sObject 
     * @param  numberOfRecords number records to be created
     * @param  values          Map of the Field API name as key and object as value, Nullable
     * @return                 return a list of row
     */
    public static List<sObject> createSObjects(String sObjectAPIName, Integer numberOfRecords, map<String, object> values, set<String> ignoreFieldName)
    {
        List<sObject> objs = new List<sObject> ();

        for (Integer i = 0; i<numberOfRecords; i++)
        {
            sObject obj = createSObject(sObjectAPIName, values);
            objs.add(obj);
            System.debug(obj);
        }

        return objs;
    }


    public static sObject createSObject(String sObjectAPIName)
    {
        return createSObject(sObjectAPIName, null, null);
    }

    public static sObject createSObject(String sObjectAPIName, map<String, object> values)
    {
        return createSObject(sObjectAPIName, values, null);
    }

    /**
     * createSObject Create a new row for a sObject with required field prefilled, values can be passed to non required field or to orverwrite 
     * @param  sObjectAPIName API Name of the sObject 
     * @param  values         Map of the Field API name as key and object as value, Nullable
     * @return                return a row of the sObject
     */
    public static sObject createSObject(String sObjectAPIName, map<String, object> values, set<String> ignoreFieldName)
    {
        if (gd == null) {
            gd = Schema.getGlobalDescribe();
            //dsr = gd.get(sObjectAPIName).getDescribe();
        }
        dsr = gd.get(sObjectAPIName).getDescribe();
        Map<String, Schema.SObjectField> sObjectFieldMap = dsr.fields.getMap();

        sObject obj = Schema.getGlobalDescribe().get(sObjectAPIName).newSObject();

        for (String fieldName : sObjectFieldMap.keySet()) {
            Schema.DescribeFieldResult field = sObjectFieldMap.get(fieldName).getDescribe();

            if ((ignoreFieldName == null ||
            (ignoreFieldName != null && !ignoreFieldName.contains(field.getName()))) &&
            ((values != NULL && !values.containsKey(field.getName())) || values == NULL) &&
            (!field.isNillable() || field.isNameField()) &&
                !field.isDefaultedOnCreate() && field.isCreateable() && !field.isAutoNumber() && !field.isCalculated())
            {
                if (!(sObjectAPIName == 'Account' && (field.getName() == 'FirstName' || field.getName() == 'LastName')))
                {

                    //System.debug(String.format('{0}:{1}', new list<String>{field.getName(), String.valueOf(field.getType())}));

                    Object defaultValue = getDefaultValueForField(field);
                    System.debug('@field.getName(): ' + field.getName());

                    if (defaultValue != null)
                    {
                        System.debug(field.getName());
                        System.debug(defaultValue);
                        obj.put(field.getName(), defaultValue);
                    }
                }
            }
        }

        for (String key : values.keySet())
        {
            obj.put(key, values.get(key));
        }

        return obj;
    }

    /**
     * getDefaultValueForField return a default value for the type of the field passed
     * @param  field Schema.DescribeFieldResult of the field
     * @return       return default value for the field
     */
    private static Object getDefaultValueForField(Schema.DescribeFieldResult field)
    {
        Object defaultValue;

        if (String.valueOf(field.getType()).toUpperCase() == 'STRING')
        {
            defaultValue = generateString(8);
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'DATE')
        {
            defaultValue = System.today();
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'DATETIME')
        {
            defaultValue = System.NOW();
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'INTEGER')
        {
            defaultValue = 1;
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'DOUBLE')
        {
            defaultValue = 1.0;
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'PICKLIST')
        {
            defaultValue = getPicklistValue(field);
        }
        else if (String.valueOf(field.getType()).toUpperCase() == 'REFERENCE')
        {
            throw new RecordCreatorException('Required ' + field.getType() + ' must be passed as parameter. Field: ' + field.getName());
        }

        return defaultValue;

    }


    /**
     * getDefaultRecordTypeId get the default record type of the sObject 
     * @param  dsr sObject Schema.DescribeSObjectResult
     * @return     return id of default record type of the sObject
     */
    private static id getDefaultRecordTypeId(Schema.DescribeSObjectResult dsr)
    {
        Schema.RecordTypeInfo defaultRecordType;
        for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if (rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
                break;
            }
        }
        return defaultRecordType.getRecordTypeId();

    }

    /**
     * getPicklistValue get the default value of a picklist if there is one, if not get the last value from the list
     * @param  picklistEntry Schema.DescribeFieldResult for a picklist field
     * @return               return default value if there is one, if not will return the last value from the list
     */
    private static String getPicklistValue(Schema.DescribeFieldResult picklistEntry)
    {
        String selection = '';
        //Return the default value if there is one, if not will return the last value from the list
        for (Schema.PicklistEntry f : picklistEntry.getPicklistValues())
        {
            if (f.isDefaultValue())
            {
                selection = f.getValue();
                break;
            }
            selection = f.getValue();
        }

        return selection;
    }

    /**
     * generateString Return a random string of a specified length
     * @param  len length of the string
     * @return     return random string
     */
    private static String generateString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() <len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public class RecordCreatorException extends Exception { }
}