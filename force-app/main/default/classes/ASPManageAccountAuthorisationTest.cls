@isTest
public class ASPManageAccountAuthorisationTest {
    
    
    @isTest
    static void getNotifiableOccurrencesRecordsTest(){
        Id ownerid = GlobalUtility.getOwnerId();
        Id caseNotifiableOccurrenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_LABEL_NOTIFIABLE_OCCURRENCE).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Case cas = new Case(AccountId=ac.id,RecordtypeId=caseNotifiableOccurrenceRecordTypeId,Authorisation__c=auth.Id,Status='New',ContactId=con.Id,Postcode__c='2000',City__c='Sydney',State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas;
        List<Case> caseList = new List<Case>();
        caseList= ASPManageAccountAuthorisation.getNotifiableOccurrencesRecords();
    }
    
    @testSetup 
    static void createASPUserAndAccount(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void getLoggedInUserAccountTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        String usr;
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        system.runAs(user){
            usr = ASPManageAccountAuthorisation.getLoggedInUserAccount();
        }
        system.assert(usr != null);
    }
    
    @isTest
    private static void getAuthorisationRecordsTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        List<Authorisation__c> retrievedAuthorisationList = new List<Authorisation__c>();
        List<Authorisation__c> authorisationList = new List<Authorisation__c>();
        test.startTest();
        System.runAs(user) {
            for(Integer i = 0; i < 5; i++){
                Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
                authorisationList.add(auth);
            }
            insert authorisationList;
            retrievedAuthorisationList = ASPManageAccountAuthorisation.getAuthorisationRecords();
        }
        test.stopTest();
        System.assertEquals(5, retrievedAuthorisationList.size());
    } 
    
    
    @isTest
    private static void surrenderAuthorisationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        String returnedValue;
        String SurrenderDate = Datetime.now().format('yyyy-MM-dd');
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = user.ContactId);
        insert auth;
        test.startTest();
        System.runAs(user) {
            returnedValue = ASPManageAccountAuthorisation.surrenderAuthorisation(auth.id,SurrenderDate);
        }
        test.stopTest();
        System.assertNotEquals(NULL, returnedValue);
    }
    
    @isTest
    private static void renewAuthorisationTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        Case c = new Case(AccountId = accountId, Service_Type__c = 'Taxi',ContactId = conId, Status = GlobalConstants.CLOSED_CASE_STATUS,Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_GRANTED
                          ,Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE ,Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION, RecordTypeId = rtIdforIndividual);
        insert c;
        
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId, Application__c = c.Id);
        insert auth;
        test.startTest();
        String returnedValue;
        System.runAs(user) {
            returnedValue = ASPManageAccountAuthorisation.renewAuthorisation(auth.id);
        }
        test.stopTest();
        system.assert(returnedValue != '');
        
    }
    
    @isTest
    private static void createRelatedContactTest(){
        
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        system.runas(user){
            Contact con = new Contact( Australian_Driver_Licence_Number__c = 'ASDF234',LastName = 'sample', FirstName = 'test' ,Other_Name_Details__c = 'other_name',State__c = 'NSW' , Other_given_name__c = 'No Other name' ,MailingCity = 'Sydney',MailingCountry = 'Aus' ,MailingStreet = 'Castlereagh street', MailingState = 'NSW',Title = 'Mr.');
            insert con;
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId);
            insert auth;
            Authorisation_Contact__c authContact = new Authorisation_Contact__c(Authorisation__c = auth.Id, Contact__c = con.Id);
            insert authContact;
            
            Related_Contact__c rc = ASPManageAccountAuthorisation.createRelatedContact(authContact);
            system.assert(rc != null);
        }
        test.stopTest();
        
    }
    
}