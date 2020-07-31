/* Batch class to update all taxi licence records present in the system
 * so that the licence class related information is re-populated on them
 */
global class TaxiBatchToUpdateClassInformation implements Database.Batchable<sObject> {
  
  global final String query;
  global final String taxiLicenceRecordTypeDevName = 'Taxi_Licence';
  
  global TaxiBatchToUpdateClassInformation() {
    
    query = 'SELECT Id, Status__c, Licence_Class__c, Record_Type_Dev_Name__c FROM Authorisation__c '+
            'WHERE Record_Type_Dev_Name__c = :taxiLicenceRecordTypeDevName';
  }
  
  //Start method
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }
  
  //Execute method
  global void execute(Database.BatchableContext BC, List<Authorisation__c> scope) {
    
    //dry updating the records as trigger on authorisation helps to 
    //re-populate the licence class details
    Database.update(scope, false);
  }
    
  //Finish method
  global void finish(Database.BatchableContext BC) {
        
  }
}