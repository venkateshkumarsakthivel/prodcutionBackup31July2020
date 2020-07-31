trigger AuthorisationTrigger on Authorisation__c(before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate)
        AuthorisationTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    
    if(Trigger.isBefore && Trigger.isInsert)
        AuthorisationTriggerHandler.beforeInsert(Trigger.new);
  
    if(Trigger.isAfter && Trigger.isUpdate)
        AuthorisationTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);    
}