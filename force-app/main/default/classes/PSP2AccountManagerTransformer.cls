/**
 *  Description: Helper class for upgrading user profile from PSP to Account Manager
 */
public without sharing class PSP2AccountManagerTransformer {
    
    @future
    public static void transform(Set<Id> pspUsersContact) {
    
        //retrieve Account Manager profile
        List<Profile> accountManagerProfile = [SELECT Id 
                                                   FROM Profile 
                                                   WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME];
                                               
                                                                                  
        if(accountManagerProfile.isEmpty())
          return;
    
        System.debug('pspUsersContact Size'+pspUsersContact.size());
        System.debug('pspUsersContact'+pspUsersContact);
    
        List<User> users = [SELECT Id, ProfileId, Name, User_Profile_Name__c, ContactId
                            FROM User WHERE ContactId IN :pspUsersContact];
        
        for(User userRec : users) {
        
          System.debug('++users++'+userRec);
            
          if(userRec.User_Profile_Name__c == GlobalConstants.PSP_PROFILE_NAME)
           userRec.ProfileId = accountManagerProfile[0].Id;

        }
        
        update users;
    }
}