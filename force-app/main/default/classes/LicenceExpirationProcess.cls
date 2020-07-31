/*
- Class for Licence Expiration Process invoked by process
- This class creates a case if authorisation dose not have a variation of it.
*/
public class LicenceExpirationProcess {
    @InvocableMethod
    public static void createCase(List<Id> authIds) {
        List<Case> casesToInsert = new List<Case>();
        
        if(!authWithSameNameExist(authIds)){
            Id rtIdforTaxiAdministrator = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            Id queueId = [SELECT Id FROM Group WHERE Type =: GlobalConstants.QUEUE AND DeveloperName =: GlobalConstants.TAXI_LEVEL_1_QUEUE_DEV_NAME ].Id;
            for(Authorisation__c auth : [SELECT Id, Service_Provider__c FROM Authorisation__c WHERE Id IN : authIds]){
                case caseRec = new Case(); 
                caseRec.RecordTypeId = rtIdforTaxiAdministrator;
                caseRec.Subject = GlobalConstants.TAXI_LICENCE_EXPIRATION_CASE_SUBJECT;
                caseRec.type = GlobalConstants.CASE_TAXI_TYPE;
                caseRec.Sub_Type__c = GlobalConstants.EXPIRY_CASE_SUB_TYPE;
                caseRec.Status = GlobalConstants.CASE_NEW;
                caseRec.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
                caseRec.OwnerId = queueId;
                caseRec.Authorisation__c = auth.Id;
                caseRec.AccountId = auth.Service_Provider__c;
                casesToInsert.add(caseRec);
            }
            if(casesToInsert.size() > 0)
                insert casesToInsert;
        }
    }
    
    
    public static boolean authWithSameNameExist(List<Id> authIds) {
        List<Authorisation__c> authsWithSameName = new List<Authorisation__c>();
        for(Authorisation__c authRec : [Select Id FROM Authorisation__c WHERE Variation_Auth_Id__c IN : authIds]){
            authsWithSameName.add(authRec);
            system.debug('authRec: '+authRec);
        }
        
        if(authsWithSameName.size() > 0)
            return true;
        return false;
    }
}