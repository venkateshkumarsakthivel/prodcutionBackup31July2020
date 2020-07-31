/*
Created By : Venkatesh Kumar
Created Date : 15 Nov 2019
Requirement : https://tfnswjira.transport.nsw.gov.au/browse/P2PSUPPORT-275

Reference : Lightning Component : AuthorisationHistory
Test Class: getAuthorisationHistoryDetailsTest
*/

public class getAuthorisationHistoryDetails {

    @AuraEnabled
    public static List<Authorisation__c> getOldAuthorisations(Id authID){
        system.debug('Current Authorisation ID ------>'+authID);
        Authorisation__c Auth = [Select ID,Service_Provider__c,CreatedDate,Name FROM Authorisation__c where ID =: authID Limit 1];
        List<Authorisation__c> listAuth = [Select ID,Service_Provider__c,CreatedDate,Name,Authorisation_Number__c,Status__c,LastModifiedDate from Authorisation__c where CreatedDate <: Auth.CreatedDate and Name =: Auth.Name Order by CreatedDate Desc];
        return listAuth;
    }

    @AuraEnabled
    public static List<Authorisation__History> getAuthHistories(Id authID){
        system.debug('Current Authorisation ID ------>'+authID);
        List<Authorisation__History> listAuthHistories = [SELECT CreatedDate,Field,createdby.Name ,OldValue,NewValue FROM Authorisation__History where ParentId =: authID ];
        return listAuthHistories;
    }
    
}