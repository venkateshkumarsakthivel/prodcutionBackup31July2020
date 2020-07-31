/*
Helper class called through Case trigger handler to update Notice Records on Audit Action Case Update.
*/



public class NoticeRecordAuditActionCase {
    
    private Map<Id, Case> newCases;
    private Map<Id, Case> oldCases;
    
    Map<String, List<Case>> contactIdVsCases;
    List<Case> getCaseRecords;
    List<Notice_Record__c> updateNCRecords;
    
    public NoticeRecordAuditActionCase(Map<Id, Case> newCases, Map<Id, Case> oldCases){
        
        this.newCases = newCases;
        this.oldCases = oldCases;
        this.getCaseRecords = new List<Case>();
        this.updateNCRecords = new List<Notice_Record__c>();
    }
    
    public void checkIsRelatedCaseApprovedOnNCRecord(){
        try{
            System.debug('In checkIsRelatedCaseApprovedOnNCRecord');
            for (Case tempCase :  newCases.values()){
                if(tempCase.Record_Type_Dev_Name__c == 'Audit_Action_Case'){
                    //GlobalConstants.AUDIT_ACTION_CASE_RECORD_TYPE_DEV_NAME'' 
                    //&& ((tempCase.Status == GlobalConstants.CASE_STATUS_IN_PROGRESS && tempCase.Sub_Status__c == GlobalConstants.CASE_APPROVED) 
                       // && (tempCase.Audit_Action_Case_Appproved__c == true && oldCases.get(tempCase.Id).Audit_Action_Case_Appproved__c == false))
                       // ||
                        //(tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS && tempCase.Sub_Status__c == GlobalConstants.SUB_STATUS_COMPLETED)
                       // && (tempCase.Audit_Action_Case_Appproved__c == true && oldCases.get(tempCase.Id).Audit_Action_Case_Appproved__c == true))
                       // ))){
                            getCaseRecords.add(tempCase);
                            System.debug('getCaseRecords' +getCaseRecords);
                        }
            }
            
            if(!getCaseRecords.isEmpty()){
                List<Notice_Record__c> getRelatedNoticeRecord = [SELECT Id FROM Notice_Record__c WHERE Case__c IN: getCaseRecords AND Status__c != 'Sent'];
                System.debug('NC:'+getRelatedNoticeRecord);
                for(Notice_Record__c updateNC : getRelatedNoticeRecord){
                    //updateNC.Is_Related_Case_Approved__c = true;
                    //updateNC.Is_Related_Case_Approved_del1__c = true;
                    //Used to trigger Notice Record object trigger to update Conga Related Validation if its Status is not Sent.
					System.debug('Notice Records Selected');
                    updateNCRecords.add(updateNC);
                }
            }
            
            if(!updateNCRecords.isEmpty()){
                 Database.SaveResult [] updateResult = Database.update(updateNCRecords, false);
                for (Database.SaveResult r : updateResult)
                {
                    if (!r.isSuccess())
                    {
                        for (Database.Error e : r.getErrors())
                        { 
                         System.debug('DataBase update Errors: '+e);
                        }
                      }
                 }
                System.debug('Updates'+updateNCRecords);
            }
        } 
        catch(Exception ex){
            System.debug('Exception' +ex);
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NoticeRecordAuditActionCase','checkIsRelatedCaseApprovedOnNCRecord',ex.getMessage(),ex);
        }
    }
    
}