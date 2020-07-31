public without sharing class NoticeLegislationController { 
    
    @AuraEnabled
    public static List<Notice_Legislative_Reference__c> loadNoticeLegislation(Id noticeId){
        return ([SELECT Id, Name, Notice_Record__c, Legislation__c,Legislation__r.Legislation_Name__c,Legislation__r.Description__c, Legislation__r.Section__c, Legislation__r.Schedule_Section_Clause_Rule__c, Legislation__r.Sub_Section_Clause__c, Reason_for_Change__c, Comment__c, Status__c 
                 FROM Notice_Legislative_Reference__c 
                 WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Notice_Record__r.Id = :noticeId]);
    }
        
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Notice_Legislative_Reference__c.Reason_for_Change__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static void saveNoticeLegislation(String noticeLegislation){
        system.debug('noticeLegislation:'+noticeLegislation);
        List<Notice_Legislative_Reference__c> noticeLeg = (List<Notice_Legislative_Reference__c>) JSON.deserialize(noticeLegislation, List<notice_Legislative_Reference__c>.class);
        system.debug('noticeLeg:'+noticeLeg);
        if(noticeLeg.size()>0){
            try{
            	upsert noticeLeg;
            }catch(DmlException e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static void deleteNoticeLegislation(String noticeLegislation){
        system.debug('noticeLegislation:'+noticeLegislation);
        List<Notice_Legislative_Reference__c> noticeLeg = (List<Notice_Legislative_Reference__c>) JSON.deserialize(noticeLegislation, List<notice_Legislative_Reference__c>.class);
        system.debug('noticeLeg:'+noticeLeg);
        if(noticeLeg.size()>0){
            delete noticeLeg;
        }
    }
}