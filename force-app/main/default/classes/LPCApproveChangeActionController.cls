/*-----------------------------------------------------------------------------------------
Description:   Server side rest resource controller to fetch Law Part Code information. 
Test Class:    LPCApproveChangeActionControllerTest
-------------------------------------------------------------------------------------------*/
public class LPCApproveChangeActionController {
    
    //method to log return request for the selected Law Part Code record
    @AuraEnabled
    public static String updateLawPartCodeStatus(String lawPartCodeId) {
        
        Id profileId = UserInfo.getProfileId();
        
        String profileName = [Select Name FROM Profile WHERE Id =: profileId].Name;
        
        List<PermissionSetAssignment> permissionSetName = [SELECT PermissionSet.Name 
                                                           FROM PermissionSetAssignment where
                                                           Assignee.Id =: UserInfo.getUserId() AND
                                                           PermissionSet.Name=:GlobalConstants.SANCTIONS_OPERATIONS_STAFF_LEVEL_2_LEVEL_3_PERMISSION_SET];
        
        List<Law_Part_Code__c> lawPartCodeList = new List<Law_Part_Code__c>();
        
        List<Law_Part_Code__c> lpcRecords = [SELECT Id,Unapproved_P2P_Classification__c,Unapproved_P2P_Regulatory_End_Date__c,
                                             Unapproved_Repeal_Date__c,Unapproved_P2P_Regulation_Sub_clause__c,Unapproved_Special_Conditions__c,Law_Part_Repeal_Date__c,
                                             P2P_Regulatory_End_Date__c,Approval_Date__c,P2P_Classification__c,Special_Conditions__c,Status__c 
                                             FROM Law_Part_Code__c WHERE Id =: lawPartCodeId];
        
        if(profileName == GlobalConstants.ADMIN_PROFILE_NAME 
           || (profileName == GlobalConstants.P2P_OPERATIONS_LEVEL_3 && (permissionSetName != null && permissionSetName.size() > 0))){
               
               for(Law_Part_Code__c lpcVal: lpcRecords){
                   
                   if(lpcVal.Status__c != GlobalConstants.LAW_PART_CODE_STATUS_APPROVED){               
                       
                       if(lpcVal.Approval_Date__c != Null || !String.isBlank(lpcVal.Unapproved_P2P_Classification__c)){
                           
                           if(lpcVal.Unapproved_Repeal_Date__c != Null)
                               lpcVal.Law_Part_Repeal_Date__c = lpcVal.Unapproved_Repeal_Date__c;
                           
                           if(lpcVal.Unapproved_P2P_Regulatory_End_Date__c != Null)
                               lpcVal.P2P_Regulatory_End_Date__c = lpcVal.Unapproved_P2P_Regulatory_End_Date__c;
                           
                           if(!String.isBlank(lpcVal.Unapproved_P2P_Classification__c))
                               lpcVal.P2P_Classification__c = lpcVal.Unapproved_P2P_Classification__c;
                           
                           if(!String.isBlank(lpcVal.Unapproved_Special_Conditions__c))
                               lpcVal.Special_Conditions__c = lpcVal.Unapproved_Special_Conditions__c;
                           
                           if(!String.isBlank(lpcVal.Unapproved_P2P_Regulation_Sub_clause__c))
                               lpcVal.P2P_Regulation_Sub_clause__c = lpcVal.Unapproved_P2P_Regulation_Sub_clause__c;
                           
                           lpcVal.Status__c = GlobalConstants.LAW_PART_CODE_STATUS_APPROVED;
                           lpcVal.Unapproved_Repeal_Date__c = Null;
                           lpcVal.Unapproved_P2P_Regulatory_End_Date__c = Null;
                           lpcVal.Unapproved_P2P_Classification__c = '';
                           lpcVal.Unapproved_Special_Conditions__c = '';
                           lpcVal.Unapproved_P2P_Regulation_Sub_clause__c = '';
                           lpcVal.Approval_Date__c = system.today();
                           
                           lawPartCodeList.add(lpcVal);
                       }else{
                           return 'UnapprovedFieldError'; 
                       }
                   }
               }
               
               system.debug('----lawPartCodeList----'+ lawPartCodeList);
               if(lawPartCodeList.size() > 0){
                   update lawPartCodeList; 
                   return 'SUCCESS';
               }
               else
                   return 'Error';  
           }else{
               return 'InvalidUser';
           }
    }
}