trigger OrderTrigger on Order(before insert,before update, after update) {

 if(Trigger.isBefore && Trigger.isInsert)
	 OrderTriggerHandler.beforeInsert(Trigger.new);
    
 if(Trigger.isBefore && Trigger.isUpdate)
   OrderTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
   
 if(Trigger.isAfter && Trigger.isUpdate)
   OrderTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
}