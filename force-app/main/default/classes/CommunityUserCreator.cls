/*
 * @Description: Helper class to create portal users for account/contact
 */
public without sharing class CommunityUserCreator {

    //Create portal user with taxi licence profile.
    @future
    public static void create(List<Id> conIds, Id profileId) {    
        if(conIds == null || conIds.isEmpty()){
            return;
        }
        List<User> usersToInsert = new List<User>();
        List<User> usersToUpdate = new List<User>();
        
        Map<Id, User> conVsUser = new Map<Id, User>();
        for(Id conId : conIds){
            conVsUser.put(conId, new User( ContactId = conId));
        }
        for(User user : [SELECT Id, UserName, ContactId, Email, FirstName, LastName FROM User WHERE ContactId IN :conIds]){
            conVsUser.put(user.ContactId, user);
        }
        
        //set dml options to send user creation emails
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;

        //retrieve contact details for whom portal user needs to be created
        for(Contact con : [SELECT Id, FirstName, LastName, AccountId, Email, Contact_Number__c FROM Contact WHERE Id IN : conIds]) {
            User u = conVsUser.get(con.Id);
            u.ProfileId = profileId;
            u.Username = GlobalUtility.generateUserName(con); 
            u.Email = con.Email;
            u.FirstName = con.FirstName; 
            u.LastName = con.LastName;
            u.IsActive = true;
            
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            String nickname = con.LastName;
            if(nickname.length() >= 5)
                nickname = nickname.substring(0, 4);
            nickname = (nickname + dateString.reverse()).subString(0,10);
            System.debug('nickname: '+nickname);
            
            u.put('CommunityNickname', nickname);
            u.LocaleSidKey = 'en_AU';
            u.TimeZoneSidKey = 'Australia/Sydney';
            String alias = u.LastName + '_' + u.FirstName;
            u.Alias = alias.length() > 7 ? alias.substring(0, 7) : alias;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            
            if(u.Id == null){
                u.setOptions(dlo);
                usersToInsert.add(u);                
            } else {
                usersToUpdate.add(u);
            }
            System.debug(LoggingLevel.INFO, 'New user created ' + u);
        }
       
        insert usersToInsert;
        update usersToUpdate;
    }
}