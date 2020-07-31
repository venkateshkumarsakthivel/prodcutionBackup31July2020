/**
* Server side rest resource controller for creating new audit 
*/
public with sharing class AuditNewNoticeController {
    
    @AuraEnabled
    public static List<String> getNoticeSubTypes(String selectedNoticeType){
        List<String> options = new List<String>();
        
        List<Audit_Notice_Records_Config__mdt> auditNoticesConfigMDT = AuditNoticesConfiguration.get();
        for(Audit_Notice_Records_Config__mdt metadataRecord : auditNoticesConfigMDT) {
            
            if(metadataRecord.Type__c.equals(selectedNoticeType)) {
                options.add(metadataRecord.Sub_Type__c);
            }
        }
        
        options.sort();
        return options;
    }
    
    @AuraEnabled
    public static Case getAuditCaseDetails(String auditCaseId){
        
        Case auditCase = [SELECT AccountId, Account.Notice_Address__c, ContactId, Account.Email__c,
                          Audit_Vendor__c, Id, Lead_Auditor__c, Lead_Auditor__r.Email, Assigned_Reviewer__c,
                          Account.Notice_Email__c, Record_Type_Dev_Name__c, Audit_Target_End_Date__c, Sub_Status__c 
                          FROM Case WHERE Id = :auditCaseId];
        
        return auditCase;
    }
    
    @AuraEnabled
    public static User getLoggedinUsersDetails() {
        
        return GlobalUtility.getLoggedInUser();
    }  
    
    @AuraEnabled
    public static Audit_Notice_Records_Config__mdt getRecordTypeAndDefaultValues(String selectedNoticeType, String selectedNoticeSubType) {
        
        Audit_Notice_Records_Config__mdt result = null;
        
        List<Audit_Notice_Records_Config__mdt> auditNoticesConfigMDT = AuditNoticesConfiguration.get();
        for(Audit_Notice_Records_Config__mdt metadataRecord : auditNoticesConfigMDT) {
            
            if(metadataRecord.Type__c.equals(selectedNoticeType) && metadataRecord.Sub_Type__c.equals(selectedNoticeSubType)) {
                result = metadataRecord;
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static List<Case_Legislative_Reference__c> loadCaseNoticeLegislation(Id caseId){
        return ([SELECT Id, Name, Case__c, Legislation__c,Legislation__r.Legislation_Name__c,Legislation__r.Description__c
                 FROM Case_Legislative_Reference__c 
                 WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Case__r.Id = :caseId ]);
    } 
    
    /*@AuraEnabled not valid business scenario
public static List<Case_Legislative_Reference__c> loadCaseLegislation(Id caseId){
return ([SELECT Id, Name, Case__c, Legislation__c,Legislation__r.Legislation_Name__c,Legislation__r.Description__c, Legislation__r.Schedule_Section_Clause_Rule__c, Legislation__r.Sub_Section_Clause__c, Notice_Legislative_Reference__r.Status__c 
FROM Case_Legislative_Reference__c 
WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Case__r.Id = :caseId AND (Notice_Legislative_Reference__c = NULL OR Notice_Legislative_Reference__r.Status__c = 'Inactive')]);
}*/
    
    @AuraEnabled
    public static String createNewNoticeRecord(String newNotice){
        //System.debug('Notice Record:'+newNotice);
        Notice_Record__c noticeLeg = (Notice_Record__c) JSON.deserialize(newNotice, Notice_Record__c.class);
        insert noticeLeg;
        //System.debug('noticeLeg.Id'+noticeLeg.Id);
        return noticeLeg.Id;
    }
    
    @AuraEnabled
    public static void createNoticeLegislationRecord(String selectedLeg, String noticeId){
        Map<Id,Notice_Legislative_Reference__c> caseNoticeLegislationMap = new Map<Id,Notice_Legislative_Reference__c>();
        Map<Id,Case_Legislative_Reference__c> caseLegislationMap = new Map<Id,Case_Legislative_Reference__c>();
        List<Case_Legislative_Reference__c> updatedCaseLegs = new List<Case_Legislative_Reference__c>();
        
        system.debug('selectedLeg:'+selectedLeg);
        List<Case_Legislative_Reference__c> caseLegs = (List<Case_Legislative_Reference__c>) JSON.deserialize(selectedLeg, List<Case_Legislative_Reference__c>.class);
        system.debug('caseLegs:'+caseLegs);
        
        for(Case_Legislative_Reference__c caseLeg : caseLegs){
            Notice_Legislative_Reference__c noticeLeg = new Notice_Legislative_Reference__c();
            noticeLeg.Case_Legislative_Reference__c = caseLeg.Id;
            noticeLeg.Legislation__c =caseLeg.Legislation__c;
            noticeLeg.Notice_Record__c = noticeId;
            noticeLeg.Status__c = 'Active';            
            caseNoticeLegislationMap.put(caseLeg.Id,noticeLeg);
            caseLegislationMap.put(caseLeg.Id, caseLeg);
        }
        try{   
            if(caseNoticeLegislationMap.size() > 0){
                Database.insert(caseNoticeLegislationMap.values());
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
}