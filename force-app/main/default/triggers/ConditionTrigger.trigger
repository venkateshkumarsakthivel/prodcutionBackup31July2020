trigger ConditionTrigger on Condition__c (after insert, after delete) {

    if(Trigger.isAfter && Trigger.isInsert){
        ConditionTriggerHandler.afterInsert(Trigger.newMap);
    } else if(Trigger.isAfter && Trigger.isDelete){
        ConditionTriggerHandler.afterDelete(Trigger.oldMap);
    }
    
}