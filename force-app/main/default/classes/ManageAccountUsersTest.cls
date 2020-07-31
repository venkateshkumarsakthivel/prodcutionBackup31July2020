@IsTest
private with sharing class ManageAccountUsersTest{

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        ManageAccountUsers.updateUser(null);
        System.Test.stopTest();
        Account act = [SELECT Id FROM Account LIMIT 1];
        List<User> users = [SELECT Id FROM User WHERE AccountId = :act.Id];
        System.assert(users.size() == 1);
    }
    
    private static testMethod void testForTaxiPlusAsp(){
        Contact con = [SELECT Id, Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c FROM Contact LIMIT 1];
        con.Is_Access_Level_Account_Administrator__c = true;
        con.Is_Access_Level_DVD_Administrator__c = true;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        Database.update(con, dml);
        
        Id taxiAndASPProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.Taxi_ASP_PROFILE_NAME LIMIT 1].Id;
        
        System.Test.startTest();
        ManageAccountUsers.updateUser(new List<Id>{con.Id});
        System.Test.stopTest();
        User updatedUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE ContactId = :con.Id];
        System.debug(LoggingLevel.INFO, 'Updated user: ' + updatedUser);
        System.assert(updatedUser.ProfileId == taxiAndASPProfileId);
    }
    
    private static testMethod void testForTaxiPlusAccountMgr(){
        Contact con = [SELECT Id, Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c FROM Contact LIMIT 1];
        con.Is_Access_Level_Account_Administrator__c = true;
        con.Is_Access_Level_DVD_Administrator__c = false;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        Database.update(con, dml);
        
        Id taxiAndAccountManagerProfileId = [SELECT Id FROM Profile 
                                            WHERE Name = :GlobalConstants.Taxi_ACCOUNT_MANAGER_PROFILE_NAME LIMIT 1].Id;
        
        System.Test.startTest();
        ManageAccountUsers.updateUser(new List<Id>{con.Id});
        System.Test.stopTest();
        User updatedUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE ContactId = :con.Id];
        System.debug(LoggingLevel.INFO, 'Updated user: ' + updatedUser);
        System.assert(updatedUser.ProfileId == taxiAndAccountManagerProfileId);
    }
    
    private static testMethod void testForDvdAccess(){
        Account act = [SELECT Id FROM Account LIMIT 1];
        Contact con = createContact(act.Id);
        con.Is_Access_Level_Account_Administrator__c = false;
        con.Is_Access_Level_DVD_Administrator__c = true;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        Database.update(con, dml);
        
        Id dvdUserProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.MSC_PROFILE_NAME LIMIT 1].Id;
        
        System.Test.startTest();
        ManageAccountUsers.updateUser(new List<Id>{con.Id});
        System.Test.stopTest();
        User updatedUser = [SELECT Id, ProfileId FROM User WHERE ContactId = :con.Id];
        System.assert(updatedUser.ProfileId == dvdUserProfileId);
    }
    
    private static testMethod void testForAccountMgrAccess(){
        Account act = [SELECT Id FROM Account LIMIT 1];
        Contact con = createContact(act.Id);
        con.Is_Access_Level_Account_Administrator__c = true;
        con.Is_Access_Level_DVD_Administrator__c = false;
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        Database.update(con, dml);
        
        Id accountManagerUserProfileId = [SELECT Id FROM Profile 
            WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME LIMIT 1].Id;
        
        System.Test.startTest();
        ManageAccountUsers.updateUser(new List<Id>{con.Id});
        System.Test.stopTest();
        User updatedUser = [SELECT Id, ProfileId FROM User WHERE ContactId = :con.Id];
        System.assert(updatedUser.ProfileId == accountManagerUserProfileId);
    }
    
    private static testMethod void testForNonTaxiAccess(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id dvdUserProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.MSC_PROFILE_NAME LIMIT 1].Id;
        Id accountManagerUserProfileId = [SELECT Id FROM Profile 
            WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME LIMIT 1].Id;
        
        User userRec = [SELECT Id, ProfileId FROM User WHERE ContactId = :con.Id];
        userRec.ProfileId = dvdUserProfileId;
        update userRec;
        
        System.Test.startTest();
        ManageAccountUsers.updateUser(new List<Id>{con.Id});
        System.Test.stopTest();
        User updatedUser = [SELECT Id, ProfileId FROM User WHERE ContactId = :con.Id];
        System.assert(updatedUser.ProfileId == accountManagerUserProfileId);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Contact con = createContact(act.Id);
        Id taxiLicenceUserProfileId = [ SELECT Id FROM Profile 
                                        WHERE Name = :GlobalConstants.TAXI_LICENCE_USER_PROFILE_NAME LIMIT 1].Id;
        createUser(con.Id, taxiLicenceUserProfileId);
    }
    
    private static Account createAccount(){
         Id ownerid = GlobalUtility.getOwnerId();
        Account account = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                      Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                      Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                      BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                      ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',OwnerId=ownerid);
        insert account;
        return account;
    }
    
    private static Contact createContact(Id actId){
        Contact contact = new Contact(Title='Mr.',LastName ='testCon',AccountId = actId,
                                        Is_Access_Level_Account_Administrator__c = true,
                                        Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert contact;
        return contact;
    }
    
    private static User createUser(Id conId, Id profileId){
        Long millis = System.now().getTime();
        User user = new User(alias = 'test123', email='test123@example.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username= millis + 'tester@example.com');
        insert user;
        return user;
    }
}