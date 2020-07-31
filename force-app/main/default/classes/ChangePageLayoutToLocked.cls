/*
* Invocable class for Change The Page Layout Of Authorisation.
*/
public without sharing class ChangePageLayoutToLocked {
    
    //Method to update recordtype to locked
    @InvocableMethod
    public static void ChangeTypeToLocked(List<Id> authIds) {
        List<Authorisation__c> authsToUpdate = new List<Authorisation__c>();
        Id rtIdforLocked = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_RECORDTYPE_LOCKED).getRecordTypeId();
        for(Authorisation__c authRec : [Select Id FROM Authorisation__c WHERE Id IN : authIds]){
            authRec.RecordTypeId = rtIdforLocked;
            authsToUpdate.add(authRec);
        }
        update authsToUpdate;
    }
}