public class AgentsAdditionalInfo {

    @AuraEnabled
    public static List<Related_Contact__c> retrieveAgentAdditionalInformation(String id){
        List<Related_Contact__c> relatedContacts = [SELECT Id, Name, Email__c, Date_of_Birth__c 
                            						FROM Related_Contact__c 
                                                    WHERE Related_Application__c =: id];
        return relatedContacts;
    }
}