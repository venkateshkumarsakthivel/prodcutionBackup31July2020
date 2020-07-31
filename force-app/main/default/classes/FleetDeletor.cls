/*
  Helper class to delete entity records of passed in ids
  On purpose without sharing to allow external users belonging to same account
  to delete driver/vehicle records irrespective of ownership
*/
public without sharing class FleetDeletor  {

   
  public static Boolean deleteEntities(List<String> ids) {
   
   try {
   
    List<DVD_Entity__c> recordsToDelete = [SELECT Id  FROM DVD_Entity__c WHERE Id in :ids LIMIT 10000];
            
    if(recordsToDelete.size() > 0)
     delete recordsToDelete;
     
    return true;
   }
   catch(Exception e) {
     
    System.debug('Exception: '+e);
    ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'FleetDeletor', 'deleteEntities', e.getMessage(), e);
    return false;
   }  
  } 
}