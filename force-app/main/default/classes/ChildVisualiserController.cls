public class ChildVisualiserController {

    @AuraEnabled
    public static List<sObject> getRecords(String recordId, String childName,
                                           String fieldSetName, String relatedByField,
                                           String sortBy, String sortOrder, Boolean refreshData){
        
        if(childName == '' || childName == null)
            return null; 
        String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
         
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\'';
       
        if(sortBy != '' && sortBy != null){
             query += ' ORDER BY '+ sortBy + ' '+ sortOrder;                                     
       	}
        
        List<sObject> records = Database.query(query);
        return records;
    }
     @AuraEnabled
    public static boolean getUserInfo(){
        
        Profile PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE.Name;
         Boolean ifAdmin = MyProflieName == 'System Administrator'? True : False;
        system.debug(ifAdmin);
        return ifAdmin;
    }
    
     @AuraEnabled(Cacheable=true)
   public static List<String> picklistValues(String objectName, String fieldName) {
      List<String> values = new List<String>();
      List<String> types = new List<String>{objectName};
      List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
      for(Schema.DescribeSobjectResult result : results) {
         for (Schema.PicklistEntry entry : result.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
            if (entry.isActive()){
                values.add(entry.getValue());
            }
         }
      }
      return values;
   }
    @AuraEnabled
    public static Child_Visualiser_Information__c getCustomSettingInfo(String customSettingName){
        if(customSettingName == '' || customSettingName == null)
            return null;
        
        List<Child_Visualiser_Information__c> customSettings = [SELECT Id, Name, Child_Object_Name__c, Buttons__c,
                                                               	Number_of_Columns__c, Related_by_Field__c, 
                                                                Field_Set_Name__c, filters__c, Buttons2__c
                                                               	FROM Child_Visualiser_Information__c
                                                                WHERE Unique_Name__c = :customSettingName LIMIT 1];
        return customSettings[0];   
    }
       
    @AuraEnabled
    public static String getPluralLabel(String objectName){
        if(objectName == null || objectName == ''){
            return 'Related Object';
        }
        
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe(); 
        
        	return (DescribeSObjectResultObj.getLabelPlural());
    }
     @AuraEnabled(Cacheable=true)
    public static List<sObject> getFilterdRecords(String recordId, String childName,
                                                  String fieldSetName,
                                           String relatedByField,String selectedField, String selectedCondition,
                                           String enteredValue,String selectedFieldType){
            system.debug(selectedFieldType);  
                                             
           List<sObject> records = new  List<sObject>();  
                                               system.debug(records);
         if(selectedFieldType == 'DOUBLE' || selectedFieldType == 'CURRENCY'){
                 Double integerValues = Double.valueof(Enteredvalue.trim());
         if(selectedCondition=='Equals'){         
             String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '=' +integerValues;
            System.debug(query);
             records = Database.query(query);
            }
        else if(selectedCondition=='Not Equals'){
                 String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '!='+integerValues;
             records = Database.query(query);
            }
        else if(selectedCondition=='Greater Than Equals'){
              String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' + selectedField +'>='+integerValues;
            system.debug(query);
             records = Database.query(query);
            
            }
        
        else if(selectedCondition=='Less Than Equals'){
             String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' + selectedField +'<='+integerValues;
             records = Database.query(query);
            }
         }
         else if(selectedFieldType == 'DATE'|| selectedFieldType == 'DATETIME'){
              
              String dateValue;
             if(selectedFieldType == 'DATETIME'){
                dateValue = Enteredvalue + 'T00:00:00Z';
             }
             else{
                 dateValue = Enteredvalue;
             }
             
            system.debug(dateValue);
         if(selectedCondition=='Equals'){         
             String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '=' +dateValue;
            System.debug(query);
             records = Database.query(query);
            }
        else if(selectedCondition=='Not Equals'){
                 String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '!='+dateValue;
             records = Database.query(query);
            }
        else if(selectedCondition=='Greater Than Equals'){
              String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' + selectedField +'>='+dateValue;
            system.debug(query);
             records = Database.query(query);
            
            }
        
        else if(selectedCondition=='Less Than Equals'){
             String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' + selectedField +'<='+dateValue;
             records = Database.query(query);
            }
         }
           else{
               String stringValues = String.valueof(enteredvalue);
         if(selectedCondition=='Equals'){         
             String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '=' +'\''+stringValues+'\'';
            System.debug(query);
             records = Database.query(query);
            }
        else if(selectedCondition=='Not Equals'){
                 String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' +selectedField+ '!=' +'\''+stringValues+'\'';
             records = Database.query(query);
            }
        
        else if(selectedCondition=='Contains'){
            String query = FieldSetUtility.getFieldstoQuery(childName, fieldSetName);
        query+= ' WHERE '+relatedByField+' =\''+recordId+'\''+ ' AND ' + selectedField +' like '+'\'%'+stringValues+'%\'';
             records = Database.query(query);
        }
         }    
          return records;
                 }
          
           }