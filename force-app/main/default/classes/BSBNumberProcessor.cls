/**
* Server side rest resource controller for returning Bank Name and Suburb
* for specified BSB number. This configuration is stored in BSB Details custom object.
*/
public with sharing class BSBNumberProcessor {

  //for returning Bank Name and Suburb for specified BSB number
  @AuraEnabled
  public static String getBSBNumberDetails(String bsbNumber) {       
    
    
    List<BSB_Details__c> configuredBSBNumbers = [SELECT Bank__c, Suburb__c
                                                 FROM BSB_Details__c
                                                 WHERE Name = :bsbNumber LIMIT 1];
                                                 
    String result = configuredBSBNumbers.size() > 0 ? configuredBSBNumbers[0].Bank__c+':'+configuredBSBNumbers[0].Suburb__c : NULL;
    
    return result;
  }  
    
}