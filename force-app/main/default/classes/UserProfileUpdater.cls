/*
 * Class responsible to send http request for user profile update.
 * This approach is needed as user profile needs to be changed in context 
 * of community user
*/
public without sharing class UserProfileUpdater {
    
    //method that updates user to PSP profile
    @future(callout=true)
    public static void updateUserProfile(Set<String> userIds) {
        try{
            
            
            Community_Site_URL__c commURL = Community_Site_URL__c.getValues('Industry Portal URL');
            for(String tempUserId : userIds) {
                
                String remoteURL = commURL.URL__c+'ProfileUpdate?userId='+tempUserId;
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod('GET');
                httpRequest.setEndpoint(remoteURL);
                HttpResponse httpResponse = new Http().send(httpRequest);
            }   
            
        }catch(Exception ex){
            System.debug('Exception: '+ex.getLineNumber());
            System.debug('Exception: '+ex.getMessage());
        }   
    }
}