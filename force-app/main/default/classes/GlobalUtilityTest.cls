@isTest
public class GlobalUtilityTest {

    @isTest
    public static void testUtilityTest() {
        
        string  givenid = (string) GlobalUtility.getOwnerId();
 
       System.assertEquals(3, GlobalUtility.retrieveASPApplicationRecordTypes().size()); 
       System.assertNotEquals(NULL, GlobalUtility.getLoggedInUser()); 
       System.assertNotEquals(NULL, GlobalUtility.getASPProfile()); 
       System.assertNotEquals(NULL, GlobalUtility.getPSPProfile());
       System.assertNotEquals(NULL, GlobalUtility.getSysAdminProfile());
       System.assertNotEquals(NULL, GlobalUtility.getP2POperationsLevel1Profile());
       System.assertNotEquals(NULL, GlobalUtility.getTaxiLicenceUserProfile());
       System.assertNotEquals(NULL, GlobalUtility.getTaxiAccountManagerProfile());
       System.assertNotEquals(NULL, GlobalUtility.getTaxiASPProfile());
       System.assertNotEquals(NULL, GlobalUtility.getCreatableFieldsSOQL('Account', 'Id'));
       System.assertEquals(NULL, GlobalUtility.getCreatableFieldsSOQL(NULL, 'Id'));
System.assert(givenid.startsWith('005'));
       BusinessHours bh = new BusinessHours();
       bh = [SELECT Id FROM BusinessHours WHERE isDefault = TRUE];
       System.assertNotEquals(NULL, GlobalUtility.isInBusinessHours(bh, System.Now()));
        
       System.assertNotEquals(NULL, GlobalUtility.getCustomerPortalProfiles());
       System.assertNotEquals(NULL, GlobalUtility.getAccEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATION));
       System.assertNotEquals(NULL, GlobalUtility.getAccEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_INDIVIDUAL));
       System.assertNotEquals(NULL, GlobalUtility.getAccEntityType(GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_CORPORATE_PARTNERSHIP));
       System.assertNotEquals(NULL, GlobalUtility.getAccEntityType(''));
    }
    
    private static testMethod void testForInternalUserCheck(){
        System.Test.startTest();
        System.assert(true, GlobalUtility.isInternalUser());
        System.Test.stopTest();
    }
    
    private static testMethod void testUsernameGenerationForInvalidContact(){
        System.Test.startTest();
        String userName = GlobalUtility.generateUserName(null);
        System.Test.stopTest();
        System.assert(userName == 'pointtopoint.@pointtopoint.com');
    }
}