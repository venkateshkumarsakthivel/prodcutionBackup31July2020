@isTest
public class BatchForAuthExpirationTest {
    
    @testSetup 
    static void setup(){
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    @isTest
    private static void getLoggedInUserAccountTest() {
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        String TAXI_LICENCE_AUTHORISATION_DEV_NAME = 'Taxi License Administration';
        List<Authorisation__c> ListAuths = new List<Authorisation__c>();
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Granted Authorisation').getRecordTypeId();
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
        
        Date today = System.Today(); 
        
        Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'TSP', Start_Date__c = System.today()-20,
                                                        End_Date__c = today, Service_Provider__c = accountId, Status__c ='Granted');

        Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'TSP', Start_Date__c = System.today()-200,
                                                        End_Date__c = today, Service_Provider__c = accountId, Status__c ='Granted');
        
        Authorisation__c authRec3 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP', Start_Date__c = System.today()-200,
                                                        End_Date__c = today, Service_Provider__c = accountId, Status__c ='Granted');
        
        Authorisation__c authRec4 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP', Start_Date__c = System.today()-200,
                                                        End_Date__c = today, Service_Provider__c = accountId, Status__c ='Granted');
        
        authList.add(authRec1);
        authList.add(authRec2);
        authList.add(authRec3);
        authList.add(authRec4);
        insert authList;
        
        test.startTest();
            BatchForAuthExpiration obj = new BatchForAuthExpiration();
            DataBase.executeBatch(obj);
        test.stopTest();
        
        for(Authorisation__c  auth : [Select Id, Status__c From Authorisation__c]) {
            System.debug('status: '+auth.Status__c);
            System.assertEquals('Lapsed', auth.Status__c);    
        }
        for(Case cs : [SELECT Id, Status, Type, Sub_Type__c FROM Case]){
            System.assertEquals('Lodged', cs.Status);  
            System.assertEquals('Service Provider', cs.Type);  
            System.assertEquals('Expiry', cs.Sub_Type__c);  
        }
       
    }    
}