/*
 * Description: Batch class to initiate renewal process for eligible licences
 */
public with sharing class TaxiLicenceRenewalMaxYearsZeroBatch implements Database.Batchable<SObject> {
    private static final String SUSPENDED_STATUS = GlobalConstants.AUTHORISATION_SUSPENDED;
    private static final String GRANTED_STATUS = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String TAXI_LICENCE = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    private static final Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
     //private Map<String, Taxi_Class__mdt> classVsConfig = new Map<String, Taxi_Class__mdt>();
    Set<String> taxiclass = new Set<String>();
    //classVsConfig = new Map<String, Taxi_Class__mdt>();
    //private string authid='a0G6F000022IVv4UAG';
    
    // String authid='a0G6F0000227Vkc'; 
                        //'AND (id=:authid) ' +
    public TaxiLicenceRenewalMaxYearsZeroBatch(){
        
        for(Taxi_Class__mdt config : [SELECT Description__c, Is_Legacy_Only__c,
                                        Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                        Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                        Renew_Months__c
                                    FROM Taxi_Class__mdt
                                    WHERE Is_Renewable__c = :GlobalConstants.YES_VALUE AND Max_Years__c =0]){
            //classVsConfig.put(config.Licence_Class__c, config);
            taxiclass.add(config.Licence_Class__c);
                                        
        }    
        system.debug(taxiclass);
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
                        + 'AND Licence_Class__c IN :taxiclass '
//                        + 'AND Id=:authid ' 
                + 'AND Renewal_Count_Remaining__c = 0';
        
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