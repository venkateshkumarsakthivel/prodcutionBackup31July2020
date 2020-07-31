/*
 * Controller of 'SubmitChildCasesForApproval.cmp'
 * Submitting child cases for approval and check user is sys admin or member of 'Sanction staff group. 
 */

public without sharing class SubmitCasesForApproval {
    
    @AuraEnabled
    public static Boolean checkUserAccess() {
        
        //Check if user is an admin
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName.equals(GlobalConstants.ADMIN_PROFILE_NAME))
            return true;
       
        //check if user is a member of a group Sanction Staff
        String loggedInUserId = UserInfo.getUserId();
        Group sanctionGrp = [SELECT Id, Name, DeveloperName FROM Group where Name = 'Sanctions Staff'];
        
        String sanctionGrpId =sanctionGrp.Id;
        List<GroupMember> grpMembers = [SELECT Id,GroupId FROM GroupMember where GroupId = :sanctionGrpId and UserOrGroupId = :loggedInUserId];
        
        If(grpMembers.size() == 0) 
            return false;
		else
        	return true;
    }
    
    @AuraEnabled
    public static String submitChildCasesForApproval(String parentCaseId) {
        
        try { 
            
			if(!checkUserAccess()) 
                return 'No Access';
            
            //find child criminal offence cases with Status = 'Lodged' and Sub_Status__c = 'Assessment In Progress'
            SET<String> requiredCaseStatus = new SET<String>{'Lodged'};
            SET<String> requiredCaseSubStatus = new SET<String>{'Assessment In-Progress'};
            List<Case> childCases = [SELECT Id, CaseNumber FROM Case 
                                     WHERE ParentId = :parentCaseId 
                                     AND Status = 'Lodged' 
                                     AND Sub_Status__c = 'Assessment In Progress'];
            
            if(childCases.size() == 0)
                return 'No Records';
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            String childCaseNumbers = '';
            
            for(Case childCase : childCases) {
                
                childCaseNumbers += childCase.CaseNumber + ', ';
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting case for approval');
                req1.setObjectId(childCase.Id);
                requests.add(req1);
            }
            
            childCaseNumbers = childCaseNumbers.removeEnd(', ');
            
            Approval.ProcessResult[] processResults = null;
            
            if(!Test.isRunningTest())
            	processResults = Approval.process(requests, true);
            
            return childCaseNumbers;
            
        }
        catch (Exception ex) {
            //Insert Application Log
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'SubmitCasesForApproval', 'submitChildCasesForApproval', ex.getMessage(), null, ex, null, null, null, null);
            return null;
        }
    }
}