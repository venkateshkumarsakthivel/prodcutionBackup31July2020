// This class is used as RevokeAgreementCaseApprovalProcessor's test class.

@isTest
public class RevokeAgreementCaseApprovalProcessorTest {
    
    @testSetup 
    static void setup(){
        
        Id ownerid = GlobalUtility.getOwnerId();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_AGENT_REGISTRATION_RECORD_TYPE).getRecordTypeId();
        Id indivRecordTypeId = Schema.SObjectType.Related_Contact__c.getRecordTypeInfosByName().get(GlobalConstants.INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Account ac1 = new Account(name ='testAcc1', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test1.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac1;
        
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Contact con1 = new Contact(LastName ='testCon1',AccountId = ac1.Id, Email='test@contest1.com');
        insert con1;
        
        Authorisation__c auth = new Authorisation__c(Name = 'TLH-1111', Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Authorisation__c auth1 = new Authorisation__c(Name = 'TLH-2222', Service_Provider__c = ac1.Id, Contact__c = con1.Id, Status__c = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth1;
        
        Case cas = new Case(AccountId=ac.id,RecordtypeId=caseRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Sub_Type__c = GlobalConstants.REVOKE_AGREEMENT_CASE_SUB_TYPE,Sub_Status__c = GlobalConstants.DECLINED_CASE_SUB_STATUS,Status=GlobalConstants.CLOSED_CASE_STATUS,State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas; 
        
        Related_Contact__c relatedContact = new Related_Contact__c(Taxi_Licence__c = auth.Name, Plate_Number__c = '22222', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId = indivRecordTypeId, Related_Application__c = cas.Id);
        insert relatedContact;
        Related_Contact__c relatedContact2 = new Related_Contact__c(Taxi_Licence__c = auth1.Name, Plate_Number__c = '33333', Contact_Type__c = GlobalConstants.CONTACT_NOMINATED_DIRECTOR_TYPE, RecordTypeId = indivRecordTypeId, Related_Application__c = cas.Id);
        insert relatedContact2;
        
        Authorisation_Agent__c authAgent = new Authorisation_Agent__c(Authorisation__c= auth.Id, Account__c= ac.Id,Status__c= GlobalConstants.ACTIVE_CONTACT_STATUS,Approved_Date__c= system.today());
        insert authAgent;
                
    }
    
    @isTest
    static void getCaseTest(){
        Map<Id, Case> newCases = new Map<Id, Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        
        Test.startTest(); 
        Account acn1 = [SELECT Id FROM Account WHERE Name='testAcc1'];
        Contact con = [SELECT Id FROM Contact WHERE LastName='testCon'];
        Contact con1 = [SELECT Id FROM Contact WHERE LastName='testCon1'];
        Authorisation__c auth = [SELECT Id, Name FROM Authorisation__c WHERE Contact__c=: con.Id];
        Authorisation__c auth1 = [SELECT Id, Name FROM Authorisation__c WHERE Contact__c=: con1.Id];
        List<Related_Contact__c> relatedContactList = [SELECT Id FROM Related_Contact__c];
        relatedContactList[0].Taxi_Licence__c = auth.Name;
        relatedContactList[1].Taxi_Licence__c = auth.Name;
        update relatedContactList;
        
        Case caseData = [SELECT Id,RecordtypeId,AccountId,Authorisation__c,ContactId, Sub_Status__c, Sub_Type__c FROM Case];
        oldCases.put(caseData.Id, caseData);
        caseData.AccountId = acn1.Id;
        caseData.ContactId = con1.Id;
        caseData.Authorisation__c = auth1.Id;
        caseData.Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS;
        update caseData;
        
        newCases.put(caseData.Id, caseData);
      
        RevokeAgreementCaseApprovalProcessor a = new RevokeAgreementCaseApprovalProcessor(newCases,oldCases);
        Test.stopTest();
    }
}