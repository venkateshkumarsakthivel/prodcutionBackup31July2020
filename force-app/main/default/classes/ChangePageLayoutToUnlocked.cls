public without sharing class ChangePageLayoutToUnlocked {
     //Method to update recordtype to unlocked
    @InvocableMethod
    public static void ChangeTypeToUnlocked(List<Id> authIds) {
        List<Authorisation__c> authsToUpdate = new List<Authorisation__c>();
        Id rtIdforUnlocked = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_RECORDTYPE_UNLOCKED).getRecordTypeId();
        for(Authorisation__c authRec : [Select Id FROM Authorisation__c WHERE Id IN : authIds]){
            authRec.RecordTypeId = rtIdforUnlocked;
            authsToUpdate.add(authRec);
        }
        update authsToUpdate;
    }
}