/*
* Batch class to be scheduled to run on 1st of every month and create assessment records for the previous month.

* Criteria: 1 AND 2 AND 3 AND 4 AND 5
* 1. Status of Taxpayer registration is 'Active'
* 2. Sub Status of Taxpayer registration is 'Completed'
* 3. Status of authorisation is either "Granted Unconditionally" or "Granted Conditionally" or "Suspended"
* 4. Start date of authorisation linked to taxpayer registration is in past.
* 5. End date of authorisation linked to taxpayer registration is greater than or equal to 1st of previous month (either in future or in previous month)
*/
global class LevyAssessmentsAutoCreatorBatch implements Database.Batchable<SObject> {
    
    String taxPayerRegistrationStatus = GlobalConstants.STATUS_ACTIVE; //'Active';
    String taxPayerRegistrationSubStatus = GlobalConstants.SUB_STATUS_COMPLETED; //'Completed';
    String authorisationStatusGrantedConditionally = GlobalConstants.GRANTED_CONDITIONALLY; //'Granted With Conditions';
    String authorisationStatusGrantedUnconditionally = GlobalConstants.GRANTED_UNCONDITIONALLY; //'Granted Unconditionally';
    String authorisationStatusSuspended = GlobalConstants.AUTHORISATION_SUSPENDED; //'Suspended';
    String authorisationStatusLapsed = GlobalConstants.AUTH_STATUS_LAPSED; //'Lapsed';
    String authorisationStatusCancelled = GlobalConstants.AUTHORISATION_STATUS_CANCELLED; //'Cancelled';
    
    // Constructor
    public LevyAssessmentsAutoCreatorBatch() {
        
    }
    
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String strQuery = 'SELECT Id, Status__c, Sub_Status__c, '
            + 'Service_Provider_Name__c, Exemption_Approved__c, Rebate_Approved__c, Rebate_Approval_Date__c, '
            + 'Booking_Service_Provider_Number__c, Taxi_Service_Provider_Number__c, '
            + 'Booking_Service_Provider_Number__r.Status__c, Booking_Service_Provider_Number__r.Decision_Date__c, '
            + 'Taxi_Service_Provider_Number__r.Status__c, Taxi_Service_Provider_Number__r.Decision_Date__c, '
            + 'Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c, '
            + 'Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c '
            + 'FROM Tax_Payer_Registration__c '
            + 'WHERE Status__c = :taxPayerRegistrationStatus '
            + 'AND ( '
            + '  (Booking_Service_Provider_Number__c != NULL '
            + '  AND (Booking_Service_Provider_Number__r.Status__c = :authorisationStatusGrantedConditionally '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusGrantedUnconditionally '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusSuspended '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusLapsed '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusCancelled ) ) '
            + '  OR '
            + '  (Taxi_Service_Provider_Number__c != NULL '
            + '  AND (Taxi_Service_Provider_Number__r.Status__c = :authorisationStatusGrantedConditionally '
            + '      OR Taxi_Service_Provider_Number__r.Status__c = :authorisationStatusGrantedUnconditionally '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusSuspended '
            + '      OR Booking_Service_Provider_Number__r.Status__c = :authorisationStatusLapsed '
            + '      OR Taxi_Service_Provider_Number__r.Status__c = :authorisationStatusCancelled ) ) '
            + '  ) ';
        
        System.debug(LoggingLevel.INFO, '== Generated Query ==' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    // Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Tax_Payer_Registration__c> scopeList) {
        
        try {
            
            System.debug(LoggingLevel.INFO, '== LevyAssessmentsAutoCreatorBatch execute - scope size ==' + scopeList.size());
            
            // Filter Tax Payer Registrations according to following criteria
            // Check Authorisation Dates
            // Start date of authorisation linked to taxpayer registration is in past.
            // End date of authorisation linked to taxpayer registration is greater than or equal to 1st of previous month (either in future or in previous month)
            Date firstDateOfPreviousMonth = System.today().addMonths(-1).toStartOfMonth();
            System.debug(LoggingLevel.INFO, '== firstOfPreviousMonth ==' + firstDateOfPreviousMonth);
            
            Date lastDateOfPreviousMonth = System.today().toStartOfMonth().addDays(-1);
            System.debug(LoggingLevel.INFO, '== lastDateOfPreviousMonth ==' + lastDateOfPreviousMonth);
            
            Boolean isAuthorisationCriteriaSatisfied = false;
            List<Tax_Payer_Registration__c> listTaxPayerRegistrations =  new List<Tax_Payer_Registration__c>();
            
            for(Tax_Payer_Registration__c taxpayerRegistrationRec : scopeList) {
                
                isAuthorisationCriteriaSatisfied = false;
        
                //To check if "Rebate Approval Date" is the anniversary month or not, 
                //subtract 1 month from Rebate Approval Date and match this month with levy period month
                Integer levyPeriodAnniversaryMonth = 0;
                if(taxpayerRegistrationRec.Rebate_Approval_Date__c != NULL) {
                    levyPeriodAnniversaryMonth = taxpayerRegistrationRec.Rebate_Approval_Date__c.addMonths(-1).month();
                }
                Integer levyPeriodMonth = lastDateOfPreviousMonth.month();
                
                if(taxpayerRegistrationRec.Exemption_Approved__c 
                   || (taxpayerRegistrationRec.Rebate_Approved__c && levyPeriodAnniversaryMonth != levyPeriodMonth)
                   || (taxpayerRegistrationRec.Rebate_Approved__c && levyPeriodAnniversaryMonth == levyPeriodMonth
                       && taxpayerRegistrationRec.Rebate_Approval_Date__c.year() >= System.today().year())) {
                      
                       // Dont' create Assessment here
                       continue;
                   }
                
                if(taxpayerRegistrationRec.Booking_Service_Provider_Number__c != NULL
                   && taxpayerRegistrationRec.Booking_Service_Provider_Number__r.Status__c == authorisationStatusCancelled
                   && taxpayerRegistrationRec.Booking_Service_Provider_Number__r.Decision_Date__c >= firstDateOfPreviousMonth) 
                {
                    isAuthorisationCriteriaSatisfied = true;
                }
                else if(taxpayerRegistrationRec.Booking_Service_Provider_Number__c != NULL
                        && taxpayerRegistrationRec.Booking_Service_Provider_Number__r.Status__c != authorisationStatusCancelled
                        && taxpayerRegistrationRec.Booking_Service_Provider_Number__r.Start_Date__c < Date.today()
                        && taxpayerRegistrationRec.Booking_Service_Provider_Number__r.End_Date__c >= firstDateOfPreviousMonth) 
                {
                    
                    isAuthorisationCriteriaSatisfied = true;
                }
                
                if(taxpayerRegistrationRec.Taxi_Service_Provider_Number__c != NULL
                   && taxpayerRegistrationRec.Taxi_Service_Provider_Number__r.Status__c == authorisationStatusCancelled
                   && taxpayerRegistrationRec.Taxi_Service_Provider_Number__r.Decision_Date__c >= firstDateOfPreviousMonth) 
                {
                    
                    isAuthorisationCriteriaSatisfied = true;
                }
                else if(taxpayerRegistrationRec.Taxi_Service_Provider_Number__c != NULL
                       && taxpayerRegistrationRec.Taxi_Service_Provider_Number__r.Status__c != authorisationStatusCancelled
                       && taxpayerRegistrationRec.Taxi_Service_Provider_Number__r.Start_Date__c < Date.today()
                       && taxpayerRegistrationRec.Taxi_Service_Provider_Number__r.End_Date__c >= firstDateOfPreviousMonth) 
                {
                    
                    isAuthorisationCriteriaSatisfied = true;
                }
                
                if(isAuthorisationCriteriaSatisfied) {
                    listTaxPayerRegistrations.add(taxpayerRegistrationRec);
                }
            }
            
            System.debug(LoggingLevel.INFO, '== LevyAssessmentsAutoCreatorBatch execute - Tax Payer Registrations size ==' + listTaxPayerRegistrations.size());
            
            // Create Assessment Records
            List<Assessment__c> listAssessments =  new List<Assessment__c>();
            
            for(Tax_Payer_Registration__c taxpayerRegistrationRecord : listTaxPayerRegistrations) {
                
                System.debug(LoggingLevel.INFO, '== Tax Payer Registration Record ==' + taxpayerRegistrationRecord);
                
                Assessment__c assessmentRecord = new Assessment__c();
                assessmentRecord.Account__c = taxpayerRegistrationRecord.Service_Provider_Name__c;
                assessmentRecord.Taxpayer_Registration__c = taxpayerRegistrationRecord.Id;
                assessmentRecord.Status__c = 'Open';
                assessmentRecord.Assessment_Type__c = 'Assessment';
                assessmentRecord.Period_Start_Date__c = firstDateOfPreviousMonth;
                assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
                
                // For rebate approved taxpayer, 
                // an assessment needs to be created on annual basis with levy period spanning across entire previous year.
                if(taxpayerRegistrationRecord.Rebate_Approved__c) {
                    
                    Integer levyPeriodAnniversaryMonth = 0;
                    if(taxpayerRegistrationRecord.Rebate_Approval_Date__c != NULL) {
                        levyPeriodAnniversaryMonth = taxpayerRegistrationRecord.Rebate_Approval_Date__c.addMonths(-1).month();
                    }
                    Integer levyPeriodMonth = lastDateOfPreviousMonth.month();
                    date today = system.today();
                    // Create assessment on Annual Basis
                    // We check these conditions here for safety net.
                    // Flow will not reach here is following conditions are not satisfied.
                    // Check Line 91
                    if(taxpayerRegistrationRecord.Rebate_Approved__c && levyPeriodAnniversaryMonth == levyPeriodMonth
                       && taxpayerRegistrationRecord.Rebate_Approval_Date__c.year() < System.today().year()) {
                           //assessmentRecord.Period_Start_Date__c = taxpayerRegistrationRecord.Rebate_Approval_Date__c.toStartOfMonth();
                           assessmentRecord.Period_Start_Date__c = today.addYears(-1).toStartOfMonth();
                           assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
                       }
                    
                } else {
                    
                    // Create assessment on Monthly Basis
                    assessmentRecord.Period_Start_Date__c = firstDateOfPreviousMonth;
                  assessmentRecord.Period_End_Date__c = lastDateOfPreviousMonth;
                }
                
                // Following field values are populated via trigger
                // On Creation of Assessment Record of type 'Assessment'
                
                //assessmentRecord.Payment_Due_Date__c = 
                //assessmentRecord.Issue_Date__c = 
                
                // Following field values are populated via trigger
                // On Creation of Assessment Record of type 'Assessment'
                
                //assessmentRecord.Annual_Estimates__c
                //assessmentRecord.Estimated_TSP_Transactions__c
                //assessmentRecord.Estimated_BSP_Transactions__c
                //assessmentRecord.Change_Code__c
                //assessmentRecord.Change_Comment__c
                //assessmentRecord.Levy__c
                //assessmentRecord.Rebate_Approved__c
                //assessmentRecord.Exemption_Approved__c
                //assessmentRecord.Rebate_Approval_Date__c
                //assessmentRecord.Levy_Contact__c
                //assessmentRecord.Payment_via_Sweep__c - This is always set to true for Assessment type Assessment
                
                listAssessments.add(assessmentRecord);
                
                System.debug(LoggingLevel.INFO, '== Assessment Record ==' + assessmentRecord);
            }
            
            if(listAssessments.size() > 0) {
                List<Database.SaveResult> results = Database.insert(listAssessments, false);
                for(Database.SaveResult result: results){
                    if(!result.isSuccess() && !result.getErrors().isEmpty()){
                        System.debug(LoggingLevel.ERROR, result.getErrors()[0].getMessage());
                    }
                }
            }
            
        } catch(Exception ex) {
            System.debug('LevyAssessmentsAutoCreatorBatch::execute' + ex);
        }
    }
    
    // Batch Finish Method
    global void finish(Database.BatchableContext BC) {
        // do nothing
    }
}