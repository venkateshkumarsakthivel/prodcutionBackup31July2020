trigger UserTrigger on User (after insert, after update) {
   /* 
    if(trigger.isAfter && trigger.isInsert){
        UserTriggerHandler.activateCommunityUserOnContact(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        UserTriggerHandler.deactivateCommunityUserOnContact(trigger.new);
    }
     */
    
    /*if(trigger.isAfter && trigger.isUpdate){
        list<Id> userIds = new List<Id>();
        
        for(User u : trigger.new){
            userIds.add(u.Id);
        }
    	UpdateIsActiveCommunityUser.updateContats(userIds);
    }*/
}