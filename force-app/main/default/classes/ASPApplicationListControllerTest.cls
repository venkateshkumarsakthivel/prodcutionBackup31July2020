@isTest
private class ASPApplicationListControllerTest {
    
    public class BaseException extends Exception {}
    
    @testSetup 
    static void ASPApplicationListControllerTest(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPApplicationListControllerTest','ASPApplicationListControllerTest',ex.getMessage(),ex);
        }   
    }
    
    
    
    @isTest
    private static void retrieveApplicationsTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_CORPORATION).getRecordTypeId();
            
            Id p = [select id from profile where name='Authorised Service Provider'].id;
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            
            List<Case> caseList = new List<Case>();
            List<Case> caseListToBeInserted = new List<Case>();
            
            Case Caserec1 = new Case();
            Caserec1.AccountId = user.AccountId;
            Caserec1.ContactId = user.ContactId;
            Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec1.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            Caserec1.RecordTypeId = rtIdforIndividual;
            
            caseListToBeInserted.add(Caserec1);
            
            Case Caserec2 = new Case();
            Caserec2.AccountId = user.AccountId;
            Caserec2.ContactId = user.ContactId;
            Caserec2.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec2.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            Caserec2.RecordTypeId = rtIdforCorporation;
            
            caseListToBeInserted.add(Caserec2);
            
            insert caseListToBeInserted;
            
            system.runAs(user){
                caseList = ASPApplicationListController.retrieveApplications();    
            }
            system.assertEquals(2, caseList.size()); 
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPApplicationListControllerTest','retrieveApplicationsTest',ex.getMessage(),ex); 
        }  
    }
    
    @isTest
    private static void withdrawASPApplicationTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_CORPORATION).getRecordTypeId();
            
            Id p = [select id from profile where name='Authorised Service Provider'].id;
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                                 contactId = conId,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            Case updatedCase = new Case();
            
            Case Caserec1 = new Case();
            Caserec1.AccountId = user.AccountId;
            Caserec1.ContactId = user.ContactId;
            Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
            Caserec1.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            Caserec1.RecordTypeId = rtIdforIndividual;
            insert CaseRec1;
            
            Authorisation__c auth = new Authorisation__c();
            auth.Application__c = CaseRec1.Id;
            auth.Service_Provider__c = accountId;
            insert auth;
            
            Case caseRec = [SELECT Id, Status FROM Case WHERE Status =: GlobalConstants.LODGED_CASE_STATUS LIMIT 1];
            String status;
            test.startTest();
            //system.runAs(user){
                caseRec.Status = GlobalConstants.CLOSED_CASE_STATUS;
                caseRec.Sub_Status__c = GlobalConstants.WITHDRAWN_CASE_SUB_STATUS;
                status =  ASPApplicationListController.withdrawASPApplication(caseRec);
            //}
            test.stopTest();
            
            updatedCase =[SELECT Id, Status FROM Case WHERE Status =: GlobalConstants.CLOSED_CASE_STATUS LIMIT 1]; 
            //system.assertEquals(GlobalConstants.SUCCESS_MESSAGE_TO_BE_RETURNED, status);
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPApplicationListControllerTest','withdrawASPApplicationTest',ex.getMessage(),ex);  
        }  
    } 
}