trigger AccountTrigger on Account(before update, after update) {

    if(Trigger.isBefore && Trigger.isUpdate) {
        
        AccountTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        
       AccountTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}