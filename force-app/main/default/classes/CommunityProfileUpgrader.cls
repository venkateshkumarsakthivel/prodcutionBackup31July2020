/*
 * @Description: Helper class to upgrade community profiles for portal users
 */
public with sharing class CommunityProfileUpgrader{

    private List<User> portalUsers;
    public CommunityProfileUpgrader(List<User> users){
        if(users == null){
            throw new InvalidDataException('Failed to upgrade user profiles. User details missing');
        }
        this.portalUsers = users;
    }
    
    public void upgradeToTaxi(){
        System.debug(LoggingLevel.INFO, 'Users to upgrade ' + portalUsers);
        
        Map<String, String> currentVsNewProfile = new Map<String, String>();
        currentVsNewProfile.put(GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME, GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME);
        currentVsNewProfile.put(GlobalConstants.ASP_PROFILE_NAME, GlobalConstants.Taxi_ASP_PROFILE_NAME);
        currentVsNewProfile.put(GlobalConstants.PSP_PROFILE_NAME, GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME );
        
        Map<String, Id> profileNameVsId = GlobalUtility.getCustomerPortalProfiles();
        List<User> usersToUpdate = new List<User>();
        Map<Id, Id> userVsProfile = new Map<Id, Id>();
        
        for(User u : portalUsers) {
            System.debug(LoggingLevel.INFO, 'Current Profile Assigned to User: ' + u.ProfileId);
            if(u.ProfileId == profileNameVsId.get(GlobalConstants.ASP_PROFILE_NAME)){
                //if ASP user then upgrade profile to Taxi + ASP
                System.debug(LoggingLevel.INFO, 'Profile upgrade to Taxi + ASP for ' + u.Id);
                userVsProfile.put(u.Id, profileNameVsId.get(GlobalConstants.Taxi_ASP_PROFILE_NAME));
                System.debug(LoggingLevel.INFO, 'Updated Profile assigned to User: ' + userVsProfile.get(u.Id));
                
            } else if(u.ProfileId == profileNameVsId.get(GlobalConstants.PSP_PROFILE_NAME)){
                //if PSP user then upgrade profile to Taxi + PSP
                System.debug(LoggingLevel.INFO, 'Profile upgrade to Taxi + PSP for ' + u.Id);
                userVsProfile.put(u.Id, profileNameVsId.get(GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME ));
                System.debug(LoggingLevel.INFO, 'Updated Profile assigned to User: ' + userVsProfile.get(u.Id));
                
            } else if(u.ProfileId == profileNameVsId.get(GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME)){
                //if Account manager user then upgrade profile to Taxi + account manager
                System.debug(LoggingLevel.INFO, 'Profile upgrade to Taxi + Account Manager for ' + u.Id);
                userVsProfile.put(u.Id, profileNameVsId.get(GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME));
                System.debug(LoggingLevel.INFO, 'Updated Profile assigned to User: ' + userVsProfile.get(u.Id));
                
            }
        }
        
        upgradeUserProfile(userVsProfile);
    }
    
     @future
    private static void upgradeUserProfile(Map<Id, Id> userVsProfile) {
        List<User> users = new List<User>();
        for(Id userId : userVsProfile.keySet()){
            users.add(new User(Id = userId, ProfileId = userVsProfile.get(userId)));
        }
        update users;
    }
    
    public class InvalidDataException extends Exception {}
}