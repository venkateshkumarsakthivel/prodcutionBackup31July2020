@isTest
public class ASPNotifiableFormAuthorisationTest {
    
    @testSetup 
    static void setup(){
        
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000');
        insert ac;
        
        Contact con = new Contact(FirstName = 'Test', LastName ='testCon',AccountId = ac.Id, Email='test@contest.com',Role__c = 'Director', MailingCity = 'NSW',Phone = '0211111111');
        insert con;
        
        Authorisation__c authorisation = new Authorisation__c(Service_Provider__c = ac.Id, Authorisation_Name__c = 'Authorisation for Order',Contact__c = con.Id);
        insert authorisation;
        
        System.debug('Authorisation -->' + authorisation);
        System.debug('Contact -->' + con);
        System.debug('Account -->' + ac);
        
    }
    
@isTest
    static void getCaseDetailsTest(){
        
        Test.startTest(); 
        Id ownerid = GlobalUtility.getOwnerId();
        Id caseNotifiableOccurrenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_LABEL_NOTIFIABLE_OCCURRENCE).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Case cas = new Case(AccountId=ac.id,RecordtypeId=caseNotifiableOccurrenceRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Status = 'New',State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas;
        string caseId = [SELECT id FROM Case LIMIT 1].id;
        string caseList = ASPNotifiableFormAuthorisation.getCaseDetails(caseId);
        Test.stopTest();
    }
    
    @isTest
    private static void getAuthorisationTest(){
        
        Authorisation__c getAuth = [Select Id, Name, Service_Provider__r.Name,Contact__r.Id, Contact__r.Name, Contact__r.Role__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.State__c, Contact__r.Phone  FROM Authorisation__c];
        Account authAccount = [Select Name,Id from Account];
        Contact getContact = [Select Id, FirstName, LastName, Role__c, Email, Phone FROM Contact];
        
        System.debug('Auth :'+getAuth);
        System.debug('Contact :'+getContact);
        System.debug('Account :'+authAccount);
        
        String getAuth1 =ASPNotifiableFormAuthorisation.getAuthorisation(getAuth.Id);
        System.debug('auth>>'+getAuth1);
        Authorisation__c getAuth2 = (Authorisation__c) JSON.deserialize(getAuth1,Authorisation__c.class);
        System.debug('auth  >>'+getAuth2.Service_Provider__r.Name);
        
        // System.assertEquals(expected, actual);
        System.assertEquals(authAccount.Name,getAuth2.Service_Provider__r.Name);
        System.assertEquals(getContact.Id, getAuth2.Contact__c);
        System.assertEquals(getContact.FirstName, getAuth2.Contact__r.FirstName);
        System.assertEquals(getContact.LastName, getAuth2.Contact__r.LastName);
        System.assertEquals(getContact.Phone,getAuth2.Contact__r.Phone);
        System.assertEquals(getContact.Email,getAuth2.Contact__r.Email);
        System.assertEquals(getContact.Role__c,getAuth2.Contact__r.Role__c);
    }
    
    @isTest
    private static void createNotifiableOccurenceCaseTest(){
        
        Authorisation__c getAuth = [Select Id, Name, Service_Provider__r.Name,Contact__r.Id, Contact__r.Name, Contact__r.Role__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.State__c, Contact__r.Phone  FROM Authorisation__c];
        Account authAccount = [Select Name,Id from Account];
        Contact getContact = [Select Id,Name, FirstName, LastName, Role__c, Email, Phone FROM Contact];
        
        String occurenceDesc1 = 'Test Occurence Description';
        String contFact1 = 'Test Controlling factors';
        String followDesc1 = 'Test follow up Description';
        
        String state = 'state';
        String city = 'city';
        String postcode = '1234';
        String street = 'street';
        
        Boolean checkboxA = true;
        Boolean checkboxB =false;
        Boolean checkboxC = true;
        Boolean checkboxD = false;
        Boolean checkboxE = true;
        
        Datetime myDateTime = datetime.now();
        System.debug('rawDate -->'+myDateTime);
        
        ASPNotifiableCaseAttributes attributes = new ASPNotifiableCaseAttributes();
        attributes.a = checkboxA;
        attributes.b = checkboxB;			
        attributes.c = checkboxC;
        attributes.d = checkboxD;
        attributes.e = checkboxE;
        attributes.accId = authAccount.Id;
        attributes.accountName = authAccount.Name;
        attributes.authId = getAuth.Id;
        attributes.cityadd = city;
        attributes.contactId = getContact.Id;
        attributes.contactName = getContact.Name;
        attributes.contFact = contFact1;
        attributes.followDesc = followDesc1;
        attributes.no_date = myDateTime;
        attributes.occurenceDesc = occurenceDesc1;
        attributes.postCodeadd = postcode;
        attributes.stateadd = state;
        attributes.streetadd = street;
        
        String no_data = JSON.serializePretty(attributes);
        System.debug('JSON-->'+no_data);
        
        String getNoCase =ASPNotifiableFormAuthorisation.createNotifiableOccurenceCase(no_data);
        
        Case getdeserializeCase = (Case) JSON.deserialize(getNoCase,Case.class);
        
        System.AssertEquals(getAuth.Id, getdeserializeCase.Authorisation__c);
        System.AssertEquals(authAccount.Id, getdeserializeCase.AccountId);
        System.AssertEquals(getContact.Id, getdeserializeCase.ContactId);
        System.AssertEquals(postcode, getdeserializeCase.Postcode__c);
        System.AssertEquals(city, getdeserializeCase.City__c);
        System.assertEquals(street, getdeserializeCase.Street_Address_Line_1__c);
        System.assertEquals(state, getdeserializeCase.State__c);
        System.assertEquals(checkboxA, getdeserializeCase.A__c);
        System.assertEquals(checkboxB, getdeserializeCase.B__c);
        System.assertEquals(checkboxC, getdeserializeCase.C__c);
        System.assertEquals(checkboxD, getdeserializeCase.D__c);
        System.assertEquals(checkboxE, getdeserializeCase.E__c);
        System.assertEquals(myDateTime,getdeserializeCase.Commencement_Date_Time__c);
      }
}