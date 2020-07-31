public with sharing class GrantedASPAuthorisations {
    @AuraEnabled
    public static List<Authorisation__c> getAuthorisations(String caseRecordId) {
        
        Case currentCase = [Select Id,AccountId from Case WHERE Id =: caseRecordId];
        List<Authorisation__c> auths = [SELECT Id, Name, Authorisation_Type__c, Start_Date__c, End_Date__c FROM Authorisation__c
                                        WHERE Service_Provider__c =:currentCase.AccountId  
                                        AND (Status__c IN: GlobalConstants.AUTHORISATION_STATUS) AND 
                                        (Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_TSP OR Authorisation_Type__c =: GlobalConstants.AUTHORISATION_TYPE_BSP)];
        
        return auths;
    }
}