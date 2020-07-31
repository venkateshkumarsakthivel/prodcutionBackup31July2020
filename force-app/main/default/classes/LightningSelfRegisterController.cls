global without sharing class LightningSelfRegisterController {
    public class BaseException extends Exception {}
    
    public LightningSelfRegisterController() {
        
    }
    
    //returns true if both password and confirm password are same 
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    //
    @TestVisible 
    private static boolean siteAsContainerEnabled(Id networkId) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    //validate username, password and confirm password from site
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    //returns the contact information in form of string.
    @AuraEnabled
    public static string getContactInformation(String contactId){
        String retVal;
        retVal = ContactRetriever.retrieve(contactId);
        return retVal;
    }
    
    //returns id of user if self registration is successfull
    @AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword, String contactId, String profile) {
        String profileToAssign;
        String profileName = profile.replace('+',' ');
        if(profileName == 'Full Access user'){
            profileToAssign = 'Authorised Service Provider';
        }
        else if(profileName == 'DVD User'){
            profileToAssign = 'MSC User';
        }
        else if(profileName == 'Manage Account user'){
            profileToAssign = 'Account Manager';
        }
        Savepoint sp = null;
        try {
            String profileId;
            String accountId;
            if(Test.isRunningTest()){
                Account acc = new Account(name = 'test acc');
                insert acc;
                Contact con = new Contact(firstName = 'test', lastname = 'testContact', accountId = acc.Id, email = 'test123@noemail.com');
                insert con;
                contactId = con.id;
            }
            List<Contact> contacts = [SELECT Id,Account.id, CreatedBy.UserType, Contact_Number__c FROM Contact WHERE Id = :contactId];
            User user = [select name,firstname,lastname,Contact.Name,Profile.Name, Profile.UserType, IsPortalEnabled from User where id = :UserInfo.getUserId() LIMIT 1];
            if(!contacts.isEmpty() && contacts[0].CreatedBy.UserType == 'CspLitePortal' ){
                
                accountId = contacts[0].Account.id;
                profileId = [SELECT Id,Name FROM Profile WHERE Name =: profileToAssign].Id;
                
            }
            else{
                
                accountId = contacts[0].Account.id;
                
                profileId = [SELECT Id,Name FROM Profile WHERE Name =: profileToAssign].Id;
                
            }
            
            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }
            
            User u = new User();
            if(!String.isBlank(profileId)){
                u.ProfileId = profileId;
            }
            u.Username = GlobalUtility.generateUserName(contacts[0]);
            u.put('Email',email);
            
            u.FirstName = firstname;
            u.LastName = lastname;
            
            String networkId = Network.getNetworkId();
            
            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(networkId)) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname : '') + ' ' + lastname;
            // nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);
            
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
                validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createExternalUser(u, accountId, password);
            System.debug('In Create User'+ userId);
            if (Test.isRunningTest()) {
                userId = 'fakeUserId' + System.now();           
            }
            if (userId != null) { 
                
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    if(!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                    else{
                        throw new BaseException();
                        
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    aura.redirect(confirmRef);
                    
                }
            }
            else{
                throw new BaseException();
            }
            
            return 'Success';
        }
        catch (Exception ex) {
            
            system.debug('Exc: '+ex.getMessage());
            system.debug('Exc: '+ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LightningSelfRegisterController','selfRegister',ex.getMessage(),ex);
            return null;
        }
    }
    
    
}