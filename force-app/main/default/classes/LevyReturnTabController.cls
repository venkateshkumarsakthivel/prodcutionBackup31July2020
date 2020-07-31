/**
* Server side rest resource controller for levy return tab
*/
public with sharing class LevyReturnTabController {
    
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
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','getAccountDetails',ex.getMessage(),ex);
            return null;
        }
    }
    
    //function returns authorisations from logged in user's account
    @AuraEnabled
    public static List<Authorisation__c> getAccountAuthorisations() {   
        
        List<Authorisation__c> listAuthorisations = new List<Authorisation__c>();
        
        User loggedInUser = GlobalUtility.getLoggedInUser();
            
        String accountId = loggedInUser.AccountId;
                  
        listAuthorisations = [SELECT Id, Authorisation_Type__c, Name, End_Date__c, Start_Date__c
                              FROM Authorisation__c
                              WHERE Service_Provider__c = :accountId
                              AND (Status__c = :GlobalConstants.GRANTED_UNCONDITIONALLY
                                   OR Status__c = :GlobalConstants.GRANTED_CONDITIONALLY 
                                   OR Status__c = :GlobalConstants.AUTHORISATION_SUSPENDED
                                   OR Status__c = :GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                                   OR Status__c = :GlobalConstants.AUTH_STATUS_LAPSED)
                              ORDER BY LastModifiedDate ASC];
            
        return listAuthorisations;
    }
    
    /* This function retrives Tax Payer Registation details logged in User */
    @AuraEnabled
    public static Tax_Payer_Registration__c getTaxPayerRegistrationDetails(){
    
        List<Tax_Payer_Registration__c> tpr = new List<Tax_Payer_Registration__c>();
        User user = GlobalUtility.getLoggedInUser();
        
        tpr = [SELECT Id, Applied_For_Exemption__c, Applied_For_Rebate__c, Rebate_Approval_Date__c, 
               Rebate_Approved__c, Rebate_Rejected__c, Exemption_Approved__c, Annual_Trip_Estimate__c, Privacy_Declaration__c,Exemption_Approval_Date__c
               FROM Tax_Payer_Registration__c
               WHERE Service_Provider_Name__c = :user.AccountId 
               AND Status__c = :GlobalConstants.STATUS_ACTIVE 
               ORDER BY createdDate DESC Limit 1];
               
        return tpr.size() > 0 ? tpr[0] : NULL;
    }
    
    /* This function retrives assessment details for logged in User */
    @AuraEnabled
    public static Assessment__c getAssessmentDetails(){
        
        List<Assessment__c> openAssessments = new List<Assessment__c>();
        User user = GlobalUtility.getLoggedInUser();
        Tax_Payer_Registration__c activeTPR = getTaxPayerRegistrationDetails();
        Date rebateApprovalDate = activeTPR.Rebate_Approval_Date__c;
        Date levyReturnPeriodStartDate, levyReturnPeriodEndDate;
        
        String queryAssements = 'SELECT Period_End_Date__c, Period_Start_Date__c, Payment_Due_Date__c,Status__c, Account__c, Taxpayer_Registration__c, BSP_Transaction_Count__c,TSP_Transaction_Count__c';

        queryAssements +=  ' FROM Assessment__c WHERE Account__c = \''+user.AccountId+'\'';
        queryAssements +=  ' AND Status__c = \''+ GlobalConstants.ASSESSMENT_STATUS_OPEN+'\'';
 
        if(activeTPR.Applied_For_Rebate__c == GlobalConstants.YES_VALUE
           && activeTPR.Rebate_Approved__c){
               System.debug('In');
               
               if(activeTPR.Rebate_Approval_Date__c >= System.Today().addMonths(-1).toStartOfMonth()
                  && activeTPR.Rebate_Approval_Date__c < System.Today().toStartOfMonth()){
                      
                      levyReturnPeriodStartDate = System.Today().addMonths(-1).toStartOfMonth();
                      Integer numberOfDaysInMonth = Date.daysInMonth(System.Today().addMonths(-1).Year(), System.Today().addMonths(-1).Month());
                      levyReturnPeriodEndDate = Date.newInstance(levyReturnPeriodStartDate.Year(), levyReturnPeriodStartDate.Month(), numberOfDaysInMonth); 
                  }
               else{
                   // Srikanth Sunkara -> Hot fix P2PSUPPORT-296 for leap year correcting the end date.
                   // date: 04/03/2020
                   if(Date.isLeapYear(System.Today().Year())){
                       rebateApprovalDate = activeTPR.Rebate_Approval_Date__c;
                       levyReturnPeriodStartDate = Date.newInstance(System.Today().Year()-1, rebateApprovalDate.Month(),rebateApprovalDate.Day()).toStartOfMonth();
                       levyReturnPeriodEndDate = Date.newInstance(levyReturnPeriodStartDate.addDays(-1).Year()+1, levyReturnPeriodStartDate.addDays(-1).Month(), levyReturnPeriodStartDate.addYears(1).addDays(-1).Day());   
                       
                   }
                   else{
                       rebateApprovalDate = activeTPR.Rebate_Approval_Date__c;
                       levyReturnPeriodStartDate = Date.newInstance(System.Today().Year()-1, rebateApprovalDate.Month(),rebateApprovalDate.Day()).toStartOfMonth();
                       levyReturnPeriodEndDate = Date.newInstance(levyReturnPeriodStartDate.addDays(-1).Year()+1, levyReturnPeriodStartDate.addDays(-1).Month(), levyReturnPeriodStartDate.addDays(-1).Day());
                   }
               } 
               // Modified on 18 July 2019: As part of P2PSUPPORT-244 
                queryAssements += ' AND Period_Start_Date__c =: levyReturnPeriodStartDate' ;
                queryAssements += ' AND Period_End_Date__c =: levyReturnPeriodEndDate';
                queryAssements += ' ORDER BY createdDate DESC Limit 1';
        }else {
                /*
                Modified on : 18 July 2019: P2PSUPPORT-244 : Assesment not getting displayed on the portal:
                If the rebate is approved, look for the end date on the Assement, this is cover both monthly and yearly assesments which are Active 
                */
                      levyReturnPeriodStartDate = System.Today().addMonths(-1).toStartOfMonth();
                      Integer numberOfDaysInMonth = Date.daysInMonth(System.Today().addMonths(-1).Year(), System.Today().addMonths(-1).Month());
                      levyReturnPeriodEndDate = Date.newInstance(levyReturnPeriodStartDate.Year(), levyReturnPeriodStartDate.Month(), numberOfDaysInMonth); 

                queryAssements += ' AND Period_End_Date__c =: levyReturnPeriodEndDate';
                queryAssements += ' ORDER BY createdDate DESC Limit 1';

        }
        System.debug('Start Date >>>'+levyReturnPeriodStartDate);
        System.debug('End Date >>>'+levyReturnPeriodEndDate);
        System.debug('queryAssements >>>'+queryAssements);

        openAssessments = Database.query(queryAssements);

        system.debug('openAssessments >>>>'+openAssessments);

        return openAssessments.size() > 0 ? openAssessments[0] : NULL;                   
    }
    
    /* This function updates levy return details on specified assessment record */
    @AuraEnabled
    public static Boolean submitLevyReturn(Assessment__c returnAssessment){
       
       try {
          
          update returnAssessment;
          return TRUE;
       }
       catch(Exception ex) {
         
         ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyRegistrationTabController','submitLevyReturn',ex.getMessage(),ex);
         return FALSE;
       }
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
                                                          OR (Taxi_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                                                               AND Taxi_Service_Provider_Number__r.Decision_Date__c >= :firstDateOfPreviousMonth)
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
                                                    OR (Booking_Service_Provider_Number__r.Status__c = :GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                                                               AND Booking_Service_Provider_Number__r.Decision_Date__c >= :firstDateOfPreviousMonth)
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
}