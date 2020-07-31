/*
 * Helper class to associate Tax Payer Registration record with TSP and BSP authorisations having status
 * either as Granted with Conditions, Granted Unconditionally or Suspended
*/
public class TSPBSPRegistrationAssociator {

    private List<Tax_Payer_Registration__c> newRegistrations;
    
    public TSPBSPRegistrationAssociator(List<Tax_Payer_Registration__c> newRegistrations){
    
        this.newRegistrations = newRegistrations;
    }
    
    /*
     * Method to check if related service provider account has required type of authorisation,
     * If yes associate it with regisrtation record 
    */
    public void associateRelatedAuthorisations() {
     
     try {
        
        Set<Id> relatedServiceProviders = new Set<Id>();
        
        Map<Id, Authorisation__c> relatedTSPAuthorisations = new Map<Id, Authorisation__c>();
        Map<Id, Authorisation__c> relatedBSPAuthorisations = new Map<Id, Authorisation__c>();
        
        //fetching ids of all related service providers
        for(Tax_Payer_Registration__c tempRegistration : newRegistrations) {
            
            if(String.isNotBlank(tempRegistration.Service_Provider_Name__c))
                relatedServiceProviders.add(tempRegistration.Service_Provider_Name__c);
        }
        
        //fetching all related granted or suspended TSP/BSP authorisations related to target accounts
        //sorting by enda date desc so that recent one is stored in map
        for(Authorisation__c tempAuth : [SELECT Service_Provider__c, Authorisation_Type__c, Status__c
                                            FROM Authorisation__c
                                            WHERE Service_Provider__c IN :relatedServiceProviders
                                            AND (Status__c = :GlobalConstants.GRANTED_UNCONDITIONALLY
                                                 OR Status__c = :GlobalConstants.GRANTED_CONDITIONALLY
                                                 OR Status__c = :GlobalConstants.AUTHORISATION_SUSPENDED)
                                            AND (Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TSP
                                                 OR Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_BSP)
                                            ORDER BY End_Date__c ASC]) {
                                                     
            if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP)                                         
             relatedTSPAuthorisations.put(tempAuth.Service_Provider__c, tempAuth);  
            else if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP)
             relatedBSPAuthorisations.put(tempAuth.Service_Provider__c, tempAuth);                                     
        }
        
        //iterating over list of new registration records
        for(Tax_Payer_Registration__c tempRegistration : newRegistrations) {
         
            //check if they have any qualified TSP authorisations
            if(String.isNotBlank(tempRegistration.Service_Provider_Name__c)
               && relatedTSPAuthorisations.containsKey(tempRegistration.Service_Provider_Name__c))
               tempRegistration.Taxi_Service_Provider_Number__c = relatedTSPAuthorisations.get(tempRegistration.Service_Provider_Name__c).Id;
            
           //check if they have any qualified BSP authorisations
           if(String.isNotBlank(tempRegistration.Service_Provider_Name__c)
               && relatedBSPAuthorisations.containsKey(tempRegistration.Service_Provider_Name__c))
               tempRegistration.Booking_Service_Provider_Number__c = relatedBSPAuthorisations.get(tempRegistration.Service_Provider_Name__c).Id;
        }
        
     }
     catch(Exception e) {
            
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'TSPBSPRegistrationAssociator', 'associateRelatedAuthorisations', e.getMessage(), e);
     }
   }
}