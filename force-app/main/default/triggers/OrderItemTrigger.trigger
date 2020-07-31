trigger OrderItemTrigger on OrderItem(after insert,before insert, after update, before update) {
  
  if(Trigger.isBefore && Trigger.isInsert)
   OrderItemTriggerHandler.beforeInsert(Trigger.new);
    
  if(Trigger.isAfter && Trigger.isInsert)
   OrderItemTriggerHandler.afterInsert(Trigger.newMap);
   
  if(Trigger.isAfter && Trigger.isUpdate)
   OrderItemTriggerHandler.afterUpdate(Trigger.newMap);
   
  if(Trigger.isBefore && Trigger.isUpdate)
   OrderItemTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
   
}