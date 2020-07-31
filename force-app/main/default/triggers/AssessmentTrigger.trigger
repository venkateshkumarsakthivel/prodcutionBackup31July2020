trigger AssessmentTrigger on Assessment__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert)
     AssessmentTriggerHandler.beforeInsert(Trigger.new);
   
    if(Trigger.isBefore && Trigger.isUpdate)
     AssessmentTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
}