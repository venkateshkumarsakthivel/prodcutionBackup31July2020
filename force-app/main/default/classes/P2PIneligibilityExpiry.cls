/**
 * Scheduled routine to check Ineligible Drivers and Mark them active if
 * a) Their Elibility Status has NOT been manually changed (either to active or Inactive)
 * AND
 * b) Their Authority End Date has passed 
 */ 
global class P2PIneligibilityExpiry implements Schedulable{

    /**
     * execute the job
     * This should attempt to fetch all relevant records and update them in one shot
     * This assumes that the ineligible drivers list from RMS < 10K records!
     * 
     * The Ignore End Date Flag is set using a workflow - 
     * flags if the traffic light indicator has been manually changed
     */
    global void execute(SchedulableContext sc){
        List<Ineligible_Drivers__c> drivers = [SELECT Id, Ignore_End_Date__c,
                                                  Traffic_Light_Indicator__c 
                                               FROM Ineligible_Drivers__c
                                               WHERE (Driver_Authority_Status_Date__c <= TODAY)
                                               AND Ignore_End_Date__c = FALSE
                                               AND Traffic_Light_Indicator__c = 'Fail' ];
        
        for(Ineligible_Drivers__c driver : drivers){
            driver.Traffic_Light_Indicator__c = 'Pass';
            driver.Ignore_End_Date__c = TRUE;
        }
        
        update drivers;
    }
}