/*
* Class to ensure that assessment period start date is always 1st day of selected month
* and end date is last day of selected month
* If Rebate Approved is True, then Assessment Perios is Annual
*/
public with sharing class AssessmentPeriodCalculator {
    
    public void calculatePeriod(List<Assessment__c> newAssessments) {
        
        try {
            
            for(Assessment__c tempAssessment : newAssessments) {
                
                //if start date is specified
                if(tempAssessment.Period_Start_Date__c != NULL) {
                    
                    if(tempAssessment.Rebate_Approved__c && tempAssessment.Rebate_Approval_Date__c != NULL) {
                        //&& (tempAssessment.Period_Start_Date__c <= tempAssessment.Rebate_Approval_Date__c)
                        tempAssessment.Period_Start_Date__c = Date.newInstance(tempAssessment.Period_Start_Date__c.Year(), tempAssessment.Rebate_Approval_Date__c.Month(), 01);                       
                        Integer numberOfDaysInMonth = Date.daysInMonth(tempAssessment.Period_Start_Date__c.Year()+1, tempAssessment.Period_Start_Date__c.addMonths(-1).Month());
                        Integer levyEndDateYear = tempAssessment.Period_Start_Date__c.Month() == 1 ? tempAssessment.Period_Start_Date__c.Year() : tempAssessment.Period_Start_Date__c.Year()+1;
                        tempAssessment.Period_End_Date__c = Date.newInstance(levyEndDateYear, tempAssessment.Period_Start_Date__c.addMonths(-1).Month(), numberOfDaysInMonth);
                        
                    } else {
                        
                        tempAssessment.Period_Start_Date__c = tempAssessment.Period_Start_Date__c.toStartOfMonth();
                        
                        Integer numberOfDaysInMonth = Date.daysInMonth(tempAssessment.Period_Start_Date__c.Year(), tempAssessment.Period_Start_Date__c.Month());
                        tempAssessment.Period_End_Date__c = Date.newInstance(tempAssessment.Period_Start_Date__c.Year(), tempAssessment.Period_Start_Date__c.Month(), numberOfDaysInMonth);     
                       
                        System.debug(newAssessments);   
                        
                    }
                    
                }
                
                //if end date is specified but not start date
                if(tempAssessment.Period_End_Date__c != NULL
                   && tempAssessment.Period_Start_Date__c == NULL) {
                       
                       if(tempAssessment.Rebate_Approved__c && tempAssessment.Rebate_Approval_Date__c != NULL) {
                           
                           Integer numberOfDaysInMonth = Date.daysInMonth(tempAssessment.Period_End_Date__c.Year(), tempAssessment.Period_End_Date__c.Month());
                           tempAssessment.Period_End_Date__c = Date.newInstance(tempAssessment.Period_End_Date__c.Year(), tempAssessment.Rebate_Approval_Date__c.Month(), numberOfDaysInMonth);
                           Integer levyStartDateYear = tempAssessment.Period_End_Date__c.Month() == 12 ? tempAssessment.Period_End_Date__c.Year() : tempAssessment.Period_End_Date__c.Year()-1;
                          
                           tempAssessment.Period_Start_Date__c = Date.newInstance(levyStartDateYear, tempAssessment.Period_End_Date__c.addMonths(1).Month(), 01);
                        
                       } else {
                           
                           tempAssessment.Period_Start_Date__c = tempAssessment.Period_End_Date__c.toStartOfMonth();
                           Integer numberOfDaysInMonth = Date.daysInMonth(tempAssessment.Period_End_Date__c.Year(), tempAssessment.Period_End_Date__c.Month());
                           tempAssessment.Period_End_Date__c = Date.newInstance(tempAssessment.Period_End_Date__c.Year(), tempAssessment.Period_End_Date__c.Month(), numberOfDaysInMonth); 
                       }
                   }
            }
        }
        catch(Exception ex) {
            
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AssessmentPeriodCalculator','calculatePeriod',ex.getMessage(),ex);
        }
    }

    public void calculateReminderReturnDates(List<Assessment__c> newAssessments) {
        
        //Calculation for Final return reminder date. 2 business days before end of next month from Period End Date.
        Map<Id, Date> mNextMonthEndDateById = new Map<Id, Date>();
        try {
            
            for(Assessment__c assmt : newAssessments) {
                if(assmt.Period_End_Date__c != NULL){
                    Date dNextMonth = assmt.Period_End_Date__c.addMonths(1);
                    Integer numberOfDaysInMonth = Date.daysInMonth(dNextMonth.Year(), dNextMonth.Month()); 
                    mNextMonthEndDateById.put(assmt.Id, Date.newInstance(dNextMonth.Year(), dNextMonth.Month(), numberOfDaysInMonth));
                    
                }
            }

            BusinessHours bh = GlobalUtility.getDefaultBusinessHours();

            for(Assessment__c assmt : newAssessments) {
                assmt.Conga_Return_last_business_date__c = getReminderReturnDate(2, bh, mNextMonthEndDateById.get(assmt.Id));
            }
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AssessmentPeriodCalculator','calculateReminderReturnDates',ex.getMessage(),ex);
        }
    }

    /**
     *  @author         Abhi Indulkar
     *  @date           15/11/2018
     *  @description    This method return the date 2 business days prior from month end date
     *  @param          daysAdvanced        - determins how many business days in advance
     *  @param          bh                  - BusinessHours used to determine which days are business days
     *  @param          referenceDate         - by default, it is today's date.
     *  @return         date                - service appointment start date for querying
     **/
    private static Date getReminderReturnDate(Integer daysAdvanced, BusinessHours bh, Date referenceDate) {

        Date prevDate = referenceDate;

        while (daysAdvanced > 0) {

            prevDate = prevDate.addDays(-1);
            if (isBusinessDay(prevDate, bh)) {
                daysAdvanced--;
            }
        }
        System.debug('@@DateCalculated: ' + prevDate);
        return prevDate;
    }

    /**
     *  @author         Abhi Indulkar
     *  @date           15/11/2018  
     *  @description    This method checks if a date is business day
     *  @param          dateLocal   - the date to check against
     *  @param          bh          - business hours for each business day
     *  @return         Boolean     - true if it's business day, otherwise false
     **/
    public static Boolean isBusinessDay(Date dateLocal, BusinessHours bh) {

        // The reason that we pick 10am is because 10am usually falls into business hours for business days. 
        // Otherwise, it (e.x. 1 AM) might not be within business hours even it's a business day
        Datetime datetimeLocal = Datetime.newInstance(dateLocal.year(), dateLocal.month(), dateLocal.day(), 10, 0, 0);

        System.debug('@datetimeLocal: ' + datetimeLocal);

        // Find whether the time is within the default business hours
        return BusinessHours.isWithin(bh.id, datetimeLocal);
    }
}