/*
 * @Description: Controller class to retrieve licence renewal application details.
 */
public without sharing class TaxiRenewalApplicationController{

    @AuraEnabled
    public static Case retrieveApplicationDetails(String caseId){
        System.debug(LoggingLevel.INFO, 'Retrieving case details for ' + caseId);
        List<Case> application = [SELECT Id, CaseNumber, Status, Sub_Status__c, 
                                    Authorisation__c, Authorisation__r.Name, Authorisation__r.End_Date__c,
                                    Authorisation__r.Licence_Class__c, Authorisation__r.Licence_Fee__c,
                                    Authorisation__r.Licence_Type__c, Authorisation__r.Operating_Locations__c,
                                    Authorisation__r.Operation_Area__c, Authorisation__r.Plate_Number__c,
                                    Authorisation__r.Start_Date__c, AccountId, Is_Privacy_Statement_Declared__c,
                                    Information_Declaration__c,
                                    (SELECT Id, TotalAmount, Payment_Method__c, Payment_Reference__c, Status FROM Orders__r)
                                FROM Case
                                WHERE Id = :caseId];
        Case applicationToReturn = null;
        if(!application.isEmpty()){
            applicationToReturn = application[0];
        }
        return applicationToReturn;
    }
    
    @AuraEnabled
    public static String getEntityType(String caseId) {
    
        //User loggedInUser = GlobalUtility.getLoggedInUser();                
        Case requiredCase = [SELECT AccountId, Account.Record_Type_Dev_Name__c FROM Case WHERE Id = :caseId];
        return GlobalUtility.getAccEntityType(requiredCase.Account.Record_Type_Dev_Name__c);
    }
    
    @AuraEnabled
    public static void saveApplication(Case application){
        System.debug(LoggingLevel.INFO, 'Application details received: ' + application);
        Database.update(application);
    }
}