// Used for validation on the Transfer button that is used on the 
// Console to throw a warning message if a transfer is being 
// initiated on a TX03 License.
// 
//Warning message:
//Transfer for a TX03 license has to be initiated from the corresponding TX03WAT license.

public without sharing class TransferFormController {

    @AuraEnabled
    public static String getAuthorisation(String authId) {
        Authorisation__c tempAuth = [SELECT Status__c, Authorisation_Type__c, Licence_Class__c FROM Authorisation__c
                                     WHERE Id = :authId];
        return JSON.serialize(tempAuth);
    }
    
}