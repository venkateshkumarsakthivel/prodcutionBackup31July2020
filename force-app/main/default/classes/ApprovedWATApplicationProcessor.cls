public with sharing class ApprovedWATApplicationProcessor {

    private Map<Id, Case> oldCases;
    private Map<Id, Case> newCases;
    
    private static Map<String, String> casePreferenceVsAccount = new Map<String, String>();
    static {
        casePreferenceVsAccount.put(GlobalConstants.DOCUMENT_DELIVERY_PREFERENCE_EMAIL , GlobalConstants.DOCUMENT_DELIVERY_PREFERENCE_EMAIL);
        casePreferenceVsAccount.put(GlobalConstants.DOC_DELIVERY_PREFERENCE_NOTICE_ADDR , GlobalConstants.DOC_DELIVERY_PREFERENCE_LETTER);
    }
    
    public ApprovedWATApplicationProcessor(Map<Id,Case> oldCaseRecords, Map<Id,Case> newCaseRecords){
        this.oldCases = oldCaseRecords;
        this.newCases = newCaseRecords;
    }
    
    public void process(){
        if(oldCases == null || newCases == null)
            return;
        Set<Id> qualifiedApplication = new Set<Id>();
        for(Id caseId : newCases.keySet()){
            if(isQualifiedForProcessing(newCases.get(caseId))){
                qualifiedApplication.add(caseId);
            }
        }
        
        if(qualifiedApplication.isEmpty())
            return;
        processGrantedApplication(qualifiedApplication);
    }
    
    private void processGrantedApplication(Set<Id> grantedApplications){
        Map<Id, Account> idVsAccounts = new Map<Id, Account>();
        
        for(Id caseId : grantedApplications){
            Case application = newCases.get(caseId);
            Account act = new Account();
            act.Id = application.AccountId;
            if(updateData(application.Notice_Address_City__c)) 
                act.Notice_Address_City__c = application.Notice_Address_City__c;
            if(updateData(application.Notice_Address_Country__c)) 
                act.Notice_Address_Country__c = application.Notice_Address_Country__c ;
            if(updateData(application.Notice_Address_Postal_Code__c)) 
                act.Notice_Address_Postal_Code__c = application.Notice_Address_Postal_Code__c ;
            if(updateData(application.Notice_Address_State__c)) 
                act.Notice_Address_State__c = application.Notice_Address_State__c ;
            if(updateData(application.Notice_Address_Street__c)) 
                act.Notice_Address_Street__c = application.Notice_Address_Street__c ;
            if(updateData(application.Notice_Email__c)) 
                act.Notice_Email__c = application.Notice_Email__c ;
            if(updateData(application.Preferred_method_of_comm_for_notice__c)) 
                act.Document_Delivery_Preference__c = casePreferenceVsAccount.get(application.Preferred_method_of_comm_for_notice__c) ;
            idVsAccounts.put(act.Id, act);
        }
        update idVsAccounts.values();
    }
    
    private boolean updateData(String newData){
        if(String.isBlank(newData))
            return false;
        return true;
    }
    
    private Boolean isQualifiedForProcessing(Case application){
        
        //check if application is approved
        if(application.Type == GlobalConstants.SERVICE_TYPE_TAXI 
            && application.Sub_Type__c == GlobalConstants.WAT_APPLICATION_SUB_TYPE 
            && oldCases.get(application.Id) != null
            && oldCases.get(application.Id).Sub_Status__c != GlobalConstants.CASE_SUB_STATUS_GRANTED
            && application.Sub_Status__c == GlobalConstants.CASE_SUB_STATUS_GRANTED ) {
        
           System.debug(LoggingLevel.INFO, 'Case ' + application.Id + ' is qualified for closure');
           return true;
        }
           
        System.debug(LoggingLevel.INFO, 'Case ' + application.Id + ' is not qualified for closure');
        return false;
    }
}