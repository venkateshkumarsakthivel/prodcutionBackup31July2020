/*
 * @Description: Helper class to upgrade/downgrade portal user access for ASP
 */
public without sharing class ManageAccountUsers {
    
    private static final String TAXI = 'Taxi';
    private static final String ASP = 'ASP';
    private static final String Admin = 'Admin';
    private static final String DVD = 'DVD';
    private static final String LEVY = 'Levy';
    private static final String TAXI_AGENT = 'Taxi Agent';
    
    private static Map<String, Id> accessVsProfileId;
    
    static {
        
        //retrieve community profiles
        Map<String, Id> profileNameVsId = GlobalUtility.getCustomerPortalProfiles();
        accessVsProfileId = new Map<String, Id>();
       
        for(String name : profileNameVsId.keyset()) {
           
            if(name == GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME){
                accessVsProfileId.put(Taxi, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME){
                accessVsProfileId.put(Taxi + Admin, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.Taxi_ASP_PROFILE_NAME){
                accessVsProfileId.put(Taxi + ASP, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.ASP_PROFILE_NAME){
                accessVsProfileId.put(ASP, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME){
                accessVsProfileId.put(Admin, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.MSC_PROFILE_NAME){
                accessVsProfileId.put(DVD, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.LEVY_PROFILE_NAME){
                accessVsProfileId.put(LEVY, profileNameVsId.get(name));
                
            } else if(name == GlobalConstants.TAXI_AGENT_USERS_PROFILE_NAME){
                accessVsProfileId.put(TAXI_AGENT, profileNameVsId.get(name));
            
            }
        }
    }
    
    private static User createUser(Contact contact){
        User newUser = new User();                    
        newUser.ContactId = contact.Id;
        newUser.FirstName = contact.FirstName;
        newUser.LastName = contact.LastName;
        newUser.Email = contact.Email;
        newUser.Username = GlobalUtility.generateUserName(contact);
        newUser.CommunityNickname = contact.FirstName + '_' + contact.LastName + '_' + Integer.valueOf(Math.random() * 10);
        String alias = contact.LastName + '_' + contact.FirstName;
        newUser.Alias = alias.length() > 7 ? alias.substring(0, 7) : alias;
        newUser.TimeZoneSidKey = 'Australia/Sydney';
        newUser.LocaleSidKey = 'en_AU';
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey ='en_US';
        newUser.IsActive = true;
        
        return newUser;
    }
    
    private static String identifyAccess(Contact con, String prefix){
        
        String profile = prefix != null? prefix : '';
        if(con.Is_Access_Level_Account_Administrator__c && con.Is_Access_Level_DVD_Administrator__c){
            profile += ASP;
        } else if(con.Is_Access_Level_Account_Administrator__c){
            profile += Admin;
        } else if(con.Is_Access_Level_Levy_Administrator__c){
            profile = LEVY;
        } else if(con.Is_Access_Level_DVD_Administrator__c){
            profile = DVD;
        } else if(con.Is_Access_Level_Taxi_Agent__c){
            profile = TAXI_AGENT;
        }
        
        return profile;
    }
    
    private static Boolean isCurrentTaxiUser(String profileName){
        if(profileName == GlobalConstants.Taxi_ASP_PROFILE_NAME
                || profileName == GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME
                || profileName == GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME){
            return true;
        }
        return false;
    }
    
    //Function to update user
    @future(callout=true)
    public static void updateUser(List<Id> contacts) {        
        try {
            Map<Id,Contact> contactMap =new Map<Id, Contact>([SELECT Id, Is_Access_Level_DVD_Administrator__c,
                                                              Is_Access_Level_Account_Administrator__c, Contact_Number__c, Is_Access_Level_Levy_Administrator__c,
                                                              AccountId, FirstName, LastName, Email, Access_Level__c, Is_Access_Level_Taxi_Agent__c
                                                              FROM Contact WHERE Id IN :contacts]);
            
            Map<Id, User> contactVsUser = new Map<Id, User>();
            List<User> users = [SELECT Id, IsActive, IsPortalEnabled, ProfileId, Profile.Name, ContactId
                                FROM User WHERE ContactId IN: contacts];
            for(User user : users){
                contactVsUser.put(user.ContactId, user);
            }
            
            User runningUserToUpdate;
            
            List<User> usersToUpsert = new List<User>();
            //upgrade/downgrade existing portal user
            for(Id contactId : contactVsUser.keySet()){
                User user = contactVsUser.get(contactId);
                Contact contact = contactMap.get(contactId);
                String access;
                user.IsActive = true;
                if(isCurrentTaxiUser(user.Profile.Name)){
                    access = identifyAccess(contact, Taxi);
                } else {
                    access = identifyAccess(contact, null);
                }
                if(accessVsProfileId.containsKey(access)){
                    user.ProfileId = accessVsProfileId.get(access);
                }
                runningUserToUpdate = user;
                if(user.Id != UserInfo.getUserId()){
                    usersToUpsert.add(user);
                    runningUserToUpdate = null;
                }
            }
            
            //create new user for non-existing users
            for(Id contactId : contactMap.keySet()){
                //create new user for non-existing user
                if(!contactVsUser.containsKey(contactId)){
                    System.debug(LoggingLevel.INFO, 'Creating user record for ' + contactMap.get(contactId));
                    String access = identifyAccess(contactMap.get(contactId), null);
                    System.debug(LoggingLevel.INFO, 'Access to be granted to contact: ' + access);
                    User user = createUser(contactMap.get(contactId));
                    
                    if(accessVsProfileId.containsKey(access)){
                        user.ProfileId = accessVsProfileId.get(access);
                        usersToUpsert.add(user);
                    }
                }
            }
            
            List<Database.UpsertResult> results = Database.upsert(usersToUpsert, User.Fields.Id, false);
            for(Database.UpsertResult result : results){
                System.debug(LoggingLevel.INFO, 'User creation result ' + result.isSuccess());
                System.debug(LoggingLevel.INFO, result.getErrors());                
            }
            if(runningUserToUpdate != null){
                System.debug(LoggingLevel.INFO, 'Updating profile for current user');
                Community_Site_URL__c commURL = Community_Site_URL__c.getValues('Industry Portal URL');
                String remoteURL = commURL.URL__c+'ProfileUpdate?userId='+runningUserToUpdate.Id+'&profileId='+runningUserToUpdate.ProfileId;
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod('GET');
                httpRequest.setEndpoint(remoteURL);
                HttpResponse httpResponse = new Http().send(httpRequest);
            }                       
        } catch(Exception ex) {
            System.debug('exce' + ex.getMessage());
            System.debug('exce' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountUsers','updateUser',ex.getMessage(),ex);
        }
    }
    
    //Function to update user
    @future(callout=true)
    public static void updateUserEmail(Id editedContactId, String updatedEmail) {
        
        try {
            
            User user = [SELECT Id, ContactId, Email
                         FROM User WHERE ContactId =: editedContactId];
            
            user.Email = updatedEmail;
            
            update user;
            
        } catch(Exception ex) {
            System.debug('ManageAccountUsers Exception' + ex.getMessage());
            System.debug('ManageAccountUsers Exception' + ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ManageAccountUsers','updateUserEmail',ex.getMessage(),ex);
        }
    }    
}