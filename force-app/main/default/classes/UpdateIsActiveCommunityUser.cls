public class UpdateIsActiveCommunityUser {
	
    //update the contact if it is unabled for community 
	//@InvocableMethod
    public static void updateAssociatedContact(List<Id> userIds){
    	    UpdateIsActiveCommunityUser.updateContats(userIds);
    }

    @future
    public static void updateContats(List<Id> userIds){
    	List<User> userList = [SELECT Id, IsActive, Name, ContactId FROM User Where Id IN :userIds AND ContactId != NULL];
    	Map<Id,Contact> idContcatMap = new Map<Id, Contact>();
        List<Contact> contacts = new List<Contact>();
      	List<Id> conIds = new List<Id>(); 
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (User u : userList){
            conIds.add(u.ContactId);
        }
        
        contacts = [SELECT Id, IsActiveCommunityUser__c
                    FROM Contact
                    WHERE Id IN : conIds];
        //map one contact vs one community user
        for(User u : userList ){
            for(Contact con: contacts){
                if(con.Id == u.ContactId){
                    idContcatMap.put(u.Id, con);
                    break;
                }
            }
        }
        
        
        for (User u : userList){
            Contact con = new Contact();
            con = idContcatMap.get(u.Id);
            if(u.IsActive == FALSE){
                con.IsActiveCommunityUser__c = FALSE;
            }else{
                con.IsActiveCommunityUser__c = TRUE;
            }
            contactsToUpdate.add(con);
        }
        
        update contactsToUpdate; 
    }
}