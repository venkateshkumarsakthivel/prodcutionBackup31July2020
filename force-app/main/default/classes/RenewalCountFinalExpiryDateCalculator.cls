/*
 * Helper class to calculate renewal count and final expiry date 
 * for taxi licences
 */
public with sharing class RenewalCountFinalExpiryDateCalculator {
 
    public void calculateRenwalCountFinalExpiryDate(List<Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisationsMap) {
       
       List<Authorisation__c> targetAuthorisationsForCalculation = new List<Authorisation__c>();
       
       for(Authorisation__c tempAuth : newAuthorisations) {
       
        if((oldAuthorisationsMap == NULL && String.isNotBlank(tempAuth.Licence_Class__c) 
            && tempAuth.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME)
           || (oldAuthorisationsMap != NULL && String.isNotBlank(tempAuth.Licence_Class__c) 
                && tempAuth.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME))
            targetAuthorisationsForCalculation.add(tempAuth);
       }
       
       if(targetAuthorisationsForCalculation.size() > 0)
        renewalCountFinalExpiryDateCalculatorHelper(targetAuthorisationsForCalculation);
    } 
    
    public static void renewalCountFinalExpiryDateCalculatorHelper(List<Authorisation__c> targetAuthorisations) {
      
      Map<String, Taxi_Class__mdt> taxiClassConfigMap = new Map<String, Taxi_Class__mdt>();
      
      List<Taxi_Class__mdt> taxiClassConfig = [SELECT MasterLabel, Is_Renewable__c, Licence_Class__c, Max_Years__c
                                               FROM Taxi_Class__mdt];
      
      //creating a map of taxi class configuration                                 
      for(Taxi_Class__mdt tempTaxiClassConfig : taxiClassConfig)
         taxiClassConfigMap.put(tempTaxiClassConfig.Licence_Class__c, tempTaxiClassConfig);                                   
      
      //iterating over the list of target authorisations and calculating
      //Renewal Count and Final Expiry Date
      for(Authorisation__c tempAuth : targetAuthorisations) {
        
        if(taxiClassConfigMap.containsKey(tempAuth.Licence_Class__c)) {
          
          Taxi_Class__mdt tempTaxiClassConfig = taxiClassConfigMap.get(tempAuth.Licence_Class__c);
           
          //calculating Final Expiry date if licence class has final expiry duration configured 
          if(tempTaxiClassConfig.Max_Years__c != 0 && tempAuth.First_Issued_Date__c != NULL && tempAuth.End_Date__c != NULL) {
             
             tempAuth.Final_Expiry_Date__c = Date.newInstance(tempAuth.First_Issued_Date__c.addYears(Integer.valueOf(tempTaxiClassConfig.Max_Years__c)).year(), tempAuth.First_Issued_Date__c.Month(), tempAuth.First_Issued_Date__c.Day()).addDays(-1);
             
             //calculating Renewal Count if licence class is eligible for renewal
             if(tempTaxiClassConfig.Is_Renewable__c == GlobalConstants.YES_VALUE)
              tempAuth.Renewal_Count_Remaining__c = tempAuth.Final_Expiry_Date__c.Year() - tempAuth.End_Date__c.Year();
             else
              tempAuth.Renewal_Count_Remaining__c = NULL;
          }
          else if(tempTaxiClassConfig.Is_Renewable__c == GlobalConstants.YES_VALUE) {
              
              tempAuth.Renewal_Count_Remaining__c = 0;
              tempAuth.Final_Expiry_Date__c = tempAuth.End_Date__c;  
          }
          else {
           
           tempAuth.Renewal_Count_Remaining__c = NULL;
           tempAuth.Final_Expiry_Date__c = NULL;
          }
        }
      }  
    }
}