@isTest
public class AgentRegistrationCaseApprovalProTest {
    
    @testSetup
    private static void setupTestData() {
        
        Id ownerid = GlobalUtility.getOwnerId();
        Id caseNotifiableOccurrenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Account ac1 = new Account(name ='testAcc1', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test1.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac1;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Contact con1 = new Contact(LastName ='testCon1',AccountId = ac1.Id, Email='test@contest1.com');
        insert con1;
        
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Authorisation__c auth1 = new Authorisation__c(Service_Provider__c = ac1.Id, Contact__c = con1.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth1;
        
        Case cas = new Case(AccountId=ac.id,RecordtypeId=caseNotifiableOccurrenceRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Sub_Type__c = GlobalConstants.CASE_SUB_TYPE_AGENT_REGISTRATION,Sub_Status__c = GlobalConstants.WITHDRAWN_CASE_SUB_STATUS,Status=GlobalConstants.CLOSED_CASE_STATUS,State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas;
        
        Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        Related_Contact__c relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '22222', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId = indivRecordTypeId, Related_Application__c = cas.Id);
        insert relatedContact;
        Related_Contact__c relatedContact2 = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '22222', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId = indivRecordTypeId, Related_Application__c = cas.Id);
        insert relatedContact2;
        
    }
    
    @isTest
    static void processApprovedAgentRegistrationCasesTest(){
        Map<Id, Case> newCases = new Map<Id, Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
        Case caseData = [SELECT Id, RecordtypeId, AccountId, Authorisation__c, ContactId, Record_Type_Dev_Name__c, Status, Sub_Status__c, Sub_Type__c FROM Case LIMIT 1];
        Account ac1 = [SELECT Id FROM Account LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact LIMIT 1];
        Authorisation__c auth1 = [SELECT Id FROM Authorisation__c LIMIT 1];
        
        oldCases.put(caseData.Id, caseData);
        caseData.AccountId = ac1.Id;
        caseData.ContactId = con1.Id;
        caseData.Authorisation__c = auth1.Id;
        caseData.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        update caseData;
        newCases.put(caseData.Id, caseData);
        
        Test.startTest(); 
        AgentRegistrationCaseApprovalProcessor a = new AgentRegistrationCaseApprovalProcessor(newCases,oldCases);
        a.processApprovedAgentRegistrationCases();
        Test.stopTest();
    }
    
    @isTest
    static void processApprovedAgentRegistrationCasesTest2(){
        Map<Id, Case> newCases = new Map<Id, Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
        List<Related_Contact__c> relatedContactList = [SELECT Id, ACN__c FROM Related_Contact__c];
        relatedContactList[0].ACN__c = '1234567898';
        relatedContactList[1].ACN__c = '1234567898';
        update relatedContactList;
        
        Case caseData = [SELECT Id, RecordtypeId, AccountId, Authorisation__c, ContactId, Record_Type_Dev_Name__c, Status, Sub_Status__c, Sub_Type__c FROM Case LIMIT 1];
        Account ac1 = [SELECT Id FROM Account LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact LIMIT 1];
        Authorisation__c auth1 = [SELECT Id FROM Authorisation__c LIMIT 1];
        
        oldCases.put(caseData.Id, caseData);
        caseData.AccountId = ac1.Id;
        caseData.ContactId = con1.Id;
        caseData.Authorisation__c = auth1.Id;
        caseData.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        update caseData;
        newCases.put(caseData.Id, caseData);
        
        Test.startTest(); 
        AgentRegistrationCaseApprovalProcessor a = new AgentRegistrationCaseApprovalProcessor(newCases,oldCases);
        a.processApprovedAgentRegistrationCases();
        Test.stopTest();
    }
}