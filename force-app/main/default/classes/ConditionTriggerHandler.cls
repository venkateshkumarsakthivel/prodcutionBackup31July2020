/*
 * Handler class to trigger execution on condition
 */
public with sharing class ConditionTriggerHandler {
    
    public static void afterInsert(Map<Id, Condition__c> newConditions){
        reIdentifyConditionType(newConditions.values());
    }
    
    public static void afterDelete(Map<Id, Condition__c> oldConditions){
        reIdentifyConditionType(oldConditions.values());
    }
    
    private static void reIdentifyConditionType(List<Condition__c> conditions){
        ConditionTypeIdentifier typeIdentifier = new ConditionTypeIdentifier(conditions);
        typeIdentifier.identify();
    }
}