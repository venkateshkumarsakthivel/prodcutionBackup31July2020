/**
* Server side rest resource controller for levy assessment new creation action
*/
public without sharing class LevyNewAssessmentController {
   
   /* This function retrives active TPR record's details for specified account */
   @AuraEnabled
   public static Tax_Payer_Registration__c getTPRDetails(String accountId){
    
     List<Tax_Payer_Registration__c> tpr = [SELECT Id, Applied_For_Exemption__c, Applied_For_Rebate__c, Rebate_Approval_Date__c, 
                                               Rebate_Approved__c, Rebate_Rejected__c, Exemption_Approved__c, Annual_Trip_Estimate__c, Privacy_Declaration__c,
                                               Service_Provider_Name__c, Levy_Contact__c,Exemption_Approval_Date__c
                                               FROM Tax_Payer_Registration__c
                                               WHERE Service_Provider_Name__c = :accountId
                                               AND Status__c = :GlobalConstants.STATUS_ACTIVE 
                                               ORDER BY createdDate DESC Limit 1];
                                               
     return tpr.size() > 0 ? tpr[0] : NULL;
   }
   
   /* This function retrives all assessments matching for specified levy period */
   @AuraEnabled
   public static List<Assessment__c> retrieveMatchingAssessments(String levyStartDate, Tax_Payer_Registration__c activeTPR){
       
     try {  
       
       System.debug('Start Date: '+levyStartDate);
       
       List<Assessment__c> matchingAssessments = [SELECT Name, Assessment_Type__c, Status__c, TSP_Transaction_Count__c, BSP_Transaction_Count__c,
                                                  Issue_Date__c, Total_Levy_Amount__c, Period_Start_Date__c, Period_End_Date__c
                                                  FROM Assessment__c
                                                  WHERE Taxpayer_Registration__c = :activeTPR.Id
                                                  AND Account__c = :activeTPR.Service_Provider_Name__c 
                                                  AND Period_Start_Date__c = :Date.parse(levyStartDate)
                                                  ORDER BY CreatedDate DESC];
       return matchingAssessments;
     }
     catch(Exception ex) {
            
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyNewAssessmentController','retrieveMatchingAssessments',ex.getMessage(),ex);
       return NULL;
     }
   }
   
   /* This function retrives all assessments matching for specified levy period */
   @AuraEnabled
   public static String retrieveLevyEndDate(String levyStartDate, Tax_Payer_Registration__c activeTPR){
     
     Date levyEndDate;
     
     if(activeTPR.Rebate_Approved__c && activeTPR.Rebate_Approval_Date__c != NULL) {
         //&& activeTPR.Rebate_Approval_Date__c < Date.parse(levyStartDate)
         Integer levyEndDateYear = Date.parse(levyStartDate).Month() == 1 ? Date.parse(levyStartDate).Year() : Date.parse(levyStartDate).Year()+1;
         Integer numberOfDaysInMonth = Date.daysInMonth(levyEndDateYear, Date.parse(levyStartDate).addMonths(-1).Month());
         
         levyEndDate = Date.newInstance(levyEndDateYear, Date.parse(levyStartDate).addMonths(-1).Month(), numberOfDaysInMonth); 
      }
      else {
         
         Integer numberOfDaysInMonth = Date.daysInMonth(Date.parse(levyStartDate).Year(), Date.parse(levyStartDate).Month());
         levyEndDate = Date.newInstance(Date.parse(levyStartDate).Year(), Date.parse(levyStartDate).Month(), numberOfDaysInMonth);
         
      }
      
      return String.valueOf(levyEndDate);
   }
   
   /* This function creates case record for initial assessment or reassessment 
    * based on whether matching assessments are present or not. 
    */
   @AuraEnabled
   public static Case createCaseRecord(String levyStartDate, Tax_Payer_Registration__c activeTPR, String category, String reasonCode, String description) {
     
     try {
       
       Case caseRec = new Case();
       Id levyAdministrationcCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_NAME).getRecordTypeId();
       
       caseRec.Type = GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY;
       caseRec.AccountId = activeTPR.Service_Provider_Name__c;
       caseRec.ContactId = activeTPR.Levy_Contact__c;
       caseRec.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_INPROGRESS;
       caseRec.Tax_Payer_Registration__c = activeTPR.Id;
       caseRec.Assessment_Start_Date__c = Date.parse(levyStartDate);
       caseRec.Status = GlobalConstants.CASE_STATUS_IN_PROGRESS;
       caseRec.RecordTypeId = levyAdministrationcCaseRecordTypeId;
       caseRec.Case_Reason_Description__c = description;
       caseRec.Case_Reason_Code__c = reasonCode;
       
       List<Assessment__c> matchingAssessments = retrieveMatchingAssessments(levyStartDate, activeTPR); 
       
       String assessmentType = matchingAssessments.size() > 0 ? 'Reassessment' : 'Assessment'; 
       
       caseRec.Sub_Type__c = assessmentType+' - '+category;
       
       String tempLevyStartDate = DateTime.newInstance(Date.parse(levyStartDate).year(), Date.parse(levyStartDate).month(), Date.parse(levyStartDate).day()).format('MMM YYYY');
       
       caseRec.Subject = matchingAssessments.size() > 0 ? GlobalConstants.CASE_SUBJECT_INITIAL_REASSESSMENT : GlobalConstants.CASE_SUBJECT_INITIAL_ASSESSMENT;
       caseRec.Description = matchingAssessments.size() > 0 ? GlobalConstants.CASE_DESCRIPTION_INITIAL_REASSESSMENT : GlobalConstants.CASE_DESCRIPTION_INITIAL_ASSESSMENT;
       caseRec.Description += ' '+tempLevyStartDate;
       caseRec.Assessment__c = matchingAssessments.size() > 0 ? matchingAssessments[0].Id : NULL;
       
       if(activeTPR.Rebate_Approved__c && activeTPR.Rebate_Approval_Date__c != NULL ) {
       //&& activeTPR.Rebate_Approval_Date__c < Date.parse(levyStartDate)  
         Integer levyEndDateYear = Date.parse(levyStartDate).Month() == 1 ? Date.parse(levyStartDate).Year() : Date.parse(levyStartDate).Year()+1;
         Integer numberOfDaysInMonth = Date.daysInMonth(levyEndDateYear, Date.parse(levyStartDate).addMonths(-1).Month());
         
         caseRec.Assessment_End_Date__c = Date.newInstance(levyEndDateYear, Date.parse(levyStartDate).addMonths(-1).Month(), numberOfDaysInMonth); 
       }
       else {
         
         Integer numberOfDaysInMonth = Date.daysInMonth(Date.parse(levyStartDate).Year(), Date.parse(levyStartDate).Month());
         caseRec.Assessment_End_Date__c = Date.newInstance(Date.parse(levyStartDate).Year(), Date.parse(levyStartDate).Month(), numberOfDaysInMonth);
       }
       insert caseRec;
       
       caseRec = [SELECT CaseNumber FROM Case WHERE Id = :caseRec.Id];
       
       return caseRec;
     }
     catch(Exception ex) {
            
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyNewAssessmentController','createCaseRecord',ex.getMessage(),ex);
       return NULL;
     }
   }
   
   //method to validate if logged in user from salesforce (non-community) is authorised to create levy assessments or not
   @AuraEnabled
   public static Boolean hasLevyAssessmentAccess(){
      
       //set to store names of profiles which can perform levy registration
       Set<String> registrationAllowedProfileNames = new Set<String>();
        
       //fetching names of profiles configure in metadata Levy_Registration_Allowed_Profile__mdt
       List<Levy_Registration_Allowed_Profile__mdt> levyRegistrationAllowedProfiles = [SELECT DeveloperName, Label
                                                                                       FROM Levy_Registration_Allowed_Profile__mdt];
        
       System.debug('List: '+levyRegistrationAllowedProfiles);
        
       //storing names of profiles which can delete attachments
       for(Levy_Registration_Allowed_Profile__mdt tempAllowedProfile : levyRegistrationAllowedProfiles)
        registrationAllowedProfileNames.add(tempAllowedProfile.Label);
        
       User loggedInUser = GlobalUtility.getLoggedInUser();
       if(registrationAllowedProfileNames.contains(loggedInUser.Profile.Name))
         return true;
       
       return false;
    }
}