@isTest
public class InitiateCancelSuspendAuthorisationTest {
    @testSetup 
    static void testSetup(){
        Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc',Notice_Email__c = 'test@sample.com', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    // test for getLoggedInUserAccount
    @isTest
    private static void submitSuspendCancelCaseRecTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        system.runAs(user){
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Id rtIdforGrantedLicences = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Granted Authorisation').getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Cancel');
            
            Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                             End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            
            Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = rtIdforGrantedLicences, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                             End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Granted');
            
            Authorisation__c authRec3 = new Authorisation__c(RecordTypeId = rtIdforGrantedLicences, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                             End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Cancel');
            
            AuthList.add(authRec);
            AuthList.add(authRec1);
            AuthList.add(authRec2);
            AuthList.add(authRec3);
            
            insert AuthList;
            String s = InitiateCancelSuspendAuthorisation.submitSuspendCancelCaseRec(authRec.Id, authRec.Status__c, 'Sample Decision Reason');
            String s1 = InitiateCancelSuspendAuthorisation.submitSuspendCancelCaseRec(authRec1.Id, authRec1.Status__c, 'Sample Decision Reason');
            String s2 = InitiateCancelSuspendAuthorisation.submitSuspendCancelCaseRec(authRec2.Id, authRec2.Status__c, 'Sample Decision Reason');
            String s3 = InitiateCancelSuspendAuthorisation.submitSuspendCancelCaseRec(authRec3.Id, authRec3.Status__c, 'Sample Decision Reason');
            
            system.assert(s!=null);
            system.assert(s1!=null);
            system.assert(s2!=null);
            system.assert(s3!=null);
        }
        test.stopTest();
    }
    
    
    // test for getLoggedInUserAccount
    @isTest
    private static void validateAuthorisationRecordTest(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getTaxiLicenceUserProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        test.startTest();
        system.runAs(user){
            List<Authorisation__c> AuthList = new List<Authorisation__c>();
            Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
            
            Authorisation__c authRec = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                            End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c ='Cancel');
            
            Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today(),
                                                             End_Date__c = System.today()+20,Licence_Class__c = 'TX08',Service_Provider__c = accountId, Status__c =GlobalConstants.GRANTED_CONDITIONALLY);
            
            AuthList.add(authRec);
            AuthList.add(authRec1);
            
            insert AuthList;
            String s = InitiateCancelSuspendAuthorisation.validateAuthorisationRecord(authRec.Id);
            String s1 = InitiateCancelSuspendAuthorisation.validateAuthorisationRecord(authRec1.Id);
            
            system.assert(s == 'ERROR');
            system.assert(s1 == 'SUCCESS');
        }
        test.stopTest();
    }
}