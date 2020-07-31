@isTest
public class RelatedContactToAccountContactTest {
    
    @testSetup 
    static void createASPUserAndAccount(){
        
        Id rtIdForCorporation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'Castlereagh', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name',RecordTypeId = rtIdForCorporation);
        insert ac;
        
        Contact con = new Contact(Title='Mr.',LastName ='testCon',AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name');
        insert con;
        
        Case newASPCase = new Case(Title__c = con.Title, Family_name__c = con.LastName, First_given_name__c = con.FirstName, Birthdate__c = con.Birthdate, Email__c = con.Email,
                                   ACN__c = ac.ACN__c, Corporation_name__c = ac.Name, Type = GlobalConstants.SERVICE_PROVIDER_CASE_TYPE, Sub_Type__c = GlobalConstants.CASE_SUBTYPE_NEW_APPLICATION,
                                   Status = GlobalConstants.APPLICATION_STATUS_DRAFT, Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT,
                                   Subject = GlobalConstants.NEW_ASP_APPLICATION_CASE_SUBJECT, AccountId = ac.Id);
        
        insert newASPCase;
        
        Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        
        Related_Contact__c individualContact1 = new Related_Contact__c();
        individualContact1.Title__c = 'Mr.';
        individualContact1.First_Given_Name__c = 'Name 1';
        individualContact1.Other_Given_Name__c = 'Other Given Name 1';
        individualContact1.Australian_Driver_Licence__c = 'BSBBSB1';
        individualContact1.Australian_Driver_Licence_State__c = 'NSW';
        individualContact1.Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE;
        individualContact1.Related_Application__c = newASPCase.Id;
        individualContact1.RecordTypeId =  indivRecordTypeId;
        individualContact1.Applicant_Details__c = false;
        
        insert individualContact1;
        
        Id corpRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.CORPORATE_RECORD_TYPE).getRecordTypeId();
        Related_Contact__c individualContact2 = new Related_Contact__c();
        individualContact2.Corporation_Name__c = 'Corporate Name';
        individualContact2.Family_Name__c = 'Corporate Name';
        individualContact2.ABN__c = '12345678901';
        individualContact2.ACN__c = '123456';
        individualContact2.Contact_Type__c = GlobalConstants.CONTACT_CORPORATE_PARTNERSHIP_TYPE;
        individualContact2.Related_Application__c = newASPCase.Id;
        individualContact2.RecordTypeId =  corpRecordTypeId;
        individualContact2.Applicant_Details__c = false;
        
        insert individualContact2;
        
        Related_Contact__c individualContact3 = new Related_Contact__c();
        individualContact3.Title__c = 'Mr.';
        individualContact3.First_Given_Name__c = 'Name 12';
        individualContact3.Other_Given_Name__c = 'Other Given Name 12';
        individualContact3.Australian_Driver_Licence__c = 'BSBBSB12';
        individualContact3.Australian_Driver_Licence_State__c = 'NSW';
        individualContact3.Contact_Type__c = GlobalConstants.CONTACT_INDIVIDUAL_PARTNERSHIP_TYPE;
        individualContact3.Related_Application__c = newASPCase.Id;
        individualContact3.RecordTypeId =  indivRecordTypeId;
        individualContact3.Applicant_Details__c = false;
        
        insert individualContact3;
        
        Authorisation__c authRec = new Authorisation__c(Application__c = newASPCase.Id, Authorisation_Type__c = 'BSP', Status__c = 'Draft', Service_Provider__c = ac.Id);
        insert authRec;
    }
    
    @isTest
    public static void validateContactAccountCreationTest() {
        
        Authorisation__c oldAuthRec = [SELECT Status__c, Record_Type_Dev_Name__c, Application__c
                                       FROM Authorisation__c];
        
        Map<Id, Authorisation__c> oldMap = new Map<Id, Authorisation__c>();
        oldMap.put(oldAuthRec.Id, oldAuthRec);
        
        Authorisation__c newAuthRec = new Authorisation__c();
        newAuthRec.Id = oldAuthRec.Id;
        newAuthRec.Status__c = GlobalConstants.GRANTED_CONDITIONALLY;
        update newAuthRec;
        
        newAuthRec = [SELECT Status__c, Record_Type_Dev_Name__c, Application__c
                                       FROM Authorisation__c];
        
        Map<Id, Authorisation__c> newMap = new Map<Id, Authorisation__c>();
        newMap.put(newAuthRec.Id, newAuthRec);
        
        Test.startTest();
        RelatedContactToAccountContactConversion tempCon = new RelatedContactToAccountContactConversion(newMap, oldMap);
        tempCon.validateContactAccountCreation();
        Test.stopTest();
    }
}