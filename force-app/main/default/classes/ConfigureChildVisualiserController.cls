public class ConfigureChildVisualiserController {

    public class ChildRelationWrapper{
        @AuraEnabled public String childName;
        @AuraEnabled public String relatedField;
        @AuraEnabled public List<String> fieldSets;
    }
    
    public class CustomSettingsParser{
        public String uniqueName;
        public String relatedField;
        public String childObjectName;
        public String columns;
        public String fieldSetName;
        public String parentObjectName;
        public String buttons;
        public String filters;
    }
    
    @AuraEnabled
    public static List<ChildRelationWrapper> getChildRelations(String parentObjectName){
        List<ChildRelationWrapper> wrapperList = new List<ChildRelationWrapper>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(parentObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe(); 
        Schema.DescribeSObjectResult sObjectType = DescribeSObjectResultObj.SObjectType.getDescribe();
        List<Schema.ChildRelationship> relationships = sObjectType.getChildRelationships();
        for(Schema.ChildRelationship relation : relationships){
            ChildRelationWrapper wrapper = new ChildRelationWrapper();
            wrapper.childName = String.valueOf(relation.getChildSObject());
            wrapper.relatedField = String.valueOf(relation.getField());
            wrapper.fieldSets = getFieldSetNames(parentObjectName);
            wrapperList.add(wrapper);
        }

        return wrapperList;
    }
    
    public static List<String> getFieldSetNames(String objectName){
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe(); 
        
            Map<String, Schema.FieldSet> fieldSetsMap = DescribeSObjectResultObj.FieldSets.getMap();
            
            Set<String> keySet = fieldSetsMap.keySet();
            List<String> fieldSets = new List<String>();
            fieldSets.addAll(keySet);
            return fieldSets;        
    }
    
    @AuraEnabled
    public static void saveCustomSettingsRecord(String record, Boolean isUpdate){
        System.debug(LoggingLevel.INFO, record);
        System.debug(LoggingLevel.INFO, 'isUpdate: ' + isUpdate);
        CustomSettingsParser parser = (CustomSettingsParser)JSON.deserialize(record, CustomSettingsParser.class);
        
        if(isUpdate == true){
            System.debug(LoggingLevel.INFO, 'Updating custom setting details');
            updateCustomSettingRecord(parser);
        }
        else{
            saveCustomSettingRecord(parser);
        }
    }
    @TestVisible
    private static void updateCustomSettingRecord(CustomSettingsParser parser){
        
        List<Child_Visualiser_Information__c> alreadyPresentRecord = [SELECT Id
                                                                      FROM Child_Visualiser_Information__c
                                                                      WHERE Unique_Name__c = :parser.uniqueName];
        if(! alreadyPresentRecord.isEmpty()){
            Child_Visualiser_Information__c record = mapCustomSettingValues(parser);
            record.Id = alreadyPresentRecord[0].Id;
            update record;
        }   
    }
    @TestVisible
    private static void saveCustomSettingRecord(CustomSettingsParser parser){
        Child_Visualiser_Information__c newRecord = mapCustomSettingValues(parser);
        insert newRecord;
    }
    
    private static Child_Visualiser_Information__c mapCustomSettingValues(CustomSettingsParser parser){
        Child_Visualiser_Information__c customSetting = new Child_Visualiser_Information__c();
       customSetting.Name = parser.uniqueName.length() > 40? parser.uniqueName.substring(0,40): parser.uniqueName;
        customSetting.Child_Object_Name__c = parser.childObjectName;
        customSetting.Number_of_columns__c = Decimal.valueOf(parser.columns);
        customSetting.Field_Set_Name__c = parser.fieldSetName;
        customSetting.Related_by_Field__c = parser.relatedField;
        customSetting.Unique_Name__c = parser.uniqueName;
        
        if(parser.buttons != null && parser.buttons != ''){
            if(parser.buttons.length() <= 255){
              customSetting.Buttons__c = parser.buttons.substring(0, parser.buttons.length());
            }
            else{
              customSetting.Buttons__c = parser.buttons.substring(0, 255);
              customSetting.Buttons2__c = parser.buttons.substring(255);
              
            }
            System.debug(customSetting.Buttons__c);

        }
        
        customSetting.filters__c = parser.filters;
        return customSetting;
    }
}