public with sharing class PendingCaseRetriever {
    
    @AuraEnabled
    public static List<Case> retrieveAllCases(){
        List<Case> cases = [SELECT Id, CaseNumber, Status, Sub_Status__c, Type, Sub_Type__c, 
                                Date_Submitted__c, AccountId, Account.Name, OwnerId, Owner.Name 
                            FROM Case
                            WHERE IsClosed = false 
                            ORDER BY CreatedDate DESC];
        return cases;
    }
    
    @AuraEnabled
    public static List<Case> retrieveMyCases(){
        List<Case> cases = [SELECT Id, CaseNumber, Status, Sub_Status__c, Type, Sub_Type__c, 
                                Date_Submitted__c, AccountId, Account.Name, OwnerId, Owner.Name
                            FROM Case 
                            WHERE OwnerId = :UserInfo.getUserId()
                                AND IsClosed = false
                            ORDER BY CreatedDate DESC];
        return cases;
    }
}