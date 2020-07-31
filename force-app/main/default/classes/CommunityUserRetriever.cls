public without sharing class CommunityUserRetriever {
    
    public static Boolean isExistingCommunityUser(String contactId){
        List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId];
        return !users.isEmpty();
    }
}