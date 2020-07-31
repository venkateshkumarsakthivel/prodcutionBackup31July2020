/*-----------------------------------------------------------------------------------------
Author:        Srikanth Sunkara
Company:       Transport
Description:   Test Class for EscalatetoComp Lightning Component
Test Class:    EscalatetoCompTest

History
17-05-2019     Srikanth Sunkara       Initial Release
-------------------------------------------------------------------------------------------*/

@isTest
public class EscalatetoCompTest {
    
    @isTest
    static void getCaseTest(){
        
        Test.startTest(); 
        Id ownerid = GlobalUtility.getOwnerId();
         string loggedInUserId = UserInfo.getUserId();
        List<Case> caseList = new List<Case>();
        Id caseRegisterLevyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_FAILURE_REGISTER_LEVY).getRecordTypeId();
        Id caseUnauthorisedServiceProviderRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.CASE_RECORDTYPE_UNAUTHORISED_SERVICE_PROVIDER).getRecordTypeId();
        Account ac = new Account(name ='testAcc', BillingStreet='Castlereagh Street', Notice_Email__c= 'Test@test.com', BillingCity='Sydney', BillingState='NSW', BillingPostalCode='2000',OwnerId=ownerid);
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email='test@contest.com');
        insert con;
        Authorisation__c auth = new Authorisation__c(Service_Provider__c = ac.Id, Contact__c = con.Id, Status__c = GlobalConstants.GRANTED_UNCONDITIONALLY, Authorisation_Type__c = GlobalConstants.AUTHORISATION_TYPE_TSP);
        insert auth;
        Case case1 = new Case(AccountId=ac.id,RecordtypeId=caseRegisterLevyRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Status = 'New',State__c='NSW',OwnerId=loggedInUserId);
        Case case2 = new Case(AccountId=ac.id,RecordtypeId=caseRegisterLevyRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Status = 'In Progress',State__c='NSW',OwnerId=loggedInUserId);
        Case case3 = new Case(AccountId=ac.id,RecordtypeId=caseUnauthorisedServiceProviderRecordTypeId,Authorisation__c=auth.Id,ContactId=con.Id,Postcode__c='2000',City__c='Sydney',Status = 'New',State__c='NSW',OwnerId=loggedInUserId);
        
        caseList.add(case1);
        caseList.add(case2);
        caselist.add(case3); 
        
        insert caseList;
        for(case c: caseList){
            
            if(c.RecordTypeId!=caseRegisterLevyRecordTypeId){
                EscalatetoComp.getNewOwnerName('Service_Delivery'); 
                EscalatetoComp.takeOwnership(c.Id, 'Service_Delivery');   
            }
            if(c.status=='New') {
                EscalatetoComp.getNewOwnerName('Compliance'); 
                EscalatetoComp.takeOwnership(c.Id, 'Compliance');    
            }  
            if(c.status=='In Progress') {
                EscalatetoComp.getNewOwnerName('Sanctions_Level_2'); 
                EscalatetoComp.takeOwnership(c.Id, 'Sanctions_Level_2');    
            }
            
            
        }
        //string caseId = [SELECT id FROM Case LIMIT 1].id;
        //string caseList = ASPNotifiableReopenCase.updateCaseStatus(caseId);
        Test.stopTest();
    }
}