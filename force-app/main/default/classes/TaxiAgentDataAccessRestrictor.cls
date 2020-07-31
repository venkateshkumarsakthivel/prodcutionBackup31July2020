/*
 * Controller class to ensure agents have access to data 
 * which is shared with them via sharing set
 */
public with sharing class TaxiAgentDataAccessRestrictor {
  
   public static List<Authorisation__c> getTaxiAuthorisationRecords(String requiredAccId) {
     
     Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
     Set<String> authStatusValues = new Set<String>();
     authStatusValues.add(GlobalConstants.AUTHORISATION_GRANTED);
     authStatusValues.add(GlobalConstants.AUTHORISATION_SUSPENDED);
     
     List<Authorisation__c> accessibleAuthorisations = GlobalUtility.getAgentAccessibleAuthorisations(requiredAccId);
     
     List<Authorisation__c> authorisationList = [SELECT Id, Application__c, Authorisation_Type__c, Name, Licence_Class__c, Licence_Type__c, Plate_Number__c, Start_Date__c, End_Date__c,
                                                        Status__c, Service_Provider__r.Name, isGranted__c, Authorisation_Name__c,
                                                        Decision_Reason__c, Decision_Made_By__c, 
                                                        Return_Requested__c, Renewal_Requested__c, Eligible_For_Renewal__c, Can_Attempt_Licence_Renewal__c,
                                                        Licence_Fee__c, Payment_Frequency__c, Operation_Area__c,
                                                        Final_Expiry_Date__c, Last_Transferred_Date__c, Renewal_Count_Remaining__c,
                                                        Agreement_Type__c, Agency__c, Agency__r.Name
                                                        FROM Authorisation__c 
                                                        WHERE Id IN :accessibleAuthorisations
                                                        AND Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE  
                                                        AND Status__c IN :authStatusValues  
                                                        AND Service_Provider__c =: requiredAccId
                                                        ORDER BY End_Date__c DESC ];
                                                        
      return authorisationList;
   }
}