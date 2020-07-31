trigger TaxPayerRegistrationTrigger on Tax_Payer_Registration__c(before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert) {
       
        TaxPayerRegistrationTriggerHandler.beforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
       
        TaxPayerRegistrationTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}