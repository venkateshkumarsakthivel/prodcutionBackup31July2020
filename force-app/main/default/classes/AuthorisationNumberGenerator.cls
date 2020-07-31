public with sharing class AuthorisationNumberGenerator {
    
    public void generate(List<Authorisation__c> auths){
        System.debug(LoggingLevel.INFO, 'Generating auto-numbers for authorisation');
        Set<Id> serviceProviders = new Set<Id>();
        for(Authorisation__c auth : auths){
            serviceProviders.add(auth.Service_Provider__c);
        }
                
        //identify authorisations qualified for new number generation       
        Map<Id, String> accountVsExistingTsp = new Map<Id, String>();
        Map<Id, String> accountVsExistingBsp = new Map<Id, String>();
        List<Authorisation__c> existingAuths = [SELECT Id, Service_Provider__c, Name, 
                                                    Authorisation_Type__c 
                                                FROM Authorisation__c 
                                                WHERE Service_Provider__c IN :serviceProviders];
        
        for(Authorisation__c auth: existingAuths){          
            if(auth.Authorisation_Type__c == 'TSP'){
                System.debug(LoggingLevel.INFO, 'existing TSP authorisation for ' + auth.Service_Provider__c);
                //if authorisation type is tsp, populate tsp map. Use the existing TSP number
                accountVsExistingTsp.put(auth.Service_Provider__c, auth.Name);                
            } else if(auth.Authorisation_Type__c == 'BSP'){
                System.debug(LoggingLevel.INFO, 'existing BSP authorisation for ' + auth.Service_Provider__c);
                //if authorisation type is bsp, populate bsp map. Use the existing BSP number
                accountVsExistingBsp.put(auth.Service_Provider__c, auth.Name);
            }
        }
        
        
        for(Authorisation__c auth : auths){
            if(auth.Authorisation_Type__c == 'TSP'){
                if(accountVsExistingTsp.containsKey(auth.Service_Provider__c)){
                    System.debug(LoggingLevel.INFO, 'Assign existing TSP number ' + accountVsExistingTsp.get(auth.Service_Provider__c) );
                    //assign existing authorisation number
                    auth.Name = accountVsExistingTsp.get(auth.Service_Provider__c);
                    auth.Auto_Generate_Number__c = false;
                } else {
                    System.debug(LoggingLevel.INFO, 'Generating new auto-number for TSP');
                    //generate new authorisation number
                    auth.Auto_Generate_Number__c = true;
                }
            } else if(auth.Authorisation_Type__c == 'BSP'){
                if(accountVsExistingBsp.containsKey(auth.Service_Provider__c)){
                    System.debug(LoggingLevel.INFO, 'Assign existing TSP number ' + accountVsExistingBsp.get(auth.Service_Provider__c) );
                    //assign existing authorisation number
                    auth.Name = accountVsExistingBsp.get(auth.Service_Provider__c);
                    auth.Auto_Generate_Number__c = false;
                } else {
                    System.debug(LoggingLevel.INFO, 'Generating new auto-number for BSP');
                    //generate new authorisation number
                    auth.Auto_Generate_Number__c = true;
                }
            } else if(String.isBlank(auth.Variation_Auth_Id__c) && !auth.Is_Renewal_Licence__c && !auth.Is_Transferred_Authorisation__c){
                System.debug(LoggingLevel.INFO, 'Generating new auto-number for taxi licence');
                //for new taxi licence, generate the auto number
                auth.Auto_Generate_Number__c = true;
            }
        }
    }   
}