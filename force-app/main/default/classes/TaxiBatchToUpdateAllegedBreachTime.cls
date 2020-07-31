/* Batch class to update Time Since Alleged Offence when batch execution date is 
 * 90 days from 2 year completion of Date of alleged breach or on 2 year completion of Date of alleged breach 
 */
global class TaxiBatchToUpdateAllegedBreachTime implements Database.Batchable<sObject> {
  
  global final String query;
  public static final String X90_DAYS_BEFORE = '90 Days Before';
  public static final String X2_YEARS_COMPLETED = '2 Years Completed';
  public final String investigationRecordTypeDevName = 'Investigation';
  
  global TaxiBatchToUpdateAllegedBreachTime() {
    
    query = 'SELECT Id, Time_Since_Alleged_Offence__c, Date_of_alleged_breach__c FROM Case '+
            'WHERE Record_Type_Dev_Name__c = :investigationRecordTypeDevName '+
            'AND Date_of_alleged_breach__c != NULL';
  }
  
  //Start method
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }
  
  //Execute method
  global void execute(Database.BatchableContext BC, List<Case> scope) {
    
    List<Case> caseRecordsToUpdate = new List<Case>();
    
    for(Case tempCase : scope) {
      
      if(System.Today().daysBetween(tempCase.Date_of_alleged_breach__c) == -640)
        tempCase.Time_Since_Alleged_Offence__c = X90_DAYS_BEFORE;
        
      if(System.Today().daysBetween(tempCase.Date_of_alleged_breach__c) == -730)
        tempCase.Time_Since_Alleged_Offence__c = X2_YEARS_COMPLETED;
      
      caseRecordsToUpdate.add(tempCase);
    }
    
    Database.update(caseRecordsToUpdate, false);
  }
    
  //Finish method
  global void finish(Database.BatchableContext BC) {
        
  }
}