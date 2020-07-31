// This class is used as BulkUploadLawPartCodeController's test class.

@isTest
public class BulkUploadLawPartCodeControllerTest {
    @isTest
    private static void addLawPartCodesFromCSVTest(){
        String fileContent = 'Legislation,Section / Clause,Law Part Code,Law Part Description,Valid From Date,Valid To Date\r\nTest Legislation,29(3),10001,Test Description,09-01-2015,10-05-2015\r\nTest Legislation,10002,Test Description,09-01-2015,19-05-2016';
        String headerContent = 'Legislation,Section / Clause,Law Part Code,Law Part Description,Valid From Date,Valid To Date';
        Id p = [SELECT ID From Profile WHERE Name =: GlobalConstants.P2P_OPERATIONS_LEVEL_3].Id;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET];
        
        User user = new User(alias = 'lpcTest', email='test12345@noemail.com',
                             emailencodingkey='UTF-8', lastname='LPCTesting', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States', IsActive =true,
                             timezonesidkey='America/Los_Angeles', username='testerLPC@noemail.com');
        insert user;
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id );
        
        test.startTest();
        System.runAs(user){
            String result = BulkUploadLawPartCodeController.addLawPartCodesFromCSV(fileContent,headerContent);
            System.assertNotEquals(result,'');
        }
        test.stopTest();
    }
}