/*-----------------------------------------------------------------------------------------
Author:        Akshay Badgujar
Company:       Arxxus
Description:   Server side rest resource controller to fetch case information. 
Test Class:    ASPNotifiableReopenCaseTest

History
07-02-2018     Akshay Badgujar        Initial Release
-------------------------------------------------------------------------------------------*/
public class ASPNotifiableReopenCase {
    
    //method to log return request for the selected case record
    @AuraEnabled
    public static String updateCaseStatus(String caseId) {
        //try {
            List<Case> caseList = new List<Case>();
            string loggedInUserId = UserInfo.getUserId();
            string loggedInRoleId = UserInfo.getUserRoleId();
            
            String queueId = [SELECT Id from Group where Type = 'Queue' AND DeveloperNAME = 'Compliance_NO_Admin'].Id;
            String nOGroupId = [SELECT Id from Group where DeveloperNAME = 'Compliance_Notifiable_Occurrence'].Id;
            
            List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                         WHERE GroupId IN (SELECT id FROM Group where Id =:nOGroupId)];
            
            set<string> ids = new set<string>(); 
            for(GroupMember member: members) { 
                ids.add(member.UserOrGroupId); 
            } 
            
            set<String> roleId = new set<string>();
            for(Group gp: [SELECT RelatedId,Id From Group WHERE Id IN:ids]) { 
                roleId.add(gp.RelatedId); 
            } 
           
            if(roleId.contains(loggedInRoleId) || ids.contains(loggedInUserId)){
                for(Case c:[SELECT Id,Status,OwnerId FROM Case WHERE Id = :caseId]){
                    if(C.Status == 'Closed'){
                        c.Status = 'Reopened';
                        c.OwnerId=queueId;
                        caseList.add(c);
                    }
                }
                
                if(caseList.size() > 0){
                    update caseList; 
                    return 'SUCCESS';
                }
                else
                    return 'Error';
            }
            else
                return 'InvalidUser';
            
        //}
       // catch(Exception ex) {
        //    ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPManageAccountAuthorisation','updateCaseStatus',ex.getMessage(),ex);
         //   return null;
        //}
    }
}