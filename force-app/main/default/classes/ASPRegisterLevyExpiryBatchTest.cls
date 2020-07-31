@isTest

public class ASPRegisterLevyExpiryBatchTest {
    
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
        //Date currentPlus7Days = System.today();
        List<Authorisation__c> ListAuths = new List<Authorisation__c>();
        Boolean IS_REGISTERLEVYCASE = false;
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Granted Authorisation').getRecordTypeId();
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
       Date todayMinusSeven = System.Today()-8;
       Date d = Date.today()-7;
//System.debug( Datetime.newInstance(d.year(), d.month(), d.day()).format('yyy-MM-dd') );
       
        Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'TSP', First_Issued_Date__c = Date.valueOf(Datetime.newInstance(d.year(), d.month(), d.day()).format('yyy-MM-dd')),
                                                         Service_Provider__c = accountId, Status__c ='Granted Unconditionally');

       Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'TSP', First_Issued_Date__c = todayMinusSeven,
                                                       Service_Provider__c = accountId,Status__c ='Granted Unconditionally');
        
        Authorisation__c authRec3 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP', First_Issued_Date__c = todayMinusSeven,
                                                       Service_Provider__c = accountId, Status__c ='Granted Unconditionally');
        
       Authorisation__c authRec4 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP', First_Issued_Date__c = todayMinusSeven,
                                                        Service_Provider__c = accountId, Status__c ='Granted Unconditionally');
        
       authList.add(authRec1);
       authList.add(authRec2);
       authList.add(authRec3);
       authList.add(authRec4);
        insert authList;
        system.debug('AuthList' + authList);
        test.startTest();
        //ASPRegisterLevyExpiryBatch obj = new ASPRegisterLevyExpiryBatch();
        //DataBase.executeBatch(obj);
       
        ASPRegisterLevyExpiryBatch obj1 = New ASPRegisterLevyExpiryBatch();
        Database.QueryLocator ql = obj1.start(null);
       obj1.execute(null,authList);
       obj1.Finish(null);

        test.stopTest();
    
        for(Case cs : [SELECT Id, Status, Type, Sub_Type__c FROM Case]){
            System.assertEquals(GlobalConstants.CASE_NEW, cs.Status);  
            System.assertEquals(GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY, cs.Type);  
            System.assertEquals(GlobalConstants.CASE_SUBTYPE_NON_REGISTRATION, cs.Sub_Type__c);  
        }
       
    }    
}