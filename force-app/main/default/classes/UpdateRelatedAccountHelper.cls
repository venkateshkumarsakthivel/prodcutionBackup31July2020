/*
* Helper class to update account's ASP category field according to Authorisation Type if authorisation's status is "Granted"
*/

public with sharing class UpdateRelatedAccountHelper {
    
    /*
*  method to update ASP category 
* If Authorisation Type is TSP then ASP category on account should be 1
* If Authorisation Type is BSP and no TSP is present then ASP category on account should be 2
*/
    
    private Map<Id, Authorisation__c> newAuthorisations;
    private Map<Id, Authorisation__c> oldAuthorisations;
    
    public UpdateRelatedAccountHelper(Map<Id, Authorisation__c> newAuthorisations, Map<Id, Authorisation__c> oldAuthorisations){
        
        this.newAuthorisations = newAuthorisations;
        this.oldAuthorisations = oldAuthorisations;
    }
    
    public void updateAccountASPCategory(){
                    
            Map<ID, Account> accountMap = new Map<ID, Account>();
            
            Set<Id> accountsIds = new Set<Id>();
            
            for (Authorisation__c auth : newAuthorisations.values()){
                
                if(auth.Service_Provider__c != null && oldAuthorisations != null && (auth.status__c != oldAuthorisations.get(auth.id).status__c))
                    accountsIds.add(auth.Service_Provider__c);           
            }
            system.debug('accountsIdsSize '+ accountsIds.size());
            system.debug('accountMap '+ accountMap);
            system.debug('accountsIds '+ accountsIds);
        
            if(accountsIds.size() > 0)
            updateAccountASPCategoryHelper(accountMap, accountsIds);
    }
    
    public void updateAccountASPCategoryHelper(Map<ID, Account> accs, Set<Id> accountIds){
        
        try {
            
            accs = new Map<Id, Account>([SELECT Id, ASP_Category__c FROM Account WHERE Id IN :accountIds]);
            
            List<Account> accsToUpdate = new List<Account>();
            
            list<Authorisation__c> auths_TSP = [select id from Authorisation__c where Service_Provider__c IN : accountIds
                                                AND Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TSP
                                                AND (Status__c = :GlobalConstants.GRANTED_CONDITIONALLY OR Status__c = :GlobalConstants.GRANTED_UNCONDITIONALLY OR Status__c = :GlobalConstants.TAXI_LICENCE_GRANTED_STATUS)];
            
            list<Authorisation__c> auths_BSP = [select id from Authorisation__c where Service_Provider__c IN : accountIds
                                                AND Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_BSP
                                                AND (Status__c = :GlobalConstants.GRANTED_CONDITIONALLY OR Status__c = :GlobalConstants.GRANTED_UNCONDITIONALLY OR Status__c = :GlobalConstants.TAXI_LICENCE_GRANTED_STATUS)];
            
            for (Authorisation__c a : newAuthorisations.values()){
                
                if(accs.size() != 0 && oldAuthorisations.get(a.id) != null && (a.status__c != oldAuthorisations.get(a.id).status__c)){
                    system.debug('oldAuthorisations ++ ' + oldAuthorisations.get(a.id));
                    system.debug('newAuthorisations ++ ' + a.id);
                    Account account = accs.get(a.Service_Provider__c);
                    
                    if(a.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_TSP){
                        
                        if(a.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || a.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY || a.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS){
                            if(account.ASP_Category__c != 1){
                                account.ASP_Category__c = 1;
                                accsToUpdate.add(account);
                            } 
                        }else if((a.Status__c != GlobalConstants.GRANTED_CONDITIONALLY || a.Status__c != GlobalConstants.GRANTED_UNCONDITIONALLY || a.Status__c != GlobalConstants.TAXI_LICENCE_GRANTED_STATUS) && auths_TSP.size() == 0 && oldAuthorisations.get(a.id) != null){
                            if(account.ASP_Category__c != 2 || account.ASP_Category__c != null){
                                if(auths_BSP.size() != 0) {
                                    account.ASP_Category__c = 2; 
                                }else{
                                    account.ASP_Category__c = null; 
                                }
                                accsToUpdate.add(account);    
                            }    
                        }
                        
                    }else if(a.Authorisation_Type__c == GlobalConstants.AUTHORISATION_TYPE_BSP && auths_TSP.size() == 0){
                        
                        if(a.Status__c == GlobalConstants.GRANTED_CONDITIONALLY || a.Status__c == GlobalConstants.GRANTED_UNCONDITIONALLY || a.Status__c == GlobalConstants.TAXI_LICENCE_GRANTED_STATUS){
                            if(account.ASP_Category__c != 2){
                                account.ASP_Category__c = 2;
                                accsToUpdate.add(account);
                            }
                            
                        }else if((a.Status__c != GlobalConstants.GRANTED_CONDITIONALLY || a.Status__c != GlobalConstants.GRANTED_UNCONDITIONALLY || a.Status__c != GlobalConstants.TAXI_LICENCE_GRANTED_STATUS) && oldAuthorisations.get(a.id) != null){
                            if(account.ASP_Category__c != 2 || account.ASP_Category__c != null){
                                if(auths_BSP.size() != 0 && auths_TSP.size() == 0){
                                    account.ASP_Category__c = 2; 
                                }else{
                                    account.ASP_Category__c = null; 
                                }
                                accsToUpdate.add(account);
                            }    
                        }
                        
                    }
                }
            }
            system.debug('accsToUpdateSize '+ accsToUpdate.size());
            if(accsToUpdate.size() > 0){
                 
                system.debug('accsToUpdate'+ accsToUpdate);
                Database.update(accsToUpdate, false);
            }
            
        }
        catch(Exception e) {
            
            System.debug('Exception: '+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'UpdateRelatedAccountHelper', 'updateAccountASPCategory', e.getMessage(), e);
        }
    }
}