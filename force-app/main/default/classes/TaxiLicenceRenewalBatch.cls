/*
 * Description: Batch class to initiate renewal process for eligible licences
 */
public with sharing class TaxiLicenceRenewalBatch implements Database.Batchable<SObject> {
    private static final String SUSPENDED_STATUS = GlobalConstants.AUTHORISATION_SUSPENDED;
    private static final String GRANTED_STATUS = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String TAXI_LICENCE = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    private static final Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
    
    public TaxiLicenceRenewalBatch(){
        
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, End_Date__c, Service_Provider__c, Authorisation_Type__c,' 
                        + 'Licence_Class__c, Licence_Type__c, Status__c, Licence_Fee__c '
                        + 'FROM Authorisation__c '
                        + 'WHERE (Status__c = :GRANTED_STATUS OR Status__c =:SUSPENDED_STATUS) '
                        + 'AND Authorisation_Type__c = :TAXI_LICENCE ' 
                        + 'AND End_Date__c <= :currentPlus28Days '
                        + 'AND Renewal_Requested__c = false '
                        + 'AND Licence_Type__c != NULL '
                + 'AND Renewal_Count_Remaining__c > 0';
        
        System.debug(LoggingLevel.INFO, 'Generated query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Authorisation__c> licences = (List<Authorisation__c>) scope;
        TaxiLicenceRenewalInitiator.initiate(licences);
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}