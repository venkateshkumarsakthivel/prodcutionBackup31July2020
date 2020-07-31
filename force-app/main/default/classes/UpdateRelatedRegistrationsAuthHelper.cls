/*
* Helper class to handle authorisation related levy registration udpates and maintainig its versions
*/
public with sharing class UpdateRelatedRegistrationsAuthHelper {
    
    private Map<Id, Authorisation__c> newAuthorisations;
    private Map<Id, Authorisation__c> oldAuthorisations;
    private static Map<Id, Tax_Payer_Registration__c> providerVsRegistration = new Map<Id, Tax_Payer_Registration__c>();
    private boolean TSPrecordcheck = false;
    private boolean BSPrecordcheck = false;
    public UpdateRelatedRegistrationsAuthHelper(Map<Id, Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisations){
        
        this.newAuthorisations = newAuthorisations;
        this.oldAuthorisations = oldAuthorisations;
    }
    
    /*
     *  Method to identify related active registrations and accordingly update them
     *  If existing registration record status is 'Active' and sub status is 'Completed', then clone the existing record to maintain
     *  its older version. If sub status is 'Pending - Revenue NSW' or 'Pending with P2P' the update the existing record itself
     */
    public void processRelatedRegistrations() {
    
      try {
        
        List<Tax_Payer_Registration__c> relatedRegistrationsToValidate = new List<Tax_Payer_Registration__c>();
        List<Tax_Payer_Registration__c> relatedRegistrationsToUpsert = new List<Tax_Payer_Registration__c>();
        
        Map<Id, Authorisation__c> accountIdVsTSPAuth = new Map<Id, Authorisation__c>();
        Map<Id, Authorisation__c> accountIdVsBSPAuth = new Map<Id, Authorisation__c>();
        Set<Id> targetAccounts = new Set<Id>();
          Map<String, Authorisation__c> mapTSPAuth = new Map<String, Authorisation__c>();
          Map<String, Authorisation__c> mapBSPAuth = new Map<String, Authorisation__c>();
            for(Authorisation__c tempAuth : newAuthorisations.values()) {
                if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP)
                mapTSPAuth.put(tempAuth.Name,tempAuth);
                if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP)
                mapBSPAuth.put(tempAuth.Name,tempAuth);
            }
          if(mapTSPAuth.Size() > 0 ) {
          List<Authorisation__c> Tauthlist= [select Id,Name from Authorisation__c WHERE (Status__c='Cancelled' OR Prior_Status__c='Cancelled') AND Name IN: mapTSPAuth.keyset()];
            if(Tauthlist.Size() > 0){
              
             TSPrecordcheck= true; 
          } 
          }
           if(mapBSPAuth.Size() > 0 ) {
          List<Authorisation__c> Bauthlist= [select Id,Name from Authorisation__c WHERE (Status__c='Cancelled' OR Prior_Status__c='Cancelled') AND Name IN: mapBSPAuth.keyset()];
            if(Bauthlist.Size() > 0){
              
            BSPrecordcheck= true; 
          } 
          }
        system.debug(TSPrecordcheck);
        system.debug(BSPrecordcheck);
        for(Authorisation__c tempAuth : newAuthorisations.values()) {
           
           if(hasAuthInfoChanged(tempAuth, oldAuthorisations.get(tempAuth.Id))) {
           
             if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP)
                accountIdVsTSPAuth.put(tempAuth.Service_Provider__c, tempAuth);
             
             if(tempAuth.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP)
                accountIdVsBSPAuth.put(tempAuth.Service_Provider__c, tempAuth);
             
             targetAccounts.add(tempAuth.Service_Provider__c);
           }
         }
         
         Boolean queryReg = false;
         for(Id actId : targetAccounts){
            if(!providerVsRegistration.containsKey(actId)){
                queryReg = true;
            }
         }
         
        if(queryReg){
            //fetching all registration records related to account of target authorisations
            relatedRegistrationsToValidate = [SELECT Status__c, Sub_Status__c, Service_Provider_Name__c, Levy_Contact__c, Revenue_NSW_Status__c, 
                                               RNSWCustomerId__c, Taxi_Service_Provider_Number__c, Booking_Service_Provider_Number__c, Applied_For_Exemption__c  
                                               FROM Tax_Payer_Registration__c
                                               WHERE Service_Provider_Name__c IN :targetAccounts
                                               AND status__c = :GlobalConstants.STATUS_ACTIVE];
            for(Tax_Payer_Registration__c reg: relatedRegistrationsToValidate){
                providerVsRegistration.put(reg.Service_Provider_Name__c, reg);
            }
             
        } else {
            for(Id actId : targetAccounts){
                if(providerVsRegistration.get(actId) != null)
                    relatedRegistrationsToValidate.add(providerVsRegistration.get(actId));
            }
        }
                                          
         for(Tax_Payer_Registration__c tempRegistration : GlobalUtility.validateRegistrationUpdates(relatedRegistrationsToValidate)) {
       
          //if existing registration record and not a clonned older version
          if(!String.isBlank(tempRegistration.Id)) {
            
            //if TSP authorisation is granted or suspended then link it to the updated registration record, else blank out the linkage
            if(accountIdVsTSPAuth.containsKey(tempRegistration.Service_Provider_Name__c)) {
             
             Authorisation__c tempTSPAuth = accountIdVsTSPAuth.get(tempRegistration.Service_Provider_Name__c);
             
             if(tempTSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                || tempTSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                || tempTSPAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) {
               
               //if authorisation's start date or end date has changed, update isUpdate flag on related registration
               if((tempTSPAuth.Start_Date__c != oldAuthorisations.get(tempTSPAuth.Id).Start_Date__c
                   || tempTSPAuth.End_Date__c != oldAuthorisations.get(tempTSPAuth.Id).End_Date__c)
                   && tempTSPAuth.Status__c == oldAuthorisations.get(tempTSPAuth.Id).Status__c
                   && tempRegistration.Taxi_Service_Provider_Number__c == tempTSPAuth.Id) {
                    
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) {
                   
                      tempRegistration.IsAuthorisationUpdate__c = TRUE;
                  system.debug('Sree8' + tempRegistration.IsAuthorisationUpdate__c);
                    tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                    tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
                   }
                  if(oldAuthorisations.get(tempTSPAuth.Id).first_issued_date__c == null && tempTSPAuth.first_issued_date__c!=null)     
                     tempTSPAuth.FirstIssueDateCheck__c= true;
                  else
                     tempTSPAuth.FirstIssueDateCheck__c= false;                        
                }
                    
                 //if authorisation's start date or end date has changed, update isUpdate flag on related registration if Status updated from Cancelled to Granted - Rajni
           if((tempTSPAuth.Start_Date__c != oldAuthorisations.get(tempTSPAuth.Id).Start_Date__c
                   || tempTSPAuth.End_Date__c != oldAuthorisations.get(tempTSPAuth.Id).End_Date__c)
                   && oldAuthorisations.get(tempTSPAuth.Id).Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED && (tempTSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || tempTSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                   && tempRegistration.Taxi_Service_Provider_Number__c == tempTSPAuth.Id) {
                       
                                      
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) {
                   
                    tempRegistration.IsAuthorisationUpdate__c = TRUE;
                    tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING; 
                    tempRegistration.Sub_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? tempRegistration.Sub_Status__c : GlobalConstants.SUB_STATUS_PENDING_RNSW;
                   }
                    if(oldAuthorisations.get(tempTSPAuth.Id).first_issued_date__c == null && tempTSPAuth.first_issued_date__c!=null)     
                     tempTSPAuth.FirstIssueDateCheck__c= true;
                  else
                     tempTSPAuth.FirstIssueDateCheck__c= false;                                           
                }  
                    
               if(oldAuthorisations.get(tempTSPAuth.Id).Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED && 
                      (tempTSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || tempTSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                   )
                 tempTSPAuth.Decision_Date__c = null;
                  tempTSPAuth.Decision_Reason__c = null;
                   tempTSPAuth.Decision_Made_By__c = null;
                  tempTSPAuth.Voluntary_Surrender_Requested__c  = False;  
                                   
                 
               
               tempRegistration.Taxi_Service_Provider_Number__c = tempTSPAuth.Id;
               
               //if non granted authorisation is granted now and is not a variation one
               if((tempTSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                   || tempTSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                  && tempTSPAuth.Status__c != oldAuthorisations.get(tempTSPAuth.Id).Status__c
                  && tempTSPAuth.Request_Type__c != GlobalConstants.VARIATION_REQUEST_TYPE) {
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                   
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) 
                       // rajni
                        if(oldAuthorisations.get(tempTSPAuth.Id).Status__c != GlobalConstants.AUTHORISATION_STATUS_CANCELLED && TSPrecordcheck==false){
                    tempRegistration.IsTSPAuthorisationCreate__c = TRUE;
                        }
                    
                }
                  
                  
               //if non granted authorisation is granted now and is a variation one
               if((tempTSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                   || tempTSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                  && tempTSPAuth.Status__c != oldAuthorisations.get(tempTSPAuth.Id).Status__c
                  && tempTSPAuth.Request_Type__c == GlobalConstants.VARIATION_REQUEST_TYPE) {
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                    
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) 
                    tempRegistration.IsAuthorisationUpdate__c = TRUE; 
                   system.debug('Sree4' + tempRegistration.IsAuthorisationUpdate__c);                      
                }
                  
              }
                
             //if authorisation is cancelled, update IsAuthorisationCancel flag on related registration
             if(tempTSPAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED) {
             
               tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                
               if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE) 
                tempRegistration.IsAuthorisationCancel__c = TRUE;
            }
               
            }
                      
            //if BSP authorisation is granted or suspended then link it to the updated registration record, else blank out the linkage
            if(accountIdVsBSPAuth.containsKey(tempRegistration.Service_Provider_Name__c)) {
             
             Authorisation__c tempBSPAuth = accountIdVsBSPAuth.get(tempRegistration.Service_Provider_Name__c);
             
             if(tempBSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                || tempBSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
                || tempBSPAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED) {
                
                //if authorisation's start date or end date has changed, update isUpdate flag on related registration
                if((tempBSPAuth.Start_Date__c != oldAuthorisations.get(tempBSPAuth.Id).Start_Date__c
                   || tempBSPAuth.End_Date__c != oldAuthorisations.get(tempBSPAuth.Id).End_Date__c)
                   && tempBSPAuth.Status__c == oldAuthorisations.get(tempBSPAuth.Id).Status__c
                   && tempRegistration.Booking_Service_Provider_Number__c == tempBSPAuth.Id) {
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                   
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE)  
                    tempRegistration.IsAuthorisationUpdate__c = TRUE;
                       
                       system.debug('Sree3' + tempRegistration.IsAuthorisationUpdate__c);
                     if(oldAuthorisations.get(tempBSPAuth.Id).first_issued_date__c == null && tempBSPAuth.first_issued_date__c!=null)     
                     tempBSPAuth.FirstIssueDateCheck__c= true;
                     else
                     tempBSPAuth.FirstIssueDateCheck__c= false;      
                       
                }
                
                    //if authorisation's start date or end date has changed, update isUpdate flag on related registration - Rajni
                if((tempBSPAuth.Start_Date__c != oldAuthorisations.get(tempBSPAuth.Id).Start_Date__c
                   || tempBSPAuth.End_Date__c != oldAuthorisations.get(tempBSPAuth.Id).End_Date__c)
                   &&  oldAuthorisations.get(tempBSPAuth.Id).Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED && (tempBSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || tempBSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY )
                   && tempRegistration.Booking_Service_Provider_Number__c == tempBSPAuth.Id) {
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
             
                       
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE)  
                    tempRegistration.IsAuthorisationUpdate__c = TRUE;
                       
                system.debug('Sree2' + tempRegistration.IsAuthorisationUpdate__c); 
                       
                       if(oldAuthorisations.get(tempBSPAuth.Id).first_issued_date__c == null && tempBSPAuth.first_issued_date__c!=null)     
                     tempBSPAuth.FirstIssueDateCheck__c= true;
                     else
                     tempBSPAuth.FirstIssueDateCheck__c= false;   
                                        
                }
                    
                if(oldAuthorisations.get(tempBSPAuth.Id).Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED && 
                   (tempBSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || tempBSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY )){
                   tempBSPAuth.Decision_Date__c = null;
                   tempBSPAuth.Decision_Reason__c = null;
                   tempBSPAuth.Decision_Made_By__c = null;
                   tempBSPAuth.Voluntary_Surrender_Requested__c  = False;   
                  }
                      
                
                tempRegistration.Booking_Service_Provider_Number__c = tempBSPAuth.Id;
                
                //if non granted authorisation is granted now and is not a variation one
                if((tempBSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                    || tempBSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                   && tempBSPAuth.Status__c != oldAuthorisations.get(tempBSPAuth.Id).Status__c
                   && tempBSPAuth.Request_Type__c != GlobalConstants.VARIATION_REQUEST_TYPE) {
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                   
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE)

                    if(oldAuthorisations.get(tempBSPAuth.Id).Status__c != GlobalConstants.AUTHORISATION_STATUS_CANCELLED && BSPrecordcheck==false){
                    system.debug('BSP Create');
                        tempRegistration.IsBSPAuthorisationCreate__c = TRUE;
                     }
                    
                }
                 
                 
                //if non granted authorisation is granted now and is a variation one
                if((tempBSPAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
                    || tempBSPAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY)
                   && tempBSPAuth.Status__c != oldAuthorisations.get(tempBSPAuth.Id).Status__c
                   && tempBSPAuth.Request_Type__c == GlobalConstants.VARIATION_REQUEST_TYPE){
                   
                   tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
                   
                   if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE)
                    tempRegistration.IsAuthorisationUpdate__c = TRUE; 
                }
               system.debug('Sree' + tempRegistration.IsAuthorisationUpdate__c);  
             }  
             
             //if authorisation is cancelled, update IsAuthorisationCancel flag on related registration
            if(tempBSPAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED){
               
               tempRegistration.Revenue_NSW_Status__c = tempRegistration.Applied_For_Exemption__c == GlobalConstants.YES_VALUE ? GlobalConstants.REVENUE_NSW_STATUS_NA : GlobalConstants.REVENUE_NSW_STATUS_PENDING;
               
               if(String.isBlank(tempRegistration.RNSWCustomerId__c) == FALSE)
                tempRegistration.IsAuthorisationCancel__c = TRUE;
            }
            
            
             
            }
          }
          
          relatedRegistrationsToUpsert.add(tempRegistration);
         }
         
         if(relatedRegistrationsToUpsert.size() > 0)
          Database.Upsert(relatedRegistrationsToUpsert, FALSE);
      }
      catch(Exception e) {
     
       System.debug('Exception: '+e);
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'UpdateRelatedRegistrationsContactHelper', 'processRelatedRegistrations', e.getMessage(), e);
     }
    }
    
    /* 
     * Helper method to identify if either of the required fields on contact have changed or not
     */
    @TestVisible
    private Boolean hasAuthInfoChanged(Authorisation__c newAuth, Authorisation__c oldAuth) {
      
       //if authorisation is granted
       if(newAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || newAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
           && newAuth.Status__c != oldAuth.Status__c)
           return true;
       
       //if authorisation is cancelled
       if(newAuth.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED && newAuth.Status__c != oldAuth.Status__c)
           return true;
       
       //start date and end date changed on active authoriastion (granted/suspended) is changed
       if((newAuth.Status__c == GlobalConstants.GRANTED_CONDITIONALLY 
          || newAuth.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY
          || newAuth.Status__c == GlobalConstants.AUTHORISATION_SUSPENDED)) {
          
       
        //if authorisation's start date has chamged
        if(newAuth.Start_Date__c != oldAuth.Start_Date__c)
           return true;
           
        //if authorisation's end date has chamged
        if(newAuth.End_Date__c != oldAuth.End_Date__c)
           return true;    
       }
           
       return false;
    }
}