trigger CaseTrigger on Case (after insert, after update, before update, before insert) {

    if(Trigger.isUpdate && Trigger.isAfter) {
        CaseTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
    } else if(Trigger.isUpdate && Trigger.isBefore){
        CaseTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    } else if(Trigger.isInsert && Trigger.isAfter) {
        CaseTriggerHandler.afterInsert(Trigger.newMap);
    }
      else if(Trigger.isInsert && Trigger.isBefore) {
         CaseTriggerHandler.beforeInsert(Trigger.new);
    }
    
}