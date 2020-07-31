trigger NoticeRecordTrigger on Notice_Record__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
    
        NoticeRecordTriggerHandler.beforeInsert(Trigger.new);
        
    } else if(Trigger.isBefore && Trigger.isUpdate){
    
        NoticeRecordTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
    
    }
}