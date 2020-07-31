@isTest
public class AuthorisationVsConditionsHandlerTest {
    
    @testSetup 
    static void createASPAccountAndContact(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    public static void attachConditionsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRec = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        insert authRec;
        
        List<Condition__c> selectedConditions = new List<Condition__c>();
        Condition__c conditionRec = new Condition__c(Condition_Details__c = 'Selected Details to test', Internal_Notes__c = 'Selected Notes to test', Authority__c = authRec.Id);
        selectedConditions.add(conditionRec);
        insert selectedConditions;
        
        List<Condition__c> unSelectedConditions = new List<Condition__c>();
        Condition__c conditionRecs = new Condition__c(Condition_Details__c = 'Unselected Details to test', Internal_Notes__c = 'Unselected Notes to test', Authority__c = authRec.Id);
        unSelectedConditions.add(conditionRecs);
        insert unSelectedConditions;
        
        String selectConditions = JSON.serialize(selectedConditions);
        String unSelectConditions = JSON.serialize(unSelectedConditions);
        String authRecId = authRec.Id;
        
        List<Condition__c> insertedConditions = new List<Condition__c>();
        
        test.startTest();
        System.runAs(user) {
            AuthorisationVsConditionsHandler.attachConditions(unSelectConditions, selectConditions, authRecId);                        
            insertedConditions = [SELECT Id from Condition__c where Authority__c = :authRec.Id];            
        }
        test.stopTest();        
        
        System.assertEquals(1, insertedConditions.size());
    }
    
    
    @isTest
    public static void getConditionsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'Granted With Conditions', Service_Provider__c = accountId);
        insert authRecord;
        
        Master_Condition__c conditionRec = new Master_Condition__c(Condition_Details__c = 'Selected Details to test', Status__c = 'Active', Type__c = 'Booking Service Provider');        
        insert conditionRec;                
        
        List<Condition__c> insertedConditions = new List<Condition__c>();
        
        test.startTest();
        System.runAs(user) {
            insertedConditions = AuthorisationVsConditionsHandler.getConditions(authRecord.Id);                                    
        }
        test.stopTest();        
        
        System.assertEquals(2, insertedConditions.size());
    }
    @isTest
    public static void validToAddConditionsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'New', Service_Provider__c = accountId);
        insert authRecord;
        Boolean result;
        
        test.startTest();
        System.runAs(user) {
            result = AuthorisationVsConditionsHandler.validToAddConditions(authRecord.Id);                                 
        }
        test.stopTest();     
        System.assertEquals(true, result);
        
        
    }

	@isTest
    public static void level3_valid_to_add_conditions_test(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id l3ProfileId = [Select Id from Profile where Name = :GlobalConstants.P2P_OPERATIONS_LEVEL_3 LIMIT 1].Id;
        
        User user = new User(alias = 'test123', email='p2plevel3@testemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = l3ProfileId, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='p2plevel3@testemail.com');
        
        insert user;
        
        Authorisation__c authRecord = new Authorisation__c(Authorisation_Type__c = 'BSP', Status__c = 'New', Service_Provider__c = accountId);
        insert authRecord;
        Boolean result;
        
        test.startTest();
        System.runAs(user) {
            result = AuthorisationVsConditionsHandler.validToAddConditions(authRecord.Id);                                 
        }
        test.stopTest();     
        System.assertEquals(true, result);
    }
    
}