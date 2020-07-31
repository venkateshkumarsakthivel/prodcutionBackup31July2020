/**
* Server side rest resource controller for levy assessment tab
*/
public without sharing class LevyAssessmentTabController {
    
    /* This function retrives Account details logged in user. */
    @AuraEnabled
    public static Account getAccountDetails(){
        
        try {
            
            User user = GlobalUtility.getLoggedInUser();
            
            Account acc = [SELECT Id, Name, Customer_Number__c, ABN__c
                           FROM Account
                           WHERE Id =: user.AccountId];
           
            return acc;
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyAssessmentTabController ','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    //function returns assessment list from logged in user's account
    @AuraEnabled
    public static List<Assessment__c> getAccountAssessments() {   
        
        List<Assessment__c> listAssessments = new List<Assessment__c>();
        
        User loggedInUser = GlobalUtility.getLoggedInUser();
            
        String accountId = loggedInUser.AccountId;
                  
        listAssessments = [SELECT Period_Start_Date__c, Period_End_Date__c, Issue_Date__c, Account__c, Account__r.Name,
                           Assessment_Type__c, Status__c, Total_Levy_Amount__c, Can_Raise_An_Objection__c,
                           Estimated_BSP_Transactions__c, Estimated_TSP_Transactions__c, Payment_Due_Date__c,
                           Levy__c, BSP_Transaction_Count__c, TSP_Transaction_Count__c, Taxpayer_Registration__c,
                           Taxpayer_Registration__r.Booking_Service_Provider_Number__c, Taxpayer_Registration__r.Taxi_Service_Provider_Number__c,
                           Taxpayer_Registration__r.Booking_Service_Provider_Number__r.Name, Taxpayer_Registration__r.Taxi_Service_Provider_Number__r.Name,
                           Levy_Assessment_Period__c
                           FROM Assessment__c
                           WHERE Account__c = :accountId
                           AND Status__c != :GlobalConstants.STATUS_SUPERSEDED
                           AND Status__c != :GlobalConstants.ASSESSMENT_STATUS_OPEN
                           ORDER BY Period_Start_Date__c DESC];
          
        
        return listAssessments;
    }
    
    //function to validate if service provider had an active/suspended TSP authorisation during the
    //assessment period
    @AuraEnabled
    public static Boolean hadTSPAuthorisation(Assessment__c tempAssessment) { 
      
      System.debug('Assessment Received: '+tempAssessment);
      
      Set<String> activeAuthStatuses = new Set<String>();
      activeAuthStatuses.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
      activeAuthStatuses.add(GlobalConstants.GRANTED_CONDITIONALLY);
      activeAuthStatuses.add(GlobalConstants.AUTHORISATION_SUSPENDED);
      
      Date firstDateOfPreviousMonth = System.today().addMonths(-1).toStartOfMonth();
       
      List<Tax_Payer_Registration__c> relatedTPR = [SELECT Booking_Service_Provider_Number__c, Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c, 
                                                    Taxi_Service_Provider_Number__c, Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c
                                                    FROM Tax_Payer_Registration__c 
                                                    WHERE Id = :tempAssessment.Taxpayer_Registration__c
                                                    AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                    AND Taxi_Service_Provider_Number__c != NULL
                                                    AND (Taxi_Service_Provider_Number__r.Status__c IN :activeAuthStatuses
                                                          OR (Taxi_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTHORISATION_STATUS_CANCELLED)
                                                               //AND Taxi_Service_Provider_Number__r.Decision_Date__c >= :firstDateOfPreviousMonth)
                                                          OR (Taxi_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTH_STATUS_LAPSED
                                                               AND Taxi_Service_Provider_Number__r.End_Date__c >= :firstDateOfPreviousMonth
                                                               AND Taxi_Service_Provider_Number__r.Start_Date__c < :Date.today()))];
      
      System.debug('TPR Received: '+relatedTPR);
                                                     
      if(relatedTPR.size() == 0)
        return FALSE;
      
      if(tempAssessment.Period_Start_Date__c >= relatedTPR[0].Taxi_Service_Provider_Number__r.Start_Date__c
          || tempAssessment.Period_End_Date__c <= relatedTPR[0].Taxi_Service_Provider_Number__r.End_Date__c)
        return TRUE;
      
      return FALSE;
    }
    
    //function to validate if service provider had an active/suspended BSP authorisation during the
    //assessment period
    @AuraEnabled
    public static Boolean hadBSPAuthorisation(Assessment__c tempAssessment) { 
      
      System.debug('Assessment Received: '+tempAssessment);
      
      Set<String> activeAuthStatuses = new Set<String>();
      activeAuthStatuses.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
      activeAuthStatuses.add(GlobalConstants.GRANTED_CONDITIONALLY);
      activeAuthStatuses.add(GlobalConstants.AUTHORISATION_SUSPENDED);
      
      Date firstDateOfPreviousMonth = System.today().addMonths(-1).toStartOfMonth();
      
      List<Tax_Payer_Registration__c> relatedTPR = [SELECT Booking_Service_Provider_Number__c, Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c, 
                                                    Taxi_Service_Provider_Number__c, Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c
                                                    FROM Tax_Payer_Registration__c 
                                                    WHERE Id = :tempAssessment.Taxpayer_Registration__c
                                                    AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                    AND Booking_Service_Provider_Number__c != NULL
                                                    AND (Booking_Service_Provider_Number__r.Status__c IN :activeAuthStatuses
                                                    OR (Booking_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTHORISATION_STATUS_CANCELLED)
                                                               //AND Booking_Service_Provider_Number__r.Decision_Date__c >= :firstDateOfPreviousMonth)
                                                          OR (Booking_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTH_STATUS_LAPSED
                                                               AND Booking_Service_Provider_Number__r.End_Date__c >= :firstDateOfPreviousMonth
                                                               AND Booking_Service_Provider_Number__r.Start_Date__c < :Date.today()))];
      
      System.debug('TPR Received: '+relatedTPR);
                                                  
      if(relatedTPR.size() == 0)
        return FALSE;
      
      if(tempAssessment.Period_Start_Date__c >= relatedTPR[0].Booking_Service_Provider_Number__r.Start_Date__c
          || tempAssessment.Period_End_Date__c <= relatedTPR[0].Booking_Service_Provider_Number__r.End_Date__c)
        return TRUE;
        
      return FALSE;
    }
    
    //function to validate is rebate approval date is before levy period end date
    @AuraEnabled
    public static Boolean wasRebateApproved(Assessment__c tempAssessment){
      
       List<Tax_Payer_Registration__c> relatedTPR = [SELECT Rebate_Approval_Date__c
                                                     FROM Tax_Payer_Registration__c 
                                                     WHERE Id = :tempAssessment.Taxpayer_Registration__c
                                                     AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                     AND Rebate_Approval_Date__c != NULL];
                                                     
       return relatedTPR.size() > 0 && relatedTPR[0].Rebate_Approval_Date__c <= tempAssessment.Period_End_Date__c ? TRUE : FALSE;
          
    }
    
    //function to initialise and construct levy objection case
    @AuraEnabled
    public static Case initialiseObjectionCase(Assessment__c pAssessment){
      
       User loggedInUser = GlobalUtility.getLoggedInUser();
       
       Case caseRec = new Case();
       Id levyObjectionCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Levy_OBJECTION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
       Group aspLevel2Queue = [SELECT Id, DeveloperName, Type FROM Group where Type = :GlobalConstants.QUEUE And DeveloperName = :GlobalConstants.ASP_LEVEL_2_QUEUE_DEV_NAME limit 1];
       
       caseRec.OwnerId = aspLevel2Queue.Id;
       caseRec.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
       caseRec.Sub_Type__c = GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE;
       
       caseRec.AccountId = loggedInUser.AccountId;
       // Modified for P2PSUPPORT-152
       // Consider Levy Contact on objection casea
       // caseRec.ContactId = loggedInUser.ContactId;
       caseRec.ContactId = getLevyContactFromTPR(pAssessment.Taxpayer_Registration__c);
       caseRec.Status = GlobalConstants.CASE_NEW;
       caseRec.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING;
       caseRec.Date_Submitted__c = System.Today();
       caseRec.Subject = GlobalConstants.LEVY_OBJECTION_SUBJECT;
       caseRec.RecordTypeId = levyObjectionCaseRecordTypeId;
       
       return caseRec;
    }
    
    //function to initialise and construct levy objection case
    @AuraEnabled
    public static Boolean hasOpenObjectionCase(String relatedAssessmentId){
      
       List<Case> relatedOpenObjectionCases = [SELECT Type, Sub_Type__c, Status, Sub_Status__c
                                               FROM Case
                                               WHERE Assessment__c = :relatedAssessmentId
                                               AND Type = :GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                                               AND Sub_Type__c = :GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE
                                               AND isClosed = FALSE];
                                          
       return relatedOpenObjectionCases.size() > 0 ? true : false;
    }
    
    //function to create levy objection case
    @AuraEnabled
    public static Boolean submitLevyObjection(Case levyObjectionCase) {
      
     try {
       
       //fix for PPT-8
       if(hasOpenObjectionCase(levyObjectionCase.Assessment__c))
           return false;
         
       Database.DMLOptions dmo = new Database.DMLOptions();
       dmo.assignmentRuleHeader.useDefaultRule = TRUE;
       levyObjectionCase.setOptions(dmo);
       
       insert levyObjectionCase;
       
        /* Fetching list of attachments related to registration, which are tagged against the account 
         * and tagging them against the newly created exemption/rebate case record.
         */
         List<Attachment> attachments = [Select ParentId, Name, Id, Description, Body 
                                         FROM Attachment 
                                         WHERE ParentId = :levyObjectionCase.Assessment__c
                                         AND Name LIKE 'LevyObjection%'];
                                            
         List<Attachment> newAttachments = new List<Attachment>();
        
         for(Attachment attach : attachments){
            
          Attachment file = new Attachment();
          file.ParentId = levyObjectionCase.Id;
          file.Name = attach.Name;
          file.Description = attach.Description;
          file.Body = attach.Body;
            
          newAttachments.add(file);        
         }
            
         insert newAttachments;
        
         GlobalUtility.ALLOW_FILE_DELETE = true;
         delete attachments;
         
         return true;
      }
      catch(Exception e) {
         
         System.debug('Exception: '+e.getLineNumber());
         ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'LevyAssessmentTabController', 'submitLevyObjection', e.getMessage(), e);
         return false;
      }
    }

    private static Id getLevyContactFromTPR(Id pTPRId){
        return [SELECT Levy_Contact__c FROM Tax_Payer_Registration__c WHERE Id = :pTPRId].Levy_Contact__c;
    }
}