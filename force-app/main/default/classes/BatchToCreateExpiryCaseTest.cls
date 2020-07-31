@isTest
public class BatchToCreateExpiryCaseTest {
    
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
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Taxi Licence').getRecordTypeId();
        
        List<Authorisation__c> authList = new List<Authorisation__c>();
        Date todayPlusSeven = System.Today()+7;  
        Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today()-20,
                                                        End_Date__c = todayPlusSeven,Licence_Class__c = 'TXA04Wol',Service_Provider__c = accountId, Status__c ='Suspended');

        Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today()-200,
                                                        End_Date__c = todayPlusSeven,Licence_Class__c = 'TXA04Wol',Service_Provider__c = accountId, Status__c ='Suspended');
        
        Authorisation__c authRec3 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today()-200,
                                                        End_Date__c = todayPlusSeven,Licence_Class__c = 'TXA04Wol',Service_Provider__c = accountId, Status__c ='Granted With Conditions');
        
        Authorisation__c authRec4 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today()-200,
                                                        End_Date__c = todayPlusSeven,Licence_Class__c = 'TXA04Wol',Service_Provider__c = accountId, Status__c ='Granted Unconditionally');
        
        Authorisation__c authRec5 = new Authorisation__c(RecordTypeId = rtIdforTaxi,Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE ,Start_Date__c = System.today()-200,
                                                        End_Date__c = todayPlusSeven,Licence_Class__c = 'TX03WAT',Service_Provider__c = accountId, Status__c ='Granted Unconditionally');
        
        authList.add(authRec1);
        authList.add(authRec2);
        authList.add(authRec3);
        authList.add(authRec4);
        authList.add(authRec5);
        insert authList;
        
        test.startTest();
            BatchToCreateExpiryCase obj = new BatchToCreateExpiryCase();
            DataBase.executeBatch(obj);
        test.stopTest();
        
        for(Case  cs : [SELECT Id, Type, Sub_Type__c, Status FROM Case]) {
            System.debug('status: '+cs.Status);
            System.assertEquals('New', cs.Status);   
            System.assertEquals('Taxi', cs.Type);
        }
		List<Case> expiryCaseList = [SELECT Id, Type, Sub_Type__c, Status FROM Case WHERE Sub_Type__c = 'Expiry' ];
        System.assert(expiryCaseList.size() == 4);
        Case expiryRenewalCase = [SELECT Id, Type, Sub_Type__c, Status FROM Case WHERE Sub_Type__c ='Expiry - Renewable'];
        System.assert(expiryRenewalCase != null);
       
    } 

}