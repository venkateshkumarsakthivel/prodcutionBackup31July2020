public with sharing class CriminalOffenceCaseFormController {
    @AuraEnabled
    public static Boolean isValidUser() {
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName.equals(GlobalConstants.ADMIN_PROFILE_NAME)) {
            return true;
        }
        
        return GlobalUtility.isUserHasAssignedPermissionSet(GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET);
        
    }
}