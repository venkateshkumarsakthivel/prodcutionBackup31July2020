public class CriminalOffenceInvestigationController {
    
    @AuraEnabled
    public static Boolean checkUserAccess() {
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName.equals(GlobalConstants.ADMIN_PROFILE_NAME)) {
            return true;
        }
        
        String userId = UserInfo.getUserId();
        String permissionSetName = GlobalConstants.DATA_EXCHANGE_SERVICE_DELIVERY;
        Boolean isUserHasAssignedPermissionSet = GlobalUtility.isUserHasAssignedPermissionSet(permissionSetName);
        
        return isUserHasAssignedPermissionSet;
    }
    
}