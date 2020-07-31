//Class for registering applicant
//This class is used for user registration process

global without sharing class ApplicantRegisterController {
    public class BaseException extends Exception {}
    public ApplicantRegisterController() {
    }
    
   // Method for preparing data for registration
    @AuraEnabled
    public static String handleApplicantRegister(String firstname,String lastname,string registerFor,string email,String mobile, String entity,String acn,String companyName,String partnershipName){
        
        String profileId;
        Account account;
        Contact con;
        
        String fname = firstname;
        
        if(firstname !=null){
            List<String> fname1 = fname.split(' '); 
            fname = ''; 
            for (String x : fname1) { 
                fname += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' '; 
            }
        } 
        System.debug('==>>>'+fname);
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllorNone = FALSE;
        dmo.DuplicateRuleHeader.allowSave = true;
        dmo.DuplicateRuleHeader.runAsCurrentUser = false;
        
        Savepoint sp = Database.setSavepoint();
        
        try{
        //Validate if contact already exists with the same mobile number
        List<Contact> ct = [SELECT Id FROM Contact WHERE MobilePhone =: mobile OR Phone =: mobile];
        if(!ct.isEmpty()){
            return 'Mobile registered';
        }
        
        if(entity == GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL){
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL).getRecordTypeId();
            Community_Account_Contact_Owner__mdt communityOwner = [select Owner_Id__c from Community_Account_Contact_Owner__mdt limit 1];
            Id ownerId = communityOwner.Owner_Id__c;
            account = new Account(Name = fname +' '+lastname, RecordTypeId = recordTypeId , OwnerId = ownerId);
            insert account;
            account.setOptions(dmo);
            con = new Contact(FirstName = fname , LastName = lastname , AccountId = account.id , MobilePhone = mobile , Email = email, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE);
            con.Primary_Contact__c = TRUE;
            con.setOptions(dmo);
            insert con;
        }        
        else if(entity == GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL_PARTNERSHIP){
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_NAME_INDIVIDUAL_PARTNERSHIP).getRecordTypeId();
            Community_Account_Contact_Owner__mdt communityOwner = [select Owner_Id__c from Community_Account_Contact_Owner__mdt limit 1];
            Id ownerId = communityOwner.Owner_Id__c;
            account = new Account(Name = partnershipName , RecordTypeId = recordTypeId, OwnerId = ownerId);
            account.setOptions(dmo);
            insert account;
            con = new Contact(FirstName = fname , LastName = lastname , AccountId = account.id , MobilePhone = mobile , Email = email, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE);
            con.Primary_Contact__c = TRUE;
            con.setOptions(dmo);
            insert con;
        }
        
        else if(entity == GlobalConstants.ACCOUNT_ENTITY_TYPE_CORPORATION){
            
            List<Account> acc = [SELECT Id FROM Account WHERE ACN__C =: acn];
            if(acc.isEmpty()){
                Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION).getRecordTypeId();
                Community_Account_Contact_Owner__mdt communityOwner = [select Owner_Id__c from Community_Account_Contact_Owner__mdt limit 1];
                Id ownerId = communityOwner.Owner_Id__c;
                account = new Account(Name = companyName , RecordTypeId = recordTypeId , ACN__c = acn , OwnerId = ownerId);
                account.setOptions(dmo);
                insert account;
                con = new Contact(FirstName = fname , LastName = lastname , AccountId = account.id , MobilePhone = mobile , Email = email, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE);
                con.Primary_Contact__c = TRUE;
                con.setOptions(dmo);
                insert con;   
            }else{
                return 'Already registerd';
            }
        }
        
        else {
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(GlobalConstants.ACCOUNT_RECORDTYPE_NAME_CORPORATE_PARTNERSHIP).getRecordTypeId();
            Community_Account_Contact_Owner__mdt communityOwner = [select Owner_Id__c from Community_Account_Contact_Owner__mdt limit 1];
            Id ownerId = communityOwner.Owner_Id__c;
            account = new Account(Name = partnershipName, RecordTypeId = recordTypeId , ACN__c = acn , OwnerId = ownerId);
            account.setOptions(dmo);
            insert account;
            con = new Contact(FirstName = fname , LastName = lastname , AccountId = account.id , MobilePhone = mobile , Email = email, Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE);
            con.Primary_Contact__c = TRUE;
            con.setOptions(dmo);
            insert con;
        }
        
        
        //User creation
            User u = new User();
            if(registerFor == GlobalConstants.PROSPECTIVE_SERVICE_PROVIDER_USER_PROFILE_NAME){
                profileId = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.PROSPECTIVE_SERVICE_PROVIDER_USER_PROFILE_NAME].Id;  
                
                if(!String.isBlank(profileId)){
                    u.ProfileId = profileId;
                }
            }
            else {
                profileId = [SELECT Id,Name FROM Profile WHERE Name =: GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME].Id;  
                
                if(!String.isBlank(profileId)){
                    u.ProfileId = profileId;
                }
            }
            Map<Id, String> conVsUserName = GlobalUtility.generateUsernames(new List<Id>{con.Id});
            
            u.Username = conVsUserName.get(con.Id); 
            u.put('Email',email);
            u.ContactId = con.Id;
            u.FirstName = fname;
            u.LastName = lastname;
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            //String nickname = ((firstname != null && firstname.length() > 0) ? firstname.subString(0,3) : '') + lastname.subString(0,3);
            String nickname = ((firstname != null && firstname.length() > 0) ? 
                                        (firstname.length() > 3 ? firstname.subString(0,3) : firstname)
                                        : '') +
                              ((lastname != null && lastname.length() > 0) ? 
                                        (lastname.length() > 3 ? lastname.subString(0,3) : lastname)
                                        : '');
            nickname = (nickname + dateString.reverse()).subString(0,10);
            u.put('CommunityNickname', nickname);
            u.LocaleSidKey = 'en_AU';
            u.TimeZoneSidKey = 'Australia/Sydney';
            u.Alias = 'Tcode';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            
            
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            dlo.EmailHeader.triggerOtherEmail = true;
            
            Database.insert(u,dlo);
            
            if (u.Id != null) { 
                return 'Success';
            }
            else{
                throw new BaseException();
            }
            
        }
        catch(Exception ex) {
            
            System.debug('Response--------'+ ex.getMessage());
            String  response = ex.getMessage();
            
            if(response.contains('DUPLICATE_USERNAME') || response.contains('Duplicate Username')){
                response = 'Username already exists with this email address';
            }
            else if(response.contains('DUPLICATE_COMM_NICKNAME') || response.contains('Duplicate Nickname')){
                response = 'User already exists with the nick name you provided';
            }
            
            Database.rollback(sp);
            return response;
        }
    }
    
    @AuraEnabled
    public static Boolean checkForExistingEmail(String email){
        List<User> users = [SELECT Id FROM User WHERE Email = :email AND IsPortalEnabled = true];
        return !users.isEmpty();
    }
}