// Test class for the class ContactUpdatorforCaseTypeSPA
@isTest
public class ContactUpdatorforCaseTypeSPATest {
    
    //Test setup method to insert Account and contact.
    @testSetup  
    static void TestSetup(){
        try{
            Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
            insert ac;
            Contact con1 = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
            insert con1;  
            Contact con2 = new Contact(LastName ='testContact',AccountId = ac.Id, Email='testcontact@contest.com');
            insert con2;  
        }catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactCreatorforCaseTypeSPATest','TestSetup',ex.getMessage(),ex);
        } 
    }
    
    @isTest
    private static void updateContactTest(){
        try {
            
            Id accountId = [select id from Account where name = 'testAcc' LIMIT 1].id; 
            Id con1Id = [select id from contact where AccountId =:accountId AND Email='test@contest.com' LIMIT 1].id;
            Id con2Id = [select id from contact where AccountId =:accountId AND Email='testcontact@contest.com' LIMIT 1].id;
            Id rtIdforSPA = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.SERVICE_PROVIDER_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            List<Case> caseList = new List<Case>();
            
            Case c1 = new Case(Family_name__c = 'Family Name 1',Birthdate__c= Date.parse('01/01/1985'),Contact_Type__c = 'Nominated Director/Manager',
                               Email__c='Test@test.com',First_given_name__c='First Name 1',Residential_Address_City__c='Test City',
                               Residential_Address_Country__c='Test Country',Residential_Address_State__c='Test state',Residential_Address_Street__c='Test street',
                               Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = accountId, Service_Type__c = 'Taxi', Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                               Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                               Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = rtIdforSPA, Maintain_Request_Type__c = GlobalConstants.CASE_MAINTAIN_REQUEST_EDIT_CONTACT);
            caseList.add(c1);
            
            Case c2 = new Case(Family_name__c = 'Family Name 2',Birthdate__c= Date.parse('01/01/1982'),Contact_Type__c = 'Nominated Director/Manager',
                               Email__c='Test2@test.com',First_given_name__c='First Name 2',Residential_Address_City__c='Test City2',
                               Residential_Address_Country__c='Test2 Country',Residential_Address_State__c='Test2 state',Residential_Address_Street__c='Test2 street',
                               Residential_Address_Postal_Code__c='4554',Access_Level__c ='DVD User',AccountId = accountId, Service_Type__c = 'Taxi', Status = GlobalConstants.CASE_STATUS_REVIEW_PENDING,
                               Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DECISION_PENDING, Type = GlobalConstants.CASE_SERVICE_PROVIDER_TYPE,
                               Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_MAINTAIN_AUTHORISATION,RecordTypeId = rtIdforSPA, Maintain_Request_Type__c = GlobalConstants.CASE_MAINTAIN_REQUEST_EDIT_CONTACT);
            caseList.add(c2);
            
            insert caseList;
            
            Related_Contact__c firstRelCon = new Related_Contact__c(Family_Name__c = 'LName1', Related_Application__c = caseList[0].Id, Residential_Address_Street__c = 'co rep',
                                                                   Residential_Address_Postcode__c = '1234', Email__c = 'ss8lye1@gmail.com', Is_Access_Level_DVD_Administrator__c = true,
                                                                   Is_Access_Level_Account_Administrator__c = true, Have_been_known_by_other_names__c = false, Related_Contact__c = con1Id );
            

            Related_Contact__c secondRelCon = new Related_Contact__c(Family_Name__c = 'LName2', Related_Application__c = caseList[1].Id, Residential_Address_Street__c = 'co rep',
                                                                   Residential_Address_Postcode__c = '1234', Email__c = 'ss8lye2@gmail.com', Is_Access_Level_DVD_Administrator__c = true,
                                                                   Is_Access_Level_Account_Administrator__c = true, Have_been_known_by_other_names__c = false, Related_Contact__c = con2Id );
            insert firstRelCon;
            insert secondRelCon;            

            List<Case> casesToUpdate = new List<Case>(); 
            for(Case c : [SELECT Id From Case]) {
            
                c.Status=GlobalConstants.CLOSED_CASE_STATUS;
                c.Sub_Status__c=GlobalConstants.CASE_APPROVED;
                casesToUpdate.add(c);
            } 
            update casesToUpdate;  
            
            caseList = [SELECT Id, Status, Sub_Status__c, Maintain_Request_Type__c, Type, Sub_Type__c, Record_Type_Dev_Name__c FROM CASE];
            
            test.startTest();
              ContactUpdatorforCaseTypeSPA contactUpdatorforCaseTypeSPA = new ContactUpdatorforCaseTypeSPA(caseList);
            test.stopTest();
            
            Contact firstContact = [SELECT Id, Email FROM Contact WHERE Id = :con1Id];
            Contact secondContact = [SELECT Id, Email FROM Contact WHERE Id = :con2Id];
            System.assertEquals(firstContact.Email, 'ss8lye1@gmail.com');
            System.assertEquals(secondContact.Email, 'ss8lye2@gmail.com');
        }
        Catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ContactUpdatorforCaseTypeSPATest','updateContactTest',ex.getMessage(),ex);
        }
    }   
}