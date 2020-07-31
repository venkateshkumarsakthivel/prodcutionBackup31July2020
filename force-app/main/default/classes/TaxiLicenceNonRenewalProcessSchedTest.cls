@IsTest
public with sharing class TaxiLicenceNonRenewalProcessSchedTest {
    private static final String CRON_EXP = '0 0 0 3 9 ? 2050';
    
    private static testMethod void testForScheduler(){
        System.Test.startTest();
        String jobId = System.schedule('TaxiLicenceNonRenewalProcessScheduler', CRON_EXP, new TaxiLicenceNonRenewalProcessScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                        FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        
        System.Test.stopTest();
    }
}