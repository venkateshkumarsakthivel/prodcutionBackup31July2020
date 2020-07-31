public with sharing class ReturnAuthorisationController {
    
  @AuraEnabled
  public static String returnAuthorisation(String authId) { 
   
   try {
   
    Authorisation__c tempAuth = new Authorisation__c();
    tempAuth.Id = authId;
    tempAuth.Voluntary_Surrender_Requested__c = True;
    //tempAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_CANCELLED;
    //tempAuth.Decision_Date__c = System.Today();
   
    update tempAuth;
    
    return 'SUCCESS';
   }
   catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ReturnAuthorisationController','returnAuthorisation',ex.getMessage(),ex);
            return 'ERROR';            
        }
  }
  
  /*Function that validates if authorisation record should be allowed
      for variation or not.
  */
  @AuraEnabled
  public static String validateAuthorisationRecord(String authId) { 
   
        try{
            
            Authorisation__c tempAuth = [SELECT Status__c FROM Authorisation__c
                                         WHERE Id = :authId];
            
            if(tempAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY 
                || tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS 
                || tempAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY
                || tempAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED)
                return 'SUCCESS';
            
            
            return 'ERROR'; 
        }  catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationController','validateAuthorisationRecord',ex.getMessage(),ex);
            return null;
        }
   }
}