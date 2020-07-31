trigger NetworkMemberTrigger on NetworkMember (before insert,before update, after insert, after update) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
        NetworkMemberTriggerHandler.afterInsert(Trigger.newMap);
    } 
    
}