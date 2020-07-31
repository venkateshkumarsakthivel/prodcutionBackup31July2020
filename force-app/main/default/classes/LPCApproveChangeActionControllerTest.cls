/* Test class for LPCApproveChangeActionController */
@isTest
public class LPCApproveChangeActionControllerTest {
    
    @isTest
    static void getCaseTest(){
        Id p = [SELECT ID From Profile WHERE Name =: GlobalConstants.P2P_OPERATIONS_LEVEL_3].Id;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET];
        
        User user = new User(alias = 'lpcTest', email='test12345@noemail.com',
                             emailencodingkey='UTF-8', lastname='LPCTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testerLPC@noemail.com');
        insert user;
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id );
        
        Test.startTest(); 
        system.runas(user){
            Law_Part_Code__c lpcRecord = new Law_Part_Code__c(Name='10001',Section_Clause__c='Test Section Clause',Unapproved_P2P_Regulation_Sub_clause__c='Test',Unapproved_P2P_Classification__c='Criminal Offence',P2P_Classification__c='Criminal Offence',Unapproved_P2P_Regulatory_End_Date__c= system.today(), Unapproved_Repeal_Date__c=system.today(), Unapproved_Special_Conditions__c='Test Condition',Law_Part_Repeal_Date__c= system.today(), Status__c='Unapproved',Law_Part_Commencement_Date__c=system.today(),Law_Part_Description__c='Test Description',Legislation__c='Test');
            insert lpcRecord;
            string lpcId = [SELECT Id FROM Law_Part_Code__c LIMIT 1].id;
            string lpcList = LPCApproveChangeActionController.updateLawPartCodeStatus(lpcId);
        }
        Test.stopTest();
    }
}