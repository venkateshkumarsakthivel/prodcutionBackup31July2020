/*
 * Description: Batch class to process actions when taxi licence is not renewed for eligible licences
 */
public without sharing class TaxiLicenceNonRenewalProcessingBatch implements Database.Batchable<SObject> {
    private static final String SUSPENDED_STATUS = GlobalConstants.AUTHORISATION_SUSPENDED;
    private static final String GRANTED_STATUS = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String TAXI_LICENCE = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    private static Date endDate = System.today() - 1 ;
    
    private static final Map<String, Taxi_Class__mdt> classVsConfig;
    static {
            System.debug(LoggingLevel.INFO, 'Retrieving renewal configuration details');
            classVsConfig = new Map<String, Taxi_Class__mdt>();
            
            for(Taxi_Class__mdt config : [SELECT Description__c, Is_Legacy_Only__c,
                                            Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                            Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                            Renew_Months__c
                                        FROM Taxi_Class__mdt
                                        WHERE Is_Renewable__c = :GlobalConstants.YES_VALUE ]){
                classVsConfig.put(config.Licence_Class__c, config);
            }       
    }

    public TaxiLicenceNonRenewalProcessingBatch(){

    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> lRenewableClasses = classVsConfig.keySet();
        String query = 'SELECT Id, End_Date__c, Service_Provider__c, Authorisation_Type__c,' 
                        + 'Licence_Class__c, Licence_Type__c, Status__c, Licence_Fee__c '
                        + 'FROM Authorisation__c '
                        + 'WHERE (Status__c = :GRANTED_STATUS OR Status__c =:SUSPENDED_STATUS) '
                        + 'AND Authorisation_Type__c = :TAXI_LICENCE ' 
                        + 'AND Licence_Class__c IN :lRenewableClasses '
                        + 'AND End_Date__c = :endDate '
                        + 'AND Licence_Type__c != NULL ';
        
        System.debug(LoggingLevel.INFO, 'Generated query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Authorisation__c> scope){
        
        Map<Id, Authorisation__c> mExpiredLicences = new Map<Id, Authorisation__c>();
        for(Authorisation__c auth: scope){
            mExpiredLicences.put(auth.Id, auth);
        }

        TaxiLicenceNonRenewalProcessor.process(mExpiredLicences);
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}