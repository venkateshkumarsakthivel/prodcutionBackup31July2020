/* 
* Class to update profile of passed in user as per below rules
* If user is on ASP profile, downgrade to Account Manager.
* If user is on DVD profile, deactivate the user.
* If user is on Account manager profile, no change in access.
* If user is on Taxi + ASP profile, downgrade to Taxi + Account Manager
* If user is on Taxi + Account Manager, no change in access.
*/
public without sharing class UserProfileUpdaterController {
    
    public void doProfileUpdate() {
        
        try {
              
            String userId = ApexPages.currentPage().getParameters().get('userId');
            String profileId = ApexPages.currentPage().getParameters().get('profileId');    
            
            if(String.isBlank(userId))
              return;
              
            User loggedInUser = [SELECT Profile.Name, Contact.Is_Access_Level_Levy_Administrator__c FROM User WHERE Id = :userId];
            
            if(profileId == null || profileId == '') {
                
                if(loggedInUser.Profile.Name.equalsIgnoreCase(GlobalConstants.Taxi_ASP_PROFILE_NAME)) {
                    
                    
                    List<Profile> taxiAccountManagerProfile = [SELECT Name FROM Profile WHERE Name = :GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME];
                    loggedInUser.ProfileId = taxiAccountManagerProfile[0].Id;
                    update loggedInUser; 
                }
                else if(loggedInUser.Profile.Name.equalsIgnoreCase(GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME)
                        || loggedInUser.Profile.Name.equalsIgnoreCase(GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME)) {
                            
                            return;
                }
                else if(loggedInUser.Profile.Name.equalsIgnoreCase(GlobalConstants.ASP_PROFILE_NAME)) {
                    
                    List<Profile> accountManagerProfile = [SELECT Name FROM Profile WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME];
                    loggedInUser.ProfileId = accountManagerProfile[0].Id;
                    update loggedInUser;
                }
                else if(loggedInUser.Profile.Name.equalsIgnoreCase(GlobalConstants.DVD_USER)) {
                    
                    loggedInUser.isActive = FALSE;
                    update loggedInUser;
                }
            }
            else {
                loggedInUser.ProfileId = profileId;
                update loggedInUser;
            }
            
        }
        catch(Exception e) {
            
            System.debug('::::user profile not update'+e);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'UserProfileUpdaterController', 'doProfileUpdate', e.getMessage(), e);
        }
    }
}