/*
 * Helper class to detect if licence is valid for renewal or not
 */
public with sharing class LicenceRenewalValidator {

    private Map<Id, Authorisation__c> newApplications;
    private Map<Id, Authorisation__c> oldApplications;
    
    
    public LicenceRenewalValidator(Map<Id, Authorisation__c> newApplications, Map<Id, Authorisation__c> oldApplications){
    
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    /*
      Method to validate if licences are valid for renewal
      using Taxi Class custom metadata 
    */
    public void validateRenewal() {
     
      //map to store licence class config with licence class a its key
      Map<String, Taxi_Class__mdt> taxiClassConfig = new Map<String, Taxi_Class__mdt>();
      
     
      for(Taxi_Class__mdt tempTaxiClassConfig : [SELECT Description__c, Is_Legacy_Only__c,
                                                  Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                                  Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                                  Renew_Months__c
                                                  FROM Taxi_Class__mdt]) {
         
          taxiClassConfig.put(tempTaxiClassConfig.Licence_Class__c, tempTaxiClassConfig );                                       
      }
      
      for(Authorisation__c tempAuth : newApplications.values()) {
        
        //check if related licence class configuration is present in the system 
        if(tempAuth.Record_Type_Dev_Name__c == GlobalConstants.TAXI_LICENCE_AUTHORISATION_DEV_NAME
            && tempAuth.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS
            && tempAuth.End_Date__c != NULL
            && taxiClassConfig.containsKey(tempAuth.Licence_Class__c)) {
            
            //check if available to renewal
            if(taxiClassConfig.get(tempAuth.Licence_Class__c).Is_Renewable__c == GlobalConstants.YES_VALUE) {
              
              //validate if licence is within renewal range, if max years is zero then renewal duration has no upper limit
              if(taxiClassConfig.get(tempAuth.Licence_Class__c).Max_Years__c == 0
                  || (tempAuth.End_Date__c.addMonths(Integer.valueOf(taxiClassConfig.get(tempAuth.Licence_Class__c).Renew_Months__c))
                       <= tempAuth.Start_Date__c.addMonths(Integer.valueOf(taxiClassConfig.get(tempAuth.Licence_Class__c).Max_Years__c*12)))
                ) {
                
                //licences can be renewed only x days before its end date
                if(System.Today() < tempAuth.End_Date__c.addDays(-28)) {
                
                 //setting up the flag as true for renewal eligibility
                 tempAuth.Eligible_For_Renewal__c = FALSE;
                }
                else {
                
                 //setting up the flag as true for renewal eligibility
                 tempAuth.Eligible_For_Renewal__c = TRUE;
                }
              }
              else {
               
                //setting up the flag as false for renewal eligibility
                tempAuth.Eligible_For_Renewal__c = FALSE;
              }
            }
            else {
            
              //setting up the flag as false for renewal eligibility
              tempAuth.Eligible_For_Renewal__c = FALSE;
            }
        }
        else {
          
          //setting up the flag as false for renewal eligibility
          tempAuth.Eligible_For_Renewal__c = FALSE;
        }
      }
    }
}