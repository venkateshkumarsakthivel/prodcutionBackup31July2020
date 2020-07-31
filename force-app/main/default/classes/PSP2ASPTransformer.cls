/**
*  Description: Helper class for upgrading user profile from PSP to ASP
*/
public without sharing class PSP2ASPTransformer {
    
    @future
    public static void transform(Set<Id> pspUsersContact){
        
        //retrieve ASP profile
        List<Profile> aspProfile = [SELECT Id 
                                    FROM Profile 
                                    WHERE Name = :GlobalConstants.ASP_PROFILE_NAME];
                                    
        //retrieve Taxi and ASP profile
        List<Profile> taxiASPProfile = [SELECT Id 
                                               FROM Profile 
                                               WHERE Name = :GlobalConstants.Taxi_ASP_PROFILE_NAME];
                                               
        if(aspProfile.isEmpty())
          return;
        
        System.debug('pspUsersContact Size'+pspUsersContact.size());
        System.debug('pspUsersContact'+pspUsersContact);
        
        List<User> users = [SELECT Id, ProfileId, Name, User_Profile_Name__c, ContactId
                            FROM User WHERE ContactId IN :pspUsersContact];
        
        
        
        for(User userRec : users) {
            
            System.debug('++users++'+userRec);
            
            if(userRec.User_Profile_Name__c == GlobalConstants.PSP_PROFILE_NAME || userRec.User_Profile_Name__c == GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME)
                userRec.ProfileId = aspProfile[0].Id;
                
               
            if(userRec.User_Profile_Name__c == GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME)
                userRec.ProfileId = taxiASPProfile[0].Id;  
        }
        
        update users;
    }
}