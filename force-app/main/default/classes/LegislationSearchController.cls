public without sharing class LegislationSearchController {
    
    @AuraEnabled
    public static List<Legislation__c> searchForRecords(String searchString, String searchSection, String exclusionRT){
        if(String.isNotEmpty(searchString)){
            String queryString = 'SELECT Id, Name, Legislation_Name__c, Description__c, Schedule_Section_Clause_Rule__c, Sub_Section_Clause__c, Legislation_Type__c, Status__c,Case_Record_Type_Exculsion__c FROM Legislation__c ';
            queryString+='WHERE Status__c = \'' + GlobalConstants.LEG_STATUS_ACTIVE + '\' AND RecordType.DeveloperName = \'' + GlobalConstants.LEG_STATUS_ACTIVE + '\' AND (Description__c Like \'' + '%'+ searchString +'%\' OR Legislation_Name__c Like \'' + '%'+ searchString +'%\') AND Schedule_Section_Clause_Rule__c Like  \'' + '%'+ searchSection +'%\' ';
            if(String.isNotEmpty(exclusionRT)){
                queryString+='AND (Case_Record_Type_Exculsion__c Excludes (\'' + exclusionRT + '\'))';
            }
            System.debug('queryString: '+queryString);
            queryString+= 'ORDER BY Id DESC LIMIT 200';
            return Database.query(queryString);
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Case_Legislative_Reference__c> loadCaseLegislation(Id caseId, Id noticeId){
        
        Set<Id> caseLegIds = new Set<Id>();
        Set<Id> noticeLegIds = new Set<Id>();
        Map<Id, Case_Legislative_Reference__c> caseLegMap = new Map<Id, Case_Legislative_Reference__c>();
        List<Case_Legislative_Reference__c> caseLegList= new List<Case_Legislative_Reference__c>(); 
        
        String RecordTypeId = [SELECT Id, RecordTypeId 
                               FROM Notice_Record__c 
                               WHERE Id=:noticeId LIMIT 1].RecordTypeId;
        System.debug('RecordTypeId: '+RecordTypeId);
        
        Id ProhibitionNoticeRecordTypeId = Schema.SObjectType.Notice_Record__c.getRecordTypeInfosByName().get('Prohibition Notice').getRecordTypeId();
        System.debug('ProhibitionNoticeRecordTypeId:'+ProhibitionNoticeRecordTypeId);
                
        
        for(Case_Legislative_Reference__c  clr : [SELECT Id, Name, Case__c, Legislation__c,Legislation__r.Legislation_Name__c,Legislation__r.Description__c, Legislation__r.Schedule_Section_Clause_Rule__c, Legislation__r.Sub_Section_Clause__c, Legislation__r.Section__c, Legislation__r.Direction__c, Legislation__r.Recommendation__c, Legislation__r.Remediation__c, Reason_for_Change__c, Primary__c, Comment__c, Status__c 
                                                  FROM Case_Legislative_Reference__c 
                                                  WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Case__r.Id = :caseId])
        { 
            caseLegIds.add((Id)clr.get('Legislation__c'));
            caseLegMap.put((Id)clr.get('Legislation__c'),clr);
        }
        System.debug('caseLegMap: '+caseLegMap);
        
        if(ProhibitionNoticeRecordTypeId == RecordTypeId ){
            //Get Id of the Current Notice Records Locked Record Type.
            String LockedRecordTypeId = GlobalUtility.getNoticeLockedRecordTypeId(RecordTypeId);
            System.debug('LockedRecordTypeId:'+LockedRecordTypeId);
            
            for(Notice_Legislative_Reference__c nlr : [SELECT Legislation__c 
                                                       FROM Notice_Legislative_Reference__c 
                                                       WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Notice_Record__r.Case__r.Id =: caseId AND (Notice_Record__r.RecordTypeId =: RecordTypeId OR Notice_Record__r.RecordTypeId =: LockedRecordTypeId)])
            {
                noticeLegIds.add((Id)nlr.get('Legislation__c'));
            }
            System.debug('noticeLegIds: '+noticeLegIds);
            caseLegIds.removeAll(noticeLegIds);
        }
        for(Id legId :caseLegIds){
            caseLegList.add(caseLegMap.get(legId));
        }
        System.debug('caseLegList: '+caseLegList);
        return caseLegList;
    }
}