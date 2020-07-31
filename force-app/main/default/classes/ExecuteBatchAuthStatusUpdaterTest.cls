@isTest 
private class ExecuteBatchAuthStatusUpdaterTest {
    public class BaseException extends Exception {}
    @testSetup 
    static void ExecuteBatchAuthStatusUpdaterTest(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ExecuteBatchAuthStatusUpdaterTest','ExecuteBatchAuthStatusUpdaterTest',ex.getMessage(),ex);
        }   
    }
    
    @isTest
    private static void executeTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
            Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
            
            List<Authorisation__c> authList = new List<Authorisation__c> ();
            List<Case> casesToBeInsert = new List<Case>();
            for(Integer i=0;i<10;i++){
                Case Caserec1 = new Case();
                Caserec1.AccountId = accountId;
                Caserec1.ContactId = conId;
                Caserec1.Service_Type__c = GlobalConstants.SERVICE_TYPE_BOOKING;
                Caserec1.Status = 'Cancelled';
                Caserec1.Sub_Status__c ='Withdrawn';
                Caserec1.RecordTypeId = rtIdforIndividual;
                casesToBeInsert.add(CaseRec1);
            }
             insert casesToBeInsert;
            
             for(Integer i=0;i<10;i++){
                Authorisation__c auth = new Authorisation__c();
                auth.Application__c = casesToBeInsert[i].Id;
                auth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
                auth.Service_Provider__c = accountId;
                authList.add(auth);
            }
           
            insert authList;
            
            Test.startTest();
                ExecuteBatchAuthorisationStatusUpdater batch = new ExecuteBatchAuthorisationStatusUpdater();
                Database.executeBatch(batch);
            Test.stopTest();
            
            List<Authorisation__c> authListAfterUpdate = new List<Authorisation__c> ();
            authListAfterUpdate = [SELECT Id FROM Authorisation__c];
            System.assertEquals(10, authListAfterUpdate.size());
        }catch(Exception ex){
            system.debug('Exception: '+ex.getMessage());
            system.debug('Exception: '+ex.getLineNumber());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ExecuteBatchAuthStatusUpdaterTest','executeTest',ex.getMessage(),ex);
            
        }
    }
}