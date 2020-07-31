public without sharing class ChangePageLayoutToDefault {
     //Method to update recordtype to default
    @InvocableMethod
    public static void ChangeTypeTodefault(List<Id> authIds) {
        List<Authorisation__c> authsToUpdate = new List<Authorisation__c>();
        Id rtIdforDefault = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_RECORDTYPE_DEFAULT).getRecordTypeId();
        System.debug('List: '+[Select Id FROM Authorisation__c WHERE Id IN : authIds]);
        for(Authorisation__c authRec : [Select Id FROM Authorisation__c WHERE Id IN : authIds]){
            authRec.RecordTypeId = rtIdforDefault;
            authsToUpdate.add(authRec);
        }
        update authsToUpdate;
    }
}