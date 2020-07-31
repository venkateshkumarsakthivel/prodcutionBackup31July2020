// this class is used as CancelChangesActionController's test class 
@isTest
public class CancelChangesActionControllerTest {
    //Legislation__c, Section_Clause__c, Law_Part_Description__c, Law_Part_Commencement_Date__c
    @testSetup
    private static void setupTestData() {
        Law_Part_Code__c lawPartCodeRecord = new Law_Part_Code__c();
        lawPartCodeRecord.Name = '11111';
        lawPartCodeRecord.Status__c = 'Approved';
        lawPartCodeRecord.Legislation__c = 'Test';
        lawPartCodeRecord.Section_Clause__c = 'Test';
        lawPartCodeRecord.Law_Part_Description__c = 'Test';
        lawPartCodeRecord.Law_Part_Commencement_Date__c = System.Today();
        
        insert lawPartCodeRecord;
    }
    
    //for fetchLoggedInUserProfile method
    @isTest
    private static void fetchLoggedInUserProfileTest() {
        
        Test.startTest();
        CancelChangesActionController.fetchLoggedInUserProfile();
        Test.stopTest();
    }
    
    //for fetchLoggedInUserProfile method
    @isTest
    private static void fetchLoggedInUserProfileTest2() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = : GlobalConstants.P2P_OPERATIONS_LEVEL_3];
        
        User user = new User(alias = 'test1234', email='test1234@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                             localesidkey='en_AU', profileid = p.Id, country='Australia', IsActive =true,
                             timezonesidkey='Australia/Sydney', username='tester24@noemail.com');
        
        insert user;
        
        PermissionSet ps = [SELECT ID FROM PermissionSet WHERE Name =: GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(user) {
            CancelChangesActionController.fetchLoggedInUserProfile();
        }
        Test.stopTest();
    }
    
    //for cancelChangesAction method
    @isTest
    private static void cancelChangesActionTest() {
        String lawPartCodeId = [SELECT Id FROM Law_Part_Code__c LIMIT 1].Id;
        
        Test.startTest();
        CancelChangesActionController.cancelChangesAction(lawPartCodeId);
        Test.stopTest();
    }
    
    //for cancelChangesAction method
    @isTest
    private static void cancelChangesActionTest2() {
        Law_Part_Code__c lawPartCodeRecord = [SELECT Id, Status__c, Old_Status__c, Unapproved_P2P_Regulation_Sub_clause__c FROM Law_Part_Code__c LIMIT 1];
        lawPartCodeRecord.Status__c = 'Unapproved';
        lawPartCodeRecord.Unapproved_P2P_Regulation_Sub_clause__c = 'Test';
        update lawPartCodeRecord;
        
        Test.startTest();
        CancelChangesActionController.cancelChangesAction(lawPartCodeRecord.Id);
        Test.stopTest();
    }

}