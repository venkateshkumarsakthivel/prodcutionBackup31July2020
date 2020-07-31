public with sharing class ASPApplicationListController {
    public class BaseException extends Exception {}
    
    /*This function retrives all applications of Individual and company record type for a logged in user. */
    @AuraEnabled
    public static List<Case> retrieveApplications() {
        try{ 
            //Query for Getting logged in user
            User userRecord = GlobalUtility.getLoggedInUser();
            List<Case> applications = new List<Case>();
            
            
                
                // Query for retriving all applications of Individual and company record type for a logged in user
                applications = [SELECT Id, Service_Type__c, CaseNumber, Status, IsClosed, Sub_Status__c,
                                    RecordType.Name, Date_Submitted__c, Payment__r.Status, CreatedBy.Name 
                                FROM Case 
                                WHERE (RecordType.Name =: GlobalConstants.CASE_RECORDTYPE_INDIVIDUAL 
                                       OR RecordType.Name =: GlobalConstants.CASE_RECORDTYPE_CORPORATION
                                       OR RecordType.Name =: GlobalConstants.CASE_RECORDTYPE_PARTNERSHIP)
                                       AND ((Status = :GlobalConstants.CASE_DRAFT
                                            OR Status = :GlobalConstants.APPLICATION_STATUS_LODGED
                                            OR Status = :GlobalConstants.CASE_NEW)
                                            AND Sub_Status__c != :GlobalConstants.CASE_SUB_STATUS_GRANTED)  
                                ORDER BY CaseNumber DESC 
                                LIMIT 100];
            
            
            return applications;
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPApplicationListController','retrieveApplications',ex.getMessage(),ex);
            return null;      
        }
    }
    
    
    /* Method for updating Application and Authorisation__c statuses to 'Withdrawn' and 'Cancelled' respectively.
* Note: If the Authorisation Record is locked by approval process, then a batch is running in the background which updates respective record for an application.
*/
    
    @AuraEnabled
    public static String withdrawASPApplication(Case caseRec) {
        try{
           User userRecord = GlobalUtility.getLoggedInUser();

            caseRec.Decision_Made_By__c = userRecord.Id;
            update caseRec;
            
            String CurrentDatetring = system.today().format();
            Date currentDate = date.parse(CurrentDatetring);
            List<Authorisation__c> authRecordsToUpdate = new List<Authorisation__c>();
            for(Authorisation__c authRecord :[SELECT Id, Decision_Reason__c, Decision_Date__c, Decision_Made_By__c  
                                              FROM Authorisation__c 
                                              WHERE Application__c =: caseRec.Id]){
                                                  
                                                  if(!Approval.isLocked(authRecord.Id)){
                                                      authRecord.Status__c= GlobalConstants.AUTHORISATION_STATUS_CANCELLED;
                                                      authRecord.Decision_Reason__c = GlobalConstants.AUTHORISATION_DECISION_REASON;
                                                      authRecord.Decision_Date__c = currentDate;
                                                      authRecord.Decision_Made_By__c =userRecord.id;
                                                      authRecordsToUpdate.add(authRecord);
                                                  } 
                                              }
            update authRecordsToUpdate;
            
            return GlobalConstants.SUCCESS_MESSAGE_TO_BE_RETURNED;
            
        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'ASPApplicationListController','withdrawASPApplication',ex.getMessage(),ex);
            return null;      
        }
    }
}