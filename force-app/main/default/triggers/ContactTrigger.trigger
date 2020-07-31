trigger ContactTrigger on Contact (before update, after update, after insert) {

    if(Trigger.isBefore && Trigger.isUpdate){
        ContactTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        ContactTriggerHandler.afterInsert(Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        ContactTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
}