/*-----------------------------------------------------------------------------------------
Author:        Akshay Badgujar
Company:       Arxxus
Description:   Test Class for RunsheetController 
Test Class:    ASPNotifiableReopenCase

History
07-02-2018     Akshay Badgujar        Initial Release
-------------------------------------------------------------------------------------------*/

@isTest
public class ASPNotifiableReopenCaseTest {
    
    @isTest
    static void getCaseTest(){
        
        Test.startTest(); 
        Id ownerid = GlobalUtility.getOwnerId();
        Id caseNotifiableOccurrenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_LABEL_NOTIFIABLE_OCCURRENCE).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        
        Case cas = new Case(AccountId=ac.id,RecordtypeId=caseNotifiableOccurrenceRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',State__c='NSW',Street_Address_Line_1__c='Castlereagh Street',A__c=true,Full_Occurrence_description__c='Test',Description_of_cause_contributing_factor__c='Test',Description_of_follow_up_action__c='Test');
        insert cas;
        
        Legislation__c leg = new Legislation__c(Legislation_Name__c='Test Legislation 1', Description__c='Test Legislation Description 1',
                                                Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='123', Sub_Section_Clause__c='123A');
        insert leg;
        
        Case_Legislative_Reference__c caseLegRef = new Case_Legislative_Reference__c(Legislation__c=leg.Id,Case__c=cas.Id,Status__c='Active',Primary__c=true);
        insert caseLegRef;
        
        cas.Status = 'Closed';
       	update cas;     
        
        string caseId = [SELECT id FROM Case LIMIT 1].id;
        string caseList = ASPNotifiableReopenCase.updateCaseStatus(caseId);
        Test.stopTest();
    }
}