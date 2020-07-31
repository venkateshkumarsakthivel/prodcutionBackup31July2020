@isTest
public class VaryAuthorisationControllerTest {
    @testSetup 
    static void testSetup(){
        try{
              Id ownerid = GlobalUtility.getOwnerId();
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
            
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationControllerTest','testSetup',ex.getMessage(),ex);
        }  
    }
    
    @isTest
    private static void varyAuthorisationTest(){
        try{
            
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
            
            
            Authorisation__c auth = new Authorisation__c(Service_Provider__c = accountId, Contact__c = conId);
            insert auth;
            
            Condition__c c = new Condition__c(Authority__c =auth.Id);
            insert c;
            String returnedValue;
            System.runAs(user) {
                returnedValue = VaryAuthorisationController.varyAuthorisation(auth.id, 'Test Decision Reason');
            }
            system.assert(returnedValue != null);
              System.runAs(user) {
                returnedValue = VaryAuthorisationController.varyAuthorisation('shscschsvcv', 'Test Decision Reason');
                  
            }
             system.assert(returnedValue == null);
            
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationControllerTest','varyAuthorisationTest',ex.getMessage(),ex);
        } 
    }
    
    
    @isTest
    private static void validateAuthorisationRecordTest(){
        
        try{
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
            
            
            Authorisation__c auth1 = new Authorisation__c(Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Service_Provider__c = accountId, Contact__c = conId);
            insert auth1;
            
            Authorisation__c auth2 = new Authorisation__c(Status__c = GlobalConstants.GRANTED_CONDITIONALLY, Service_Provider__c = accountId, Contact__c = conId);
            insert auth2;
            
            Authorisation__c auth3 = new Authorisation__c(Status__c = GlobalConstants.AUTHORISATION_SUSPENDED, Service_Provider__c = accountId, Contact__c = conId);
            insert auth3;
            
            String returnedValue;
            System.runAs(user) {
                for(Authorisation__c a : [SELECT Id FROM Authorisation__c]){
                    returnedValue = VaryAuthorisationController.validateAuthorisationRecord(a.id); 
                    system.assert(returnedValue!=null);
                }
            }
            
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationControllerTest','validateAuthorisationRecordTest',ex.getMessage(),ex);
        } 
    }
}