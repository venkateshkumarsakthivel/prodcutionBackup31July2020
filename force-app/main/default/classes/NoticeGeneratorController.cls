public with sharing class NoticeGeneratorController {
    
    @AuraEnabled
    public static Map<Id, String> fetchRecordTypeValues(String objectName, String caseType){
        Map<Id, String> recordtypemap = new Map<Id, String>();
        
        //Get Metadata for Case Record type, if found display only Notice record type one in the Matadata; else show all Notice record Type
        List<Case_Notice_Record_Type_Matrix__mdt> caseNoticeTypes = [SELECT Id, Case_Record_Type__c , Notice_Record_Type_DevName_List__c 
                                                                     FROM Case_Notice_Record_Type_Matrix__mdt 
                                                                     WHERE Case_Record_Type__c = :caseType LIMIT 1];
        
        //System.debug('caseNoticeTypes :'+caseNoticeTypes);
        
        if(caseNoticeTypes.size() >0 ){
            //Metadata record found for the Case Record Type
            List<String> validNoticeType = caseNoticeTypes[0].Notice_Record_Type_DevName_List__c.split(';');
            //System.debug('validNoticeType: '+validNoticeType);
            
            List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo rt : recordtypes){
                //System.debug('rt.getDeveloperName():'+rt.getDeveloperName());
                //System.debug('validNoticeType.contains(rt.getName()):'+validNoticeType.contains(rt.getName()));
                if(rt.getName() != 'Master' && rt.getName().trim() != '' && rt.isAvailable() && validNoticeType.contains(rt.getDeveloperName()))
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        } else {
            //No Metadata record found for the Case Record Type
            List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo rt : recordtypes){
                if(rt.getName() != 'Master' && rt.getName().trim() != '' & rt.isAvailable())
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }
        
        return recordtypemap;
    }
    
    @AuraEnabled
    public static List<Case_Legislative_Reference__c> getLegislativeReferences(Id caseId, Id RecordTypeId){      
        Set<Id> caseLegIds = new Set<Id>();
        Set<Id> noticeLegIds = new Set<Id>();
        Map<Id, Case_Legislative_Reference__c> caseLegMap = new Map<Id, Case_Legislative_Reference__c>();
        List<Case_Legislative_Reference__c> caseLegList= new List<Case_Legislative_Reference__c>(); 
        System.debug('RecordTypeId:'+RecordTypeId);
        
        Id ProhibitionNoticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        System.debug('ProhibitionNoticeRecordTypeId:'+ProhibitionNoticeRecordTypeId);
        for(Case_Legislative_Reference__c  clr : [SELECT Legislation__c, Legislation__r.Legislation_Name__c, Legislation__r.Description__c, Legislation__r.Section__c, Legislation__r.Recommendation__c, Legislation__r.Remediation__c, Legislation__r.Direction__c, Legislation__r.Schedule_Section_Clause_Rule__c, Legislation__r.Sub_Section_Clause__c ,Case__c 
                                                  FROM Case_Legislative_Reference__c 
                                                  WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Case__r.Id = :caseId])
        { 
            caseLegIds.add((Id)clr.get('Legislation__c'));
            caseLegMap.put((Id)clr.get('Legislation__c'),clr);
        }
        if(ProhibitionNoticeRecordTypeId ==RecordTypeId ){
            //Get Id of the Current Notice Records Locked Record Type.
            String LockedRecordTypeId = GlobalUtility.getNoticeLockedRecordTypeId(RecordTypeId);
            System.debug('LockedRecordTypeId:'+LockedRecordTypeId);
            
            for(Notice_Legislative_Reference__c nlr : [SELECT Legislation__c 
                                                       FROM Notice_Legislative_Reference__c 
                                                       WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Notice_Record__r.Case__r.Id =: caseId AND (Notice_Record__r.RecordTypeId =: RecordTypeId OR Notice_Record__r.RecordTypeId =: LockedRecordTypeId)])
            {
                noticeLegIds.add((Id)nlr.get('Legislation__c'));
            }
            caseLegIds.removeAll(noticeLegIds);
        }
        for(Id legId :caseLegIds){
            caseLegList.add(caseLegMap.get(legId));
            //System.debug(caseLegMap.get(legId).Legislation__r.Legislation_Name__c + ' ' +caseLegMap.get(legId).Legislation__r.Description__c);
        }
        return caseLegList;
    } 
    
    @AuraEnabled
    public static Notice_Record__c createNewNoticeRecord(String newNotice){
        System.debug('newNotice:'+newNotice);
        Notice_Record__c noticeRec = (Notice_Record__c) JSON.deserialize(newNotice, Notice_Record__c.class);
        System.debug('noticeRec:'+noticeRec);
        //Notice RT = show cause, prepopluate 1st &2nd round detail fields
        String noticeRecordType = getRecordTypeDeveloperName(noticeRec.RecordTypeId);
        if(noticeRecordType == 'Show Cause'){
            Map<String,String> WATMataDataSettingMap = getWATMataDataSetting();
            System.debug('noticeRec.Notice_Type__c:'+noticeRecordType);
            noticeRec.WAT_Show_Cause_1st_Round_Detail__c = WATMataDataSettingMap.get('WAT Compliance 1st Round');
            noticeRec.WAT_Show_Cause_2nd_Round_Detail__c =  WATMataDataSettingMap.get('WAT Compliance 2nd Round');
        }
        
        insert noticeRec;
        return ([SELECT Id, Name FROM Notice_Record__c WHERE Id= :noticeRec.Id LIMIT 1]);
    }
    
    @AuraEnabled
    public static Notice_Record__c getNoticeRecord(Id noticeId){
        System.debug('getNoticeRecord noticeId:'+noticeId);
        return ([SELECT Id, Name, Status__c, RecordTypeId, RecordType.DeveloperName, Notice_Type__c, Notice_Sub_Type__c FROM Notice_Record__c WHERE Id= :noticeId LIMIT 1]);
    }
    
    @AuraEnabled
    public static void createNoticeLegislationRecord(String selectedLeg, String noticeId){
        
        //Creating Notice Legislation Records from the Selected case legislation 
        Map<Id,Notice_Legislative_Reference__c> caseNoticeLegislationMap = new Map<Id,Notice_Legislative_Reference__c>();
        Map<Id,Case_Legislative_Reference__c> caseLegislationMap = new Map<Id,Case_Legislative_Reference__c>();
        
        if(String.isNotEmpty(selectedLeg)){
            List<Case_Legislative_Reference__c> caseLegs = (List<Case_Legislative_Reference__c>) JSON.deserialize(selectedLeg, List<Case_Legislative_Reference__c>.class);
            //system.debug('caseLegs:'+caseLegs);
            for(Case_Legislative_Reference__c caseLeg : caseLegs){
                Notice_Legislative_Reference__c noticeLeg = new Notice_Legislative_Reference__c();
                noticeLeg.Case_Legislative_Reference__c = caseLeg.Id;
                noticeLeg.Legislation__c =caseLeg.Legislation__c;
                noticeLeg.Section_Description__c = caseLeg.Legislation__r.Section__c;
                noticeLeg.Recommendation__c = caseLeg.Legislation__r.Recommendation__c;
                noticeLeg.Direction__c = caseLeg.Legislation__r.Direction__c;
                noticeLeg.Remediation__c = caseLeg.Legislation__r.Remediation__c;
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
    
    @AuraEnabled
    public static case getCaseRelatedRecords(Id caseId){     
        
        List<Case> caseRel = ([SELECT Id, Account.Notice_Email__c, Account.Document_Delivery_Preference__c, Account.Notice_Address_Street__c, Account.Notice_Address_City__c, Account.Notice_Address_State__c,
                               Account.Notice_Address_Postal_Code__c,
                               Lead_Auditor_User__r.Email
                               FROM Case 
                               WHERE Case.Id = :caseId LIMIT 1]);
        return caseRel[0];
    } 
    
 
    @AuraEnabled
    public static Map<String,String> getNoticeMataDataSetting(){

        Map<String,String> noticeSettingMap = new Map<String,String>();
        for(Notice_Record_Config__mdt notConfig : [SELECT Id,Notice_Type__c, Notice_Sub_Type__c, Field_Set_API_Name__c
                                                   FROM Notice_Record_Config__mdt]){
                                                       noticeSettingMap.put(notConfig.Notice_Type__c + '_' + notConfig.Notice_Sub_Type__c, notConfig.Field_Set_API_Name__c);
                                                   }
        
        System.debug('noticeSettingMap:'+noticeSettingMap);
        System.debug('noticeSettingMap key:'+noticeSettingMap.keySet());
        System.debug('noticeSettingMap value:'+noticeSettingMap.values());
        return noticeSettingMap;
    }
    
    @AuraEnabled
    public static String getAuthorisedUser(){
        User usr = [SELECT Id 
                    FROM User 
                    WHERE Id= :Userinfo.getUserId() AND Authorisation_Officer_Number__c !=NULL LIMIT 1];
        return (usr.Id != Null ? usr.Id : Null);
    }
    
    public static String getRecordTypeDeveloperName(String recordtypeId){
        // System.debug('recordtypeId: '+recordtypeId);
        RecordType NoticeRecorType = [SELECT Id, Name, DeveloperName 
                                      FROM RecordType 
                                      WHERE SObjectType = 'Notice_Record__c' AND Id =: recordtypeId LIMIT 1];
        return NoticeRecorType.Name;
    }
    
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = FieldSetUtil.getFields(recordId, objectName, fieldSetName);
        return form;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<Field> Fields { get; set; }
        
        public FieldSetForm() {
            Fields = new List<Field>();
        }
    }
    
    private static Map<String,String> getWATMataDataSetting(){
        Map<String,String> noticeSettingMap = new Map<String,String>();
        for(Notice_Record_Config__mdt notConfig : [SELECT Id,Notice_Sub_Type__c, WAT_Show_Cause_1st_Round_Detail__c, WAT_Show_Cause_2nd_Round_Detail__c
                                                   FROM Notice_Record_Config__mdt WHERE Notice_Sub_Type__c = 'WAT Compliance 1st Round' OR Notice_Sub_Type__c = 'WAT Compliance 2nd Round'])
        {
            if(notConfig.Notice_Sub_Type__c == 'WAT Compliance 1st Round'){
                noticeSettingMap.put('WAT Compliance 1st Round', notConfig.WAT_Show_Cause_1st_Round_Detail__c);
            }else if(notConfig.Notice_Sub_Type__c == 'WAT Compliance 2nd Round'){
                noticeSettingMap.put('WAT Compliance 2nd Round', notConfig.WAT_Show_Cause_2nd_Round_Detail__c);
            }
        }
        return noticeSettingMap;
    }
    
    /*
@AuraEnabled
public static boolean isComplianceNotice(String recordTypeName){
if(GlobalConstants.COMPLIANCE_NOTICE_RECORD_TYPE.contains(recordTypeName)){
return true;
}else{
return false;
}
}*/
    
     /*   @AuraEnabled
    public static Map<String,String> getNoticeMataDataSetting(Id noticeRecordId){
        System.debug('getNoticeMataDataSetting noticeId: '+noticeRecordId);
        Notice_Record__c notice = getNoticeRecord(noticeRecordId);
        System.debug('notice: '+notice.RecordType.DeveloperName);
        Map<String,String> noticeSettingMap = new Map<String,String>();
        for(Notice_Record_Config__mdt notConfig : [SELECT Id,Notice_Type__c, Notice_Sub_Type__c, Field_Set_API_Name__c
                                                   FROM Notice_Record_Config__mdt 
                                                   WHERE Record_Type_API_Name__c = :notice.RecordType.DeveloperName]){
                                                       noticeSettingMap.put(notConfig.Notice_Type__c + '_' + notConfig.Notice_Sub_Type__c, notConfig.Field_Set_API_Name__c);
                                                   }
        //Query for Locked Record Types
        for(Notice_Record_Config__mdt notConfig : [SELECT Id,Notice_Type__c, Notice_Sub_Type__c, Field_Set_API_Name__c
                                                   FROM Notice_Record_Config__mdt 
                                                   WHERE Locked_Record_Type_API_Name__c =:notice.RecordType.DeveloperName]){
                                                       noticeSettingMap.put(notConfig.Notice_Type__c + '_' + notConfig.Notice_Sub_Type__c, notConfig.Field_Set_API_Name__c);
                                                   }
        System.debug('noticeSettingMap:'+noticeSettingMap);
        System.debug('noticeSettingMap key:'+noticeSettingMap.keySet());
        System.debug('noticeSettingMap value:'+noticeSettingMap.values());
        return noticeSettingMap;
    }
 */  
    
}