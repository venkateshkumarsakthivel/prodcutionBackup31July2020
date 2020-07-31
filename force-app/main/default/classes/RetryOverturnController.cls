public with sharing class RetryOverturnController {
        
    @AuraEnabled
    public static Boolean isValidUser() {
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName.equals(GlobalConstants.ADMIN_PROFILE_NAME)) {
            return true;
        }
        
        return GlobalUtility.isUserHasAssignedPermissionSet(GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET);
        
    }

    @AuraEnabled 
    public static Boolean updateOvertunStatusInRMS(Id caseId) {

    system.debug('caseId:===='+caseId);
    
    Case caseInstance = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Decision__c,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Id = :caseId];
    system.debug('caseInstance==='+caseInstance);
                        
    
    if(caseInstance != null 
            && (caseInstance.Decision__c == GlobalConstants.CHARGE_CORRECTED 
                || caseInstance.Decision__c == GlobalConstants.CHARGE_RETAINED) ) {
        
            P2PRMSClient client=new P2PRMSClient();
            P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
            client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE, visitor, caseInstance);
            visitor.updateResponses();
            return true;
        
     } 
     else 
        return false;

     return null;
  }
}