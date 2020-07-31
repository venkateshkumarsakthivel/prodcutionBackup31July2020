/*
 * Test class which covers : 1.SubmitCasesForApproval, 2. CriminalOffenceInvestigationController
 */
@isTest
public class SubmitCasesForApprovalTest {
    
    @testSetup
    private static void setupTestData()
    {
        /* Account ------ */
        Account ac = new Account(ACN__c = '1234567898',ABN__c = '123456789', Name = 'testAcc',  Notice_Email__c = 's@r.com', Notice_Address_City__c = 'Sydney',
                                 Notice_Address_Postal_Code__c = '1234', Notice_Address_Country__c ='Australia', Notice_Address_State__c = 'NSW',
                                 Notice_Address_Street__c = 'castle', BillingCity = 'Sydney', BillingState = 'NSW', BillingCountry = 'Australia', BillingStreet = 'Castlereagh',
                                 BillingPostalCode='1234',ShippingCity = 'Sydney', ShippingState = 'NSW', ShippingCountry = 'Australia', ShippingStreet = 'Castlereagh',
                                 ShippingPostalCode = '1234', Registered_Business_Name__c ='Sample Business Name');
        insert ac;
        
        /* Contact ------ */
        Contact con = new Contact(Title='Mr.',LastName ='testCon', AccountId = ac.Id,Birthdate = Date.parse('01/01/1992'), Email='test@contest.com',FirstName = 'Name',Phone='0211111111');
        insert con;
        
        Id coirecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_Investigation_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        Id corecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_NAME).getRecordTypeId(); 
        
        Case parentCase= new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Correction', Status= 'Lodged', RecordTypeId = coirecordTypeId,Sub_Status__c = 'Review Pending');
        insert parentCase;
        
        Case childCase1 = new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Criminal Charge', 
                                   Status= 'Lodged', RecordTypeId = corecordTypeId,Sub_Status__c = 'Assessment In Progress',ParentId = parentCase.Id);
        insert childCase1;
        
        Case childCase2 = new Case(AccountId = ac.Id,Type = 'Criminal Charge Investigation', Sub_Type__c = 'Criminal Charge', 
                                   Status= 'Lodged', RecordTypeId = corecordTypeId,Sub_Status__c = 'Assessment In Progress',ParentId = parentCase.Id);
        insert childCase2;
    }
    
    
    @isTest 
    private static void submitChildCasesForApprovalTest()
    {
        
        Case parentCase = [SELECT Id FROM Case WHERE Sub_Type__c = 'Correction'];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_2];
        UserRole r  = [SELECT Id FROM UserRole WHERE Name =: GlobalConstants.USER_ROLE_P2P_EXE_DIRECTOR];
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU',profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester28@noemail.com', UserRoleId = r.Id);
        insert user;
        
        User user2 = new User(alias = 'test1235', email='test1235@noemail.com',
                              emailencodingkey='UTF-8', lastname='TestingUser2', languagelocalekey='en_US',
                              localesidkey='en_AU',profileid = p.Id, country='Australia', IsActive =true,
                              timezonesidkey='Australia/Sydney', username='tester32@noemail.com', UserRoleId = r.Id);
        insert user2;
        
        Group sanctionGrp = [SELECT Id, Name, DeveloperName FROM Group where Name = 'Sanctions Staff'];
        
        GroupMember member = new GroupMember();
        member.GroupId = sanctionGrp.id;
        member.UserOrGroupId = user.Id;
        insert member;
        
        Test.startTest();
        
        System.runAs(user) {
            String caseList = SubmitCasesForApproval.submitChildCasesForApproval(parentCase.Id);
            System.assert(caseList != null);
            String caseList2 = SubmitCasesForApproval.submitChildCasesForApproval('abc');
            System.assert(caseList2 == 'No Records');
        }
        System.runAs(user2) {
            String caseList3 = SubmitCasesForApproval.submitChildCasesForApproval(parentCase.Id);
            System.assert(caseList3 == 'No Access');
            
            Boolean isUserHasAccess = CriminalOffenceInvestigationController.checkUserAccess();
            system.assert(isUserHasAccess == false);
        }
        String caseList4 = SubmitCasesForApproval.submitChildCasesForApproval(parentCase.Id);
        System.assert(caseList4 != null);
        
        Boolean isUserHasAccess = CriminalOffenceInvestigationController.checkUserAccess();
        system.assert(isUserHasAccess == true);
        
        Test.stopTest();
    }
}