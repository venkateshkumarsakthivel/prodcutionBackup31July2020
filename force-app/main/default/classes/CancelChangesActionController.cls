public class CancelChangesActionController {
    
    //function to fetch logged in user profile
    @AuraEnabled
    public static Boolean fetchLoggedInUserProfile() {
        Boolean isValidForToastMsg = true;
        List<User> loggedInUser = fetchLoggedInUserDetails();
        if(loggedInUser != null && loggedInUser.size() > 0) {
            if(loggedInUser[0].Profile.Name == GlobalConstants.ADMIN_READ_ONLY_PROFILE_NAME || loggedInUser[0].Profile.Name == GlobalConstants.ADMIN_PROFILE_NAME) {
                isValidForToastMsg =false;
            }
            else {
                List<PermissionSetAssignment> loggedInUserpermissionSet = fetchLoggedInUserpermissionSetDetails(loggedInUser[0].Id);
                if(loggedInUserpermissionSet != null && loggedInUserpermissionSet.size() > 0) {
                    
                    if((loggedInUser[0].Profile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_2 || loggedInUser[0].Profile.Name == GlobalConstants.P2P_OPERATIONS_LEVEL_3) 
                         && loggedInUserpermissionSet[0].PermissionSet.Name == GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET) {
                              
                              isValidForToastMsg =false;
                     }
                }
            }
        }
        
        return isValidForToastMsg;
    }
    
    //function to fetch logged in user details
    public static List<User> fetchLoggedInUserDetails() {
        List<User> loggedInUser = [SELECT Id, Profile.Name 
                                   FROM User 
                                   WHERE Id =: userInfo.getUserId() 
                                   LIMIT 1];
        
        return loggedInUser;
    }
    
    //function to fetch permission set details
    public static List<PermissionSetAssignment> fetchLoggedInUserpermissionSetDetails(String loggedInUserId) {
        List<PermissionSetAssignment> loggedInUserpermissionSet = [SELECT Assignee.Id, PermissionSet.Name 
                                                                   FROM PermissionSetAssignment 
                                                                   WHERE Assignee.Id =: loggedInUserId 
                                                                   AND PermissionSet.Name =: GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET
                                                                   LIMIT 1];
        
        return loggedInUserpermissionSet;
    }
    
    //function to cancel changes action for CancelChangesActionOfLawPartCode form
    @AuraEnabled
    public static Boolean cancelChangesAction(String lawPartCodeId) {
        Boolean isValidForToastMsg = false;
        Law_Part_Code__c lawPartCodeRecord = fetchLawPartCodeRecordDetails(lawPartCodeId);
        
        if(lawPartCodeRecord.Status__c == 'Approved' || 
           ((lawPartCodeRecord.Unapproved_Repeal_Date__c == null) && 
           (lawPartCodeRecord.Unapproved_P2P_Regulatory_End_Date__c == null) && 
           (lawPartCodeRecord.Unapproved_P2P_Classification__c == null || lawPartCodeRecord.Unapproved_P2P_Classification__c == '') && 
           (lawPartCodeRecord.Unapproved_Special_Conditions__c == null || lawPartCodeRecord.Unapproved_Special_Conditions__c == '') && 
           (lawPartCodeRecord.Unapproved_P2P_Regulation_Sub_clause__c == null || lawPartCodeRecord.Unapproved_P2P_Regulation_Sub_clause__c == ''))) {
               
               isValidForToastMsg = true;
               
               return isValidForToastMsg;
        }
        if(lawPartCodeRecord.Status__c == 'Unapproved') {
            lawPartCodeRecord.Status__c = lawPartCodeRecord.Old_Status__c;
            lawPartCodeRecord.Unapproved_Repeal_Date__c = null;
            lawPartCodeRecord.Unapproved_P2P_Regulatory_End_Date__c = null;
            lawPartCodeRecord.Unapproved_P2P_Classification__c = '';
            lawPartCodeRecord.Unapproved_Special_Conditions__c = '';
            lawPartCodeRecord.Unapproved_P2P_Regulation_Sub_clause__c = '';
            
            update lawPartCodeRecord;
            isValidForToastMsg = false;
        }
        
        return isValidForToastMsg;
    }
    
    //function to fetch law part code record details
    public static Law_Part_Code__c fetchLawPartCodeRecordDetails(String lawPartCodeId) {
        Law_Part_Code__c lawPartCodeRecord = [SELECT Id, Status__c, Old_Status__c, Unapproved_Repeal_Date__c, Unapproved_P2P_Regulatory_End_Date__c, 
                                              Unapproved_P2P_Classification__c, Unapproved_Special_Conditions__c, Unapproved_P2P_Regulation_Sub_clause__c  
                                              FROM Law_Part_Code__c WHERE Id =: lawPartCodeId LIMIT 1];
        
        return lawPartCodeRecord;
    }
}