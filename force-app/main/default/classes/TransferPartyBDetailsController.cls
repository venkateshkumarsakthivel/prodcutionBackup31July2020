/*
 * @Description: Controller class for transfer party B application
 */
public without sharing class TransferPartyBDetailsController {

    @AuraEnabled
    public static Case retrieveApplicationDetails(String caseId){
        List<Case> applications = [SELECT Id, AccountId, Authorisation__r.Name, Authorisation__r.End_Date__c, 
                                        Authorisation__r.Operation_Area__c, Authorisation__r.Term__c, Levy_Due__c, Licence_Fee_Due__c,
                                        Notice_Address_City__c, Notice_Address_Country__c, Notice_Address_Postal_Code__c, Notice_Address_State__c,
                                        Notice_Address_Street__c, Notice_Email__c, Preferred_method_of_comm_for_notice__c, Is_Privacy_Statement_Declared__c,
                                        Information_Declaration__c, Status, Sub_Status__c
                                    FROM Case WHERE Id = :caseId];
        Case caseRec = new Case();          
        if(!applications.isEmpty()){
            caseRec = applications[0];
        }
        return caseRec;
    }
    
    @AuraEnabled
    public static Case saveApplicationDetails(Case application){
        update application;
        return application;
    }
    
    @AuraEnabled
    public static String getEntityType(String applicantAccountId, String caseId) {
        return TaxiFormSectionDataController.getEntityType(applicantAccountId, caseId);
    }
}