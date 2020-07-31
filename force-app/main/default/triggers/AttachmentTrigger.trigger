trigger AttachmentTrigger on Attachment(before delete) {

    if(Trigger.isBefore && Trigger.isDelete) {
        
        AttachmentTriggerHandler.beforeDelete(Trigger.oldMap);
    }
}