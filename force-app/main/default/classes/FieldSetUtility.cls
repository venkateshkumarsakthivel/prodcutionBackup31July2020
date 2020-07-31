public class FieldSetUtility {

    public class FieldWrapper{
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String fieldAPIName;
        @AuraEnabled public String fieldType;
        @AuraEnabled public String parentName;
    }
    
    @AuraEnabled
    public static List<FieldWrapper> getFields(String objectName, String fieldSetName){
        List<FieldWrapper> wrapperList = new List<FieldWrapper>(); 
        
        List<Schema.FieldSetMember> fields = getFieldSetMembers(objectName, fieldSetName);
        system.debug(fields);
        for(Schema.FieldSetMember field : fields){
            if(field.getFieldPath().equalsIgnoreCase('name')){
                continue;
            }
            FieldWrapper fWrapper = new FieldWrapper();
            fWrapper.fieldLabel = field.getLabel();
            fWrapper.fieldAPIName = field.getFieldPath();
            System.debug(field.label);
            System.debug(field);
            if(field.getFieldPath().contains('.')){
               //If field is referenced from parent object, get the label of parent object field
               String parentName = '';
               List<String> splittedFields = field.getFieldPath().split('\\.');
                if(splittedFields.size() > 0){
                    parentName = splittedFields[0];
                    parentName = parentName.replace('__r', '__c');//.replace('__r', '').replaceAll('_', ' ');
                    
                    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
                    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
                    
                    if(SObjectTypeObj != null){
                        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
                        if(DescribeSObjectResultObj.fields.getMap() != null &&
                          DescribeSObjectResultObj.fields.getMap().get(parentName) !=null)
                       		 parentName = DescribeSObjectResultObj.fields.getMap().get(parentName).getDescribe().getLabel();
                    }
                        System.debug(parentName);
                } 
               fWrapper.parentName = parentName;
            }
            fWrapper.fieldType = String.valueOf(field.getType());
            wrapperList.add(fWrapper);
        }
        
        System.debug(wrapperList);
        
       return wrapperList; 
        	
    }
    
    public static List<Schema.FieldSetMember> getFieldSetMembers(String relatedObjectName, String fieldSetName){
        
       Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(relatedObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe(); 
        
       return DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName).getFields();
    }
    
    public static String getFieldstoQuery(String objectName, String fieldSetName){
         String query = 'SELECT '; 
        
            for(Schema.FieldSetMember f : getFieldSetMembers(objectName, fieldSetName)) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM '+objectName;
        
            return query;
    }
}