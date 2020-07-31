/**
* Component Controller to expose Username, whether user logged in etc
*/
public class LoggedInUserController {
    
    @AuraEnabled
    public static String getLoggedInUser() {
    
        User user = [SELECT Id, FirstName, LastName, CommunityNickname, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    
        //if guest user No Auth Session records available
        List<AuthSession> authSessions =  [Select LoginType FROM AuthSession WHERE UsersId = :UserInfo.getUserId()];
        if(0 == authSessions.size()) {
    
            //guest user
            return '{"loggedIn":"false"}';
        }
    
        String nickname = ((user.FirstName != null && user.FirstName.length() > 0) ? user.FirstName : '') + ' ' + user.LastName;
        return '{"loggedIn":"true", "username":"' + nickname + '" , "profile":"' + user.Profile.Name +'"}';
    }
    
    //method to check if logged in user has access to Taxi and ASP(Industry Portal) community as well
    @AuraEnabled
    public static Boolean hasBothCommunityAccess() {
    
        User loggedInUser = [SELECT Id, FirstName, LastName, Profile.Name, Contact.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        System.debug('Profile Name: '+loggedInUser.Profile.Name);
        
        Set<String> aspTaxiAccessProfiles = new Set<String>();
        aspTaxiAccessProfiles.add(GlobalConstants.Taxi_ASP_PROFILE_NAME);
        aspTaxiAccessProfiles.add(GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME);
      
        
        if(aspTaxiAccessProfiles.contains(loggedInUser.Profile.Name))
           return true;
        
        return false;
    }
    
    //method to check if logged in user has access to Levy
    @AuraEnabled
    public static Boolean hasLevyAccess() {
    
        User loggedInUser = [SELECT Id, FirstName, LastName, Profile.Name, Contact.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        System.debug('Profile Name: '+loggedInUser.Profile.Name);
        
        Set<String> levyAccessProfiles = new Set<String>();
        levyAccessProfiles.add(GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME);
        
        if(levyAccessProfiles.contains(loggedInUser.Profile.Name))
           return true;
        
        return false;
    }
    
    // Render ManageProfile Card if It is ASP user with or without active TSP or BSP
    @AuraEnabled
    public static boolean renderOtherTiles() {
    
        boolean result = getLoggedInUserDetails();
        System.debug('result'+result);
        return getLoggedInUserDetails();
    }
    
    //Render DVD Card if It is ASP user or it is DVD user
    @AuraEnabled
    public static boolean renderDVD() {
    
        User user = [SELECT Id, FirstName, LastName, Profile.Name, Contact.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<AuthSession> authSessions =  [Select LoginType FROM AuthSession WHERE UsersId = :UserInfo.getUserId()];
        if(0 == authSessions.size() && user.ContactId == NULL) {
            //guest user
            PageReference myPage = new PageReference('/s/login');
            return false;
        }
        if(user.contactId != NULL) {
            
            Contact contact = [select id, Name,Account.id from Contact where id=: user.Contact.id LIMIT 1];
            Account account = [select id from Account where id =: contact.Account.id LIMIT 1];
            
            if(user.Profile.Name == GlobalConstants.MSC_PROFILE_NAME) 
                return true;
            else if(user.Profile.Name == GlobalConstants.ASP_PROFILE_NAME
                    || user.Profile.Name == GlobalConstants.Taxi_ASP_PROFILE_NAME 
                    || user.Profile.Name == GlobalConstants.ASP_COMMUNITY_PLUS_PROFILE_NAME )
                return true;    
            else
                return false;
        }
        else if(user.Profile.Name == GlobalConstants.ADMIN_PROFILE_NAME) {
            return true;
        }
        else {
            
            PageReference myPage = new PageReference('/s/login');
            return false;
        }
        
    }
    
    //Return true if current user is ASP or System Admin.
    public static boolean getLoggedInUserDetails(){
        
        User user = [SELECT Id, FirstName, LastName, Profile.Name, Contact.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<AuthSession> authSessions =  [Select LoginType FROM AuthSession WHERE UsersId = :UserInfo.getUserId()];
        if(0 == authSessions.size() && user.ContactId == NULL) {
            //guest user
            PageReference myPage = new PageReference('/s/login');
            return false;
        }
        if(user.contactId != NULL) {
        
            Contact contact = [select id, Name,Account.id from Contact where id=: user.Contact.id LIMIT 1];
            Account account = [select id from Account where id =: contact.Account.id LIMIT 1];
            if(user.Profile.Name == GlobalConstants.ASP_PROFILE_NAME
                || user.Profile.Name == GlobalConstants.Taxi_ASP_PROFILE_NAME
              	|| user.Profile.Name == GlobalConstants.ASP_COMMUNITY_PLUS_PROFILE_NAME ){
                return true;
            }
            else
                return false;
        }
        else {
        
            if(user.Profile.Name == GlobalConstants.ADMIN_PROFILE_NAME){
                return true;
            }
            return false;
        }
    }
}