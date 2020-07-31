// Test class for the class ContactCreatorforCaseTypeSPA
@isTest
public class ContactCreatorforCaseTypeSPATest {
    
    //Test setup method to insert Account and contact.
    @testSetup  
    static void TestSetup(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPATest','TestSetup',ex.getMessage(),ex);
        } 
    }
    
    //Actual testMethod to cover code in class.
    @isTest
    private static void createContactTest(){
        try {
            
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id rtIdforSPA = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            List<Case> caseList = new List<Case>();
            
            Case c1 = new Case(Family_name__c = 'Family Name 1',Birthdate__c= Date.parse('01/01/1985'),Contact_Type__c = 'Nominated Director/Manager',
                               Email__c='Test@test.com',First_given_name__c='First Name 1',Residential_Address_City__c='Test City',
                               Residential_Address_Country__c='Test Country',Residential_Address_State__c='Test state',Residential_Address_Street__c='Test street',
                               Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = accountId, Service_Type__c = 'Taxi', Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                               Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                               Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = rtIdforSPA, Maintain_Request_Type__c = GlobalConstants.ADD_CONTACT_CASE_SUB_STATUS);
            caseList.add(c1);
            
            Case c2 = new Case(Family_name__c = 'Family Name 2',Birthdate__c= Date.parse('01/01/1982'),Contact_Type__c = 'Nominated Director/Manager',
                               Email__c='Test2@test.com',First_given_name__c='First Name 2',Residential_Address_City__c='Test City2',
                               Residential_Address_Country__c='Test2 Country',Residential_Address_State__c='Test2 state',Residential_Address_Street__c='Test2 street',
                               Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = accountId, Service_Type__c = 'Taxi', Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                               Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                               Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = rtIdforSPA, Maintain_Request_Type__c = GlobalConstants.ADD_CONTACT_CASE_SUB_STATUS);
            caseList.add(c2);
            
            insert caseList;
            
            Related_Contact__c firstRelCon = new Related_Contact__c(Family_Name__c = 'LName1', Related_Application__c = caseList[0].Id, Is_Access_Level_DVD_Administrator__c = true);
            Related_Contact__c secondRelCon = new Related_Contact__c(Family_Name__c = 'LName2', Related_Application__c = caseList[1].Id, Is_Access_Level_Account_Administrator__c = true);
            
            insert firstRelCon;
            insert secondRelCon;
            
            List<Case> casesToUpdate = new List<Case>(); 
            for(Case c : [SELECT Id From Case]) {
                
                c.Status=GlobalConstants.CLOSED_CASE_STATUS;
                c.Sub_Status__c=GlobalConstants.CASE_APPROVED;
                casesToUpdate.add(c);
            } 
            //update casesToUpdate;
            
			List<Case> cases = [SELECT Id, Family_name__c,Birthdate__c,Contact_Type__c,Email__c,First_given_name__c,Residential_Address_City__c,Residential_Address_Country__c,
                                Residential_Address_State__c,Residential_Address_Street__c,Residential_Address_Postal_Code__c,Access_Level__c,AccountId,Service_Type__c,Status,
                                Sub_Status__c,Type,Sub_Type__c,RecordTypeId, Record_Type_Dev_Name__c, Maintain_Request_Type__c FROM Case];
            
            test.startTest();
             	update casesToUpdate;
            test.stopTest();
            
            List<Contact> conList =[SELECT Id, LastName FROM Contact WHERE LastName = 'LName1' OR LastName = 'LName2'];
            System.debug('Contact List Size: '+conList);
            System.assertEquals(2, conList.size());
        }
        Catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPATest','createContactTest',ex.getMessage(),ex);
        }
    }   
    
}