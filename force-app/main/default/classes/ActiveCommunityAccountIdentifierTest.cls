@IsTest
private with sharing class ActiveCommunityAccountIdentifierTest {

    private static testMethod void testForInvalidData(){
        System.Test.startTest();
        try {
            ActiveCommunityAccountIdentifier identifier = new ActiveCommunityAccountIdentifier(null);
            System.assert(false);
        } catch(ActiveCommunityAccountIdentifier.InvalidDataException e){
            System.assert(true);
        }
        System.Test.stopTest();
    }
    
    private static testMethod void testForInactiveAccounts(){
        Account acc = createAccount('Inactive Account');
        List<Id> actIds = new List<Id>{acc.Id};
        
        System.Test.startTest();
        ActiveCommunityAccountIdentifier identifier = new ActiveCommunityAccountIdentifier(actIds);
        Set<Id> inactiveAcc = identifier.retrieveInactiveAccounts();
        System.Test.stopTest();
        System.assert(inactiveAcc.contains(acc.Id));
    }
    
    private static testMethod void testForActiveAccounts(){
        Map<Id, Account> actMap = new Map<Id, Account>([SELECT Id FROM Account]);
        List<Id> actIds = new List<Id>(actMap.keySet());
        System.Test.startTest();
        ActiveCommunityAccountIdentifier identifier = new ActiveCommunityAccountIdentifier(actIds);
        Set<Id> activeAcc = identifier.retrieveActiveAccounts();
        System.Test.stopTest();
        System.assert(activeAcc.contains(actIds[0]));
    }
    
    private static testMethod void testForPortalUsers(){
        Map<Id, Account> actMap = new Map<Id, Account>([SELECT Id FROM Account]);
        List<Id> actIds = new List<Id>(actMap.keySet());
        System.Test.startTest();
        ActiveCommunityAccountIdentifier identifier = new ActiveCommunityAccountIdentifier(actIds);
        List<User> portalUsers = identifier.retrievePortalUsers();
        System.Test.stopTest();
        System.assert(portalUsers.size() == 1);
    }
    
    @TestSetup
    private static void setupTestData(){
        Account acc = createAccount('Test Account');
        Contact con = createContact(acc.Id);
        createPortalUser(con.Id);
    }
    
    private static Account createAccount(String accName){
         Id ownerid = GlobalUtility.getOwnerId();
        Account acc = new Account(name = accName, BillingStreet='Castlereagh Street', 
            BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert acc;
        return acc;
    }
    
    private static Contact createContact(Id accId){
        Contact con = new Contact(LastName ='testCon',AccountId = accId, Email='test@example.com');
        insert con;
        return con;
    }
    
    private static User createPortalUser(Id conId){
        Id p = GlobalUtility.getASPProfile().id;
        Long millis = System.now().getTime();
        User user = new User(alias = 'test123', email='test123@example.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username= millis + 'tester@noemail.com');
        insert user;
        return user;
    }
}