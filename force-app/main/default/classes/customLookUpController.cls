public class customLookUpController {
    
    @AuraEnabled
    public static List<sObject> fetchAutorisations(String searchKeyWord, String ObjectName, String ObjectId, String aspStatusList, String taxiStatusList) {
		String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();

        String sQuery =  'select id, Name , Authorisation_Type__c, Status__c from ' +ObjectName + ' where Name LIKE: searchKey and Service_Provider__c =:ObjectId';
        List < sObject > lstOfRecords = Database.query(sQuery);        
 
        Object[] aspStatuses = (Object[])System.JSON.deserializeUntyped(aspStatusList);
        Object[] taxiStatuses = (Object[])System.JSON.deserializeUntyped(taxiStatusList);
        
        for (sObject obj: lstOfRecords) {
            Authorisation__c auth = (Authorisation__c)obj;
            if(auth.Authorisation_Type__c == 'BSP' || auth.Authorisation_Type__c == 'TSP'){
                if(aspStatuses.size()>0){         
                    for (Object id : aspStatuses) {
                        if(auth.Status__c == string.valueof(id)){
                            returnList.add(obj);
                        }
                    }
                }
            }else if(auth.Authorisation_Type__c == 'Taxi Licence'){
                if(taxiStatuses.size()>0){         
                    for (Object id : taxiStatuses) {
                        if(auth.Status__c == string.valueof(id)){
                            returnList.add(obj);
                        }
                    }
                }
            }else{
                //
            }  
            
        }
        return returnList;
    }
    
     @AuraEnabled
    public static List<sObject> fetchContacts(String searchKeyWord, String ObjectName, String ObjectId) {
        system.debug('get cons');
        system.debug(ObjectId);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey and AccountId =:ObjectId order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);        
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
     @AuraEnabled
    public static List<sObject> fetchUsers(String searchKeyWord, String ObjectName, String ObjectId) {
        system.debug('get users');
        system.debug(ObjectId);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where UserType = \'Standard\' and name like : searchKey order by createdDate DESC  ';
        System.debug(sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);        
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}