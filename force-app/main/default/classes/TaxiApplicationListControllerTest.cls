@isTest
private class TaxiApplicationListControllerTest {
    @testSetup 
    static void testSetup(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con;
            
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationControllerTest','testSetup',ex.getMessage(),ex);
        }  
    }
    
    @isTest
    private static void retrieveApplicationsTest(){
        try{
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
        Id conId = [select id from contact where AccountId =:accountId LIMIT 1].id;
        
        Id p = GlobalUtility.getASPProfile().id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             ContactId = conId,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        insert user;
        
        List<Case> listCases = new List<Case>();
        Id rtIdforIndividual = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_INDIVIDUAL_APPLICATION).getRecordTypeId();
        Id rtIdforCorporation = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_CORPORATION_APPLICATION).getRecordTypeId();
        Test.startTest();
        System.runAs(user) {
            List<Case> caseList = new List<Case>();
            for(Integer i = 0; i < 5; i++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforCorporation);
                caseList.add(c);
            }
            for(Integer j = 0; j < 5; j++){
                Case c = new Case(AccountId = user.AccountId, Service_Type__c = 'Taxi', Status = 'New' , RecordTypeId = rtIdforIndividual);
                caseList.add(c);
            }
            insert caseList;
            listCases = TaxiApplicationListController.retrieveApplications();
        }
        Test.stopTest();
        System.assertEquals(10, listCases.size());
            
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'VaryAuthorisationControllerTest','retrieveApplicationsTest',ex.getMessage(),ex);
        }   
        
    }
    
    
}