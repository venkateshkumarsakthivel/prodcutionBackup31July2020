public with sharing class TaxiApplicationListController {
    
    /*This function retrives all applications of Individual and company record type for a logged in user. */
    @AuraEnabled
    public static List<Case> retrieveApplications() {
        //Query for Getting logged in user
        User userRecord = GlobalUtility.getLoggedInUser();
        List<Case> applications = new List<Case>();
        
        // Query for retriving all applications of Individual and company record type for a logged in user
        applications = [SELECT Id, Service_Type__c, CaseNumber, Status, Sub_Status__c, Sub_Type__c, IsClosed, RecordType.Name, Date_Submitted__c,
                        Tender_Number__c, Is_WAT_Application__c
                        FROM Case 
                        WHERE IsClosed = false 
                        AND (RecordType.Name =: GlobalConstants.TAXI_INDIVIDUAL_APPLICATION 
                             OR RecordType.Name =: GlobalConstants.TAXI_CORPORATION_APPLICATION
                             OR RecordType.Name =: GlobalConstants.TAXI_JOINT_HOLDER_APPLICATION
                             OR (RecordType.Name =: GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME 
                                 AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_OWNER) 
                             )
                        ORDER BY CaseNumber DESC 
                        LIMIT 100];
    
        return applications;
    }
}