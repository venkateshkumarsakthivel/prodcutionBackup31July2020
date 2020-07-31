public with sharing class CaseStopWatchController {
    
    @AuraEnabled
    public static String details(String id)  {
        Case cd = [SELECT Id, Case_Paused_TimeStamp__c, isPaused__c, Case_Age__c, Case_Paused_Days__c, IsClosed FROM Case WHERE Id = :id LIMIT 1];
        return JSON.serialize(cd);
    }
    
    @AuraEnabled
    public static String CSWpause(String id)  {
        Case cd = [SELECT Id, Case_Paused_TimeStamp__c, isPaused__c, Case_Age__c, Case_Paused_Days__c, IsClosed FROM Case WHERE Id = :id LIMIT 1];
        
        cd.Case_Paused_TimeStamp__c = DateTime.now();
        cd.isPaused__c = true;
        update cd;
        return CaseStopWatchController.details(id);
    }
    
    @AuraEnabled
    public static String CSWresume(String id)  {
        Case cd = [SELECT Id, Case_Paused_TimeStamp__c, isPaused__c, Case_Age__c, Case_Paused_Days__c, IsClosed  FROM Case WHERE Id = :id LIMIT 1];
        Date now = DateTime.newInstance(DateTime.now().getTime()).date();
        Date paused = DateTime.newInstance(cd.Case_Paused_TimeStamp__c.getTime()).date();
        cd.Case_Paused_Days__c += Math.abs(now.daysBetween(paused));
        cd.isPaused__c = false;
        update cd;
        return CaseStopWatchController.details(id);
    }
}