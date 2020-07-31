@isTest
private class ChangePageLayoutToDefaultTest {
    @testSetup 
    static void setup(){
         Id ownerid = GlobalUtility.getOwnerId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
    }
    
    //this test verifies account name of current ASP user running
    @isTest
    private static void testGetAccount(){
        Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        Id p = [select id from profile where name='Authorised Service Provider'].id;
        Id rtIdforTaxi = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE).getRecordTypeId();
        Id rtIdforDefault = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get(GlobalConstants.AUTHORISATION_RECORDTYPE_DEFAULT).getRecordTypeId();
        
        List<Id> authIdList = new List<Id>();
        List<Authorisation__c> authList = new List<Authorisation__c>();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             contactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
            Id ownerid = GlobalUtility.getOwnerId();
        Account acc1 = new Account(name ='testAcc11', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid) ;
        insert acc1;
        
        Authorisation__c authRec1 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                         End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = acc1.Id, Status__c ='Granted');
        authList.add(authRec1);
        
        Authorisation__c authRec2 = new Authorisation__c(RecordTypeId = rtIdforTaxi, Authorisation_Type__c = 'BSP',Start_Date__c = System.today(),
                                                         End_Date__c = System.today()+20,Licence_Class__c = 'Gold',Service_Provider__c = acc1.Id, Status__c ='Granted');        
        authList.add(authRec2);
        
        insert authList;
        
        authIdList.add(authRec1.Id);
        authIdList.add(authRec2.Id);
        system.runAs(user){
            ChangePageLayoutToDefault.ChangeTypeTodefault(authIdList);    
            for(Authorisation__c auth : [SELECT RecordTypeId FROM Authorisation__c]){
            system.assertEquals(rtIdforDefault, auth.RecordTypeId);
        }
        }
        
        
    }
}