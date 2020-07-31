public class AuditCustomSubmitForApprovalController {
    
    @AuraEnabled
    public static Case fetchCaseDetails(String caseId) {
        
        /*----------- this method is to fetch case details for caseId---------------------   */
        
     	/* Modified to remove references to fields not required as per the New Process 
     	 Case caseRec = [select Account.Id,Audit_Vendor__c,Lead_Auditor__c,Audit_Objectives__c,Audit_Scope__c,Plan_Approved_by__c,Plan_Approved_Date__c,
                        Audit_Target_End_Date__c,Audit_Target_Start_Date__c,
                        Audit_Summary__c,Report_and_Recommendation__c ,
                        Report_Approval_Date__c ,status,Sub_Status__c , Description ,Audit_Vendor__r.Auditor_Type__c
                        ,Audit_Completion_Date__c from Case where Id =:caseId ]; */
        
        Case caseRec = [select Account.Id, Lead_Auditor_User__c, Plan_Approved_by__c, Plan_Approved_Date__c,
                        Audit_Target_Start_Date__c, Report_Approval_Date__c, status, Sub_Status__c, Description,
                        Audit_Completion_Date__c, Audit_Reviewer__c from Case where Id =:caseId ];
        System.debug('case details '+ caseRec );
        return caseRec;
    }
    
    @AuraEnabled
    public static boolean isValidCaseRecord(String caseId) { 
        
        /*------ this method is to check whether given Case has related Authorisation (suspended / granted) present or not ---------*/
        
        try{
            Case caseRec = [select Account.Id from Case where Id =:caseId ];
            string relatedAccountId = caseRec.AccountId ;
            System.debug('related account id is '+ relatedAccountId );
            
            List<Authorisation__C> listofAuth = [select Id ,status__c ,Name from Authorisation__c where Service_Provider__c =:relatedAccountId 
                                                 and (status__c = : GlobalConstants.AUTHORISATION_GRANTED or status__c = : GlobalConstants.AUTHORISATION_SUSPENDED 
                                                      or status__c = : GlobalConstants.GRANTED_CONDITIONALLY or status__c = : GlobalConstants.GRANTED_UNCONDITIONALLY)
                                                 and (Authorisation_Type__c ='TSP' or Authorisation_Type__c ='BSP')];
            
            System.debug('related auth are'+ listofAuth );
            
            if(listofAuth.size()==0)
            {
                return false;
            }
            else{
                return true;
            }
        }
        
        catch(Exception ex){
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCustomSubmitForApprovalController','validateCaseRecord',ex.getMessage(),ex);
            return null;
        }
        
    }
    
    @AuraEnabled
    public static string callSubmitForApproval(String caseId) 
    {
        
        /*------ this method is to submit case for applicable approval process------*/
        try{
            
            Approval.ProcessSubmitRequest newRequest = new Approval.ProcessSubmitRequest();
            newRequest.setComments('Submitting request for approval.');
            newRequest.setObjectId(caseId);
            
            Approval.ProcessResult result = Approval.process(newRequest);
            system.debug('result is'+result ); 
            
            if(result.isSuccess()){
                return 'SUBMITTED';  
            }
            else
            {
                return 'ERROR';
            }
            
            
        }
        catch(Exception ex){
            
            if(ex.getMessage().contains('ALREADY_IN_PROCESS'))
            {
                System.debug('in alredy process');
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCustomSubmitForApprovalController','callSubmitForApproval',ex.getMessage(),ex);
                return 'ALREADY IN PROCESS';
            }
            else if(ex.getMessage().contains('NO_APPLICABLE_PROCESS'))
            {
                System.debug('in no applicable process');
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCustomSubmitForApprovalController','callSubmitForApproval',ex.getMessage(),ex);
                return 'NO APPLICABLE PROCESS';
            }
            else
                return null;
            
        }
    }
   // auditTargetEndDate depreicated, potiently method to be deleted 
  /*   @AuraEnabled
    public static Boolean validateAuditStartDate(String auditTargetStartDate , String auditTargetEndDate){
        Date getAuditTargetStartDate = Date.valueOf(auditTargetStartDate);
        Date getAuditEndStartDate = Date.valueOf(auditTargetEndDate);
        System.debug('Datetime '+ getAuditTargetStartDate + '' +getAuditEndStartDate);
        Date checkAuditDate = checkBusinessDay(getAuditTargetStartDate);
        System.debug('checkAuditDate:' +checkAuditDate);
        if(checkAuditDate < getAuditEndStartDate){
            System.debug('Less than End Date');
            return true;
        }
        else{
            System.debug('Greater than End Date');
            return false;
        }
    }
    
    public static Date checkBusinessDay(Date checkAuditDate) {
        
        BusinessHours businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, checkAuditDate);
        
        if(isInBusinessHours) {
            return checkAuditDate;
        } else {
            checkAuditDate = checkAuditDate.addDays(1);
            return checkBusinessDay(checkAuditDate);
        }
    } */
    
}