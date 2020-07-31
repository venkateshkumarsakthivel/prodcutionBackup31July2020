@IsTest
private with sharing class ContactAccessUpdaterTest{

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try{
            ContactAccessUpdater updater = new ContactAccessUpdater(null, null);
            System.assert(false);
        } catch(ContactAccessUpdater.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForDvdAccess(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        for(Contact oldCon : newContacts.values()){
            oldCon.Is_Access_Level_Account_Administrator__c = false;
            oldCon.Is_Access_Level_DVD_Administrator__c = true;
        }
        update newContacts.values();
        
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();
        
        Id dvdUserProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.MSC_PROFILE_NAME LIMIT 1].Id;
        List<User> userRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(!userRec.isEmpty());
        System.assert(userRec[0].ProfileId == dvdUserProfileId);    
        
    }
    
    private static testMethod void testForLevyAccess(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        for(Contact oldCon : newContacts.values()){
            oldCon.Is_Access_Level_Account_Administrator__c = false;
            oldCon.Is_Access_Level_Levy_Administrator__c = true;
        }
        update newContacts.values();
        
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();
        
        Id levyUserProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.LEVY_PROFILE_NAME LIMIT 1].Id;
        List<User> userRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(!userRec.isEmpty());
        System.assert(userRec[0].ProfileId == levyUserProfileId);    
        
    }
    
    private static testMethod void testForAccountMgrAccess(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        for(Contact oldCon : newContacts.values()){
            oldCon.Is_Access_Level_Account_Administrator__c = true;
            oldCon.Is_Access_Level_DVD_Administrator__c = false;
        }
        update newContacts.values();
        
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();
        
        Id accountManagerUserProfileId = [SELECT Id FROM Profile 
            WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME LIMIT 1].Id;
        List<User> userRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(!userRec.isEmpty());
        System.assert(userRec[0].ProfileId == accountManagerUserProfileId); 
    }
    
    private static testMethod void testForAccountMgrLevyAccess(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        for(Contact oldCon : newContacts.values()){
            oldCon.Is_Access_Level_Account_Administrator__c = true;
            oldCon.Is_Access_Level_DVD_Administrator__c = false;
            oldCon.Is_Access_Level_Levy_Administrator__c = true;
        }
        update newContacts.values();
        
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();
        
        Id accountManagerLevyUserProfileId = [SELECT Id FROM Profile 
                                              WHERE Name = :GlobalConstants.ACCOUNT_MANAGER_USER_PROFILE_NAME LIMIT 1].Id;
        List<User> userRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(!userRec.isEmpty());
        System.assert(userRec[0].ProfileId == accountManagerLevyUserProfileId); 
    }
    
    private static testMethod void testForASPAccess(){
        Map<Id, Contact> newContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                                Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                            FROM Contact]);
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c 
                                                             FROM Contact]);
        for(Contact oldCon : oldContacts.values()){
            oldCon.Is_Access_Level_Account_Administrator__c = false;
            oldCon.Is_Access_Level_DVD_Administrator__c = false;
        }
        
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(newContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();
        
        Id fullAccessUserProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.ASP_PROFILE_NAME LIMIT 1].Id;
        List<User> userRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(!userRec.isEmpty());
        System.assert(userRec[0].ProfileId == fullAccessUserProfileId);     
    }
    
    private static testMethod void testForNoAccessUpdate(){
        Map<Id, Contact> oldContacts = new Map<Id, Contact>([SELECT Id, Is_Access_Level_Levy_Administrator__c,
                                                             Is_Access_Level_Account_Administrator__c, Is_Access_Level_DVD_Administrator__c,
                                                             Is_Access_Level_Taxi_Agent__c 
                                                             FROM Contact]);
        List<User> oldUserRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.Test.startTest();
        ContactAccessUpdater accessUpdater = new ContactAccessUpdater(oldContacts, oldContacts);
        accessUpdater.updateAccess();
        System.Test.stopTest();     
        List<User> newUserRec = [SELECT Id, ProfileId FROM User WHERE ContactId IN : oldContacts.keySet()];
        System.assert(newUserRec.size() == oldUserRec.size());
    }
    
    @TestSetup
    private static void setupTestData(){
        Account act = createAccount();
        Contact con = createContact(act.Id);        
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
                                        Is_Access_Level_DVD_Administrator__c = true,
                                        Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert contact;
        return contact;
    }    
}