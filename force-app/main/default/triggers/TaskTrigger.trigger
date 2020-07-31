/*************************************************************************
 * Author:         Abhi Indulkar
 * Company:        Transport for NSW
 * Description:    New Trigger Framework for Task
 
 * History
 * <Date>      <Authors Name>      <Brief Description of Change>
 * 25/07/2018  Abhi Indulkar       Created
 *************************************************************************/
trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
    new TaskTriggerHandler().run();
}

/*
trigger TaskTrigger on Task (after insert) {
    
    if(Trigger.isinsert){
        TaskTriggerHandler.afterInsert(Trigger.New);
    }
}
*/