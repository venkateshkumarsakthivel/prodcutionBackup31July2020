public with sharing class BulkUploadLawPartCodeController {
    
    //Input :- Law Part Code Content of CSV file uploaded from home tab
    //Output :- Number of successfully inserted records
    @AuraEnabled
    public static String addLawPartCodesFromCSV(String fileContent, String headerRow){
        
        Id profileId = UserInfo.getProfileId();
        String resultString;
        
        String profileName = [Select Name FROM Profile WHERE Id =: profileId].Name;
        
        List<PermissionSetAssignment> permissionSetName = [SELECT PermissionSet.Name 
                                                           FROM PermissionSetAssignment where
                                                           Assignee.Id =: UserInfo.getUserId() AND
                                                           (PermissionSet.Name=:GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET OR
                                                            PermissionSet.Name=:GlobalConstants.SANCTIONS_OPERATIONS_STAFF_PERMISSION_SET )];
        System.debug('----:'+ permissionSetName.size());
        System.debug('profileName----:'+ profileName);
        System.debug('Check this: '+permissionSetName);
        
        if(profileName == GlobalConstants.ADMIN_PROFILE_NAME 
           || ((profileName == GlobalConstants.P2P_OPERATIONS_LEVEL_3 || profileName == GlobalConstants.P2P_OPERATIONS_LEVEL_2)
               && (permissionSetName != null && permissionSetName.size() > 0))){
                   
                   Integer successUploads;
                   
                   System.debug('fileContent is = '+fileContent);
                   
                   BulkLawPartCodeLoader blpcloader = new BulkLawPartCodeLoader(fileContent, headerRow);
                   resultString = blpcloader.execute();
                   
                   System.debug('Result string: '+resultString);
               }
        
        return resultString;
    }
    
}