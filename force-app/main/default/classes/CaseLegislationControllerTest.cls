@isTest
public class CaseLegislationControllerTest {
    @testSetup static void setup() {
        String IndividualRecordTypeLabel = GlobalConstants.ACCOUNT_ENTITY_TYPE_INDIVIDUAL;
        Id IndividualAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(IndividualRecordTypeLabel).getRecordTypeId();
        Account acc = new Account(Name='Test Account',RecordTypeId=IndividualAccRecordTypeId);
        insert acc;
        
        String ActiveStatus = GlobalConstants.ACTIVE_CONTACT_STATUS;
        Contact con = new Contact(FirstName='Test',LastName='Contact',Status__c = ActiveStatus,Email='testuser@nomail.com',AccountId=acc.Id);
        insert con;
        
        Id InspectionCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId=InspectionCaseRecordTypeId,Status='New',Subject='Test Case Subject',Description='Test Case Description',
                               AccountId = acc.Id,ContactId=con.Id);
        insert caseRec;
        
        Legislation__c leg = new Legislation__c(Legislation_Name__c='Test Legislation 1', Description__c='Test Legislation Description 1',
                                                Legislation_Type__c='Act',Status__c='Active', Schedule_Section_Clause_Rule__c='123', Sub_Section_Clause__c='123A');
        insert leg;
        
        Case_Legislative_Reference__c caseLegRef = new Case_Legislative_Reference__c(Legislation__c=leg.Id,Case__c=caseRec.Id,Status__c='Active');
        insert caseLegRef;
        
        
    }
    
    @isTest
    private static void testMethod1(){
        Case_Legislative_Reference__c caseLegRef1 = [SELECT Id, Name, Case__c, Legislation__c, Primary__c, Comment__c, Status__c, 
                                                     Case_Status__c, Reason_for_Change__c FROM Case_Legislative_Reference__c];
        System.debug('caseLegRef1:'+caseLegRef1.Case__c);
        
        Test.startTest();
        
        List<Case_Legislative_Reference__c> caseLegRef = CaseLegislationController.loadCaseLegislation(caseLegRef1.Case__c);
        
        System.debug('caseLegRef:'+caseLegRef);
        
        System.assertEquals(caseLegRef1.Id, caseLegRef[0].Id);
        
        List<String> ReasonForChange = CaseLegislationController.getPickListValuesIntoList();
        System.debug('ReasonForChange:'+ReasonForChange);
        
        caseLegRef[0].Reason_for_Change__c = ReasonForChange[0];
        
        List<Case_Legislative_Reference__c> caseLegRefList = new List<Case_Legislative_Reference__c>();
        caseLegRefList.add(caseLegRef[0]);
        
        String caseLegRefString = JSON.serialize(caseLegRefList);
        System.debug('caseLegRefString:'+caseLegRefString);
        
        CaseLegislationController.saveCaseLegislation(caseLegRefString);
        
        caseLegRef1 = [SELECT Id, Name, Case__c, Legislation__c, Primary__c, Comment__c, Status__c, 
                       Case_Status__c, Reason_for_Change__c FROM Case_Legislative_Reference__c WHERE Id=:caseLegRef1.Id];
        
        System.assertEquals(caseLegRef1.Reason_for_Change__c, ReasonForChange[0]);
        Test.stopTest();
    }
    
    @isTest
    private static void testMethod2(){
        Case_Legislative_Reference__c caseLegRef1 = [SELECT Id, Name, Case__c, Legislation__c, Primary__c, Comment__c, Status__c, 
                                                     Case_Status__c, Reason_for_Change__c FROM Case_Legislative_Reference__c];
        System.debug('caseLegRef1:'+caseLegRef1.Case__c);
        
        Test.startTest();
        
        List<Case_Legislative_Reference__c> caseLegRef = CaseLegislationController.loadCaseLegislation(caseLegRef1.Case__c);
        
        System.debug('caseLegRef:'+caseLegRef);
        
        System.assertEquals(caseLegRef1.Id, caseLegRef[0].Id);
        
        List<String> ReasonForChange = CaseLegislationController.getPickListValuesIntoList();
        System.debug('ReasonForChange:'+ReasonForChange);
        
        caseLegRef[0].Reason_for_Change__c = ReasonForChange[0];
        
        List<Case_Legislative_Reference__c> caseLegRefList = new List<Case_Legislative_Reference__c>();
        caseLegRefList.add(caseLegRef[0]);
        
        String caseLegRefString = JSON.serialize(caseLegRefList);
        System.debug('caseLegRefString:'+caseLegRefString);
        
        CaseLegislationController.saveCaseLegislation(caseLegRefString);
        
        caseLegRef1 = [SELECT Id, Name, Case__c, Legislation__c, Primary__c, Comment__c, Status__c, 
                       Case_Status__c, Reason_for_Change__c FROM Case_Legislative_Reference__c WHERE Id=:caseLegRef1.Id];
        
        System.assertEquals(caseLegRef1.Reason_for_Change__c, ReasonForChange[0]);
        caseLegRef1.Status__c = 'Inactive' ;
        
        List<Case_Legislative_Reference__c> caseLegRefListUpdated = new List<Case_Legislative_Reference__c>();
        caseLegRefListUpdated.add(caseLegRef1);
        String caseLegRefStringUpdated = JSON.serialize(caseLegRefListUpdated);
        
        CaseLegislationController.saveCaseLegislation(caseLegRefStringUpdated);
        
        caseLegRef1 = [SELECT Id, Name, Case__c, Legislation__c, Primary__c, Comment__c, Status__c, 
                       Case_Status__c, Reason_for_Change__c FROM Case_Legislative_Reference__c WHERE Id=:caseLegRef1.Id];
        
        System.assertEquals(caseLegRef1.Status__c, 'Inactive');
        Test.stopTest();
    }
    
    @isTest
    private static void testValdiateIfRelatedNoticeSent(){
        Case_Legislative_Reference__c caseLegRef1 = [SELECT Id FROM Case_Legislative_Reference__c limit 1];
        Test.startTest();
        CaseLegislationController.valdiateIfRelatedNoticeSent(caseLegRef1.Id);
        Test.stopTest();
    }
    
}