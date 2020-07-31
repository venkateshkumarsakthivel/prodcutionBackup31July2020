//Class to process and invite to taxi portal.
public without sharing class InviteTaxiApplicantController {
    
    public class BaseException extends Exception {}
    
    /* Commented as it is no longer in use
    //Method to check if all application are compleated or not.
    @AuraEnabled
    public static boolean isAllTenderApplicationsCompleted(Id CaseId){       
        List<Case> caseList = [SELECT Id, Type, Status, RecordTypeId, AccountId, 
                               ContactId, CaseNumber, Subject, Priority, IsClosed, 
                               ClosedDate, Sub_Status__c, Operating_Locations__c, 
                               Licence_Type__c 
                               FROM Case 
                               WHERE ParentId =: CaseId
                               AND Status =: GlobalConstants.CASE_NEW
                               AND Sub_Status__c =: GlobalConstants.CASE_DRAFT];
        
        return caseList.isEmpty();            
    }
    */
    //Method to check if all application have email for the contact
    @AuraEnabled
    public static boolean validateApplicationDetails(Id caseId){       
        Boolean isEmailMissing = false;
        try {
            List<Case> caseList = [SELECT Id, Contact_Email__c
                                FROM Case 
                                WHERE ParentId =: caseId
                                AND Status =: GlobalConstants.CASE_NEW
                                AND Sub_Status__c =: GlobalConstants.READY_TO_BE_SENT_SUB_STATUS];
                                //AND Record_type_dev_name__c !=: GlobalConstants.TENDER_CASE_RECORD_TYPE_DEV_NAME];
            System.debug(caseId);
            System.debug(caseList);
            for(Case c : caseList){
                if(String.isEmpty(c.Contact_Email__c)){
                    isEmailMissing = true;
                }
            }
            return isEmailMissing;
        } catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantController','validateApplicationDetails',ex.getMessage(),ex);
            return false;
        }            
    }

    //Method to process accounts of Tender Case.
    @AuraEnabled
    public static string processAccountForCase(Id caseId) {
        try {
            
            List<Id> accountIds = new List<Id>();
            Map<Id, Id> mapAccountIdVsCaseId = new Map<Id, Id>();
            Map<Id, String> mapAccountIdVsNoticeEmail = new Map<Id, String>();
            List<Case> casesToUpdate = new List<Case>();
            
            for(Case caseRec:[SELECT Id, Type, Status, RecordTypeId, AccountId, 
                              ContactId, CaseNumber, Subject, Notice_Email__c, Priority, IsClosed, 
                              ClosedDate, Sub_Status__c, Operating_Locations__c, 
                              Licence_Type__c 
                              FROM Case 
                              WHERE ParentId =: caseId
                              AND Sub_Status__c = :GlobalConstants.READY_TO_BE_SENT_SUB_STATUS]) { 
                                  
                                  accountIds.add(caseRec.AccountId);
                                  mapAccountIdVsCaseId.put(caseRec.AccountId, caseRec.Id); 
                                  mapAccountIdVsNoticeEmail.put(caseRec.AccountId, caseRec.Notice_Email__c); 
                                  caseRec.Status = GlobalConstants.APPLICATION_STATUS_DRAFT;
                                  caseRec.Sub_Status__c = GlobalConstants.APPLICATION_STATUS_DRAFT;
                                  caseRec.Taxi_Invitation_Send_Date__c = System.now();
                                  casesToUpdate.add(caseRec);
                              }
            
            if(casesToUpdate.size() > 0 ) {
                update casesToUpdate;
                InviteApplicantHelper inviteHelper = new InviteApplicantHelper(casesToUpdate);
                inviteHelper.invite();
            }
            
            return 'Success';
            
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'InviteTaxiApplicantController','processAccountForCase',ex.getMessage(),ex);
            return null;
        }
    }
}