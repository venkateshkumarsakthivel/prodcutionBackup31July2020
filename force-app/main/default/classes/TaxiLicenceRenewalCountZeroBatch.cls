/*
 * * * created by : Srikanth Sunkara
 * Created Date: 11/11/2019 (JIRA- 224)
*Scheduler class to Create Non Renewal expiry Case before 28 days of expiry date.
* This Batch runs run Daily.
* 
Test Class: TaxiLicenceRenewalCountZeroBatchTest
*/ 
public with sharing class TaxiLicenceRenewalCountZeroBatch implements Database.Batchable<SObject> {
    private static final Date TodaysDate =System.today();
    private static final String SUSPENDED_STATUS = GlobalConstants.AUTHORISATION_SUSPENDED;
    private static final String GRANTED_STATUS = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String TAXI_LICENCE = GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE;
    private static final Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
    public static final String ERROR ='Error';//logging level
    public static final String TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME = 'Taxi License Administration';
     Set<String> taxiclass = new Set<String>();
    public TaxiLicenceRenewalCountZeroBatch(){
        for(Taxi_Class__mdt config : [SELECT Description__c, Is_Legacy_Only__c,
                                        Is_Renewable__c, Is_Transferable__c, Is_WAT__c, Licence_Class__c,
                                        Licence_Type__c, Max_Years__c, Operating_Area__c, Renew_Formula__c,
                                        Renew_Months__c
                                    FROM Taxi_Class__mdt
                                    WHERE Is_Renewable__c = :GlobalConstants.YES_VALUE AND Max_Years__c =10]){
            //classVsConfig.put(config.Licence_Class__c, config);
            taxiclass.add(config.Licence_Class__c);
                                        
        }       
        system.debug(taxiclass);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, End_Date__c, Service_Provider__c,Operating_Locations__c,Operation_Area__c,Authorisation_Type__c,' 
                        + 'Licence_Class__c, Licence_Type__c, Status__c, Licence_Fee__c '
                        + 'FROM Authorisation__c '
                        + 'WHERE (Status__c = :GRANTED_STATUS OR Status__c =:SUSPENDED_STATUS) '
                        + 'AND Authorisation_Type__c = :TAXI_LICENCE ' 
                        + 'AND End_Date__c <= :currentPlus28Days ' + 'AND End_Date__c >:TodaysDate ' 
                        + 'AND Renewal_Requested__c = false '
                        + 'AND TaxiLicence10YearsExpiry__c = false '
                        + 'AND Licence_Type__c != NULL '
                        + 'AND Licence_Class__c IN :taxiclass '
                + 'AND Renewal_Count_Remaining__c = 0';
        
        System.debug(LoggingLevel.INFO, 'Generated query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Authorisation__c> updateAuthorisationList = new List<Authorisation__c>();
        List<Authorisation__c> licences = (List<Authorisation__c>) scope;
        system.debug(licences.size());
       //  Set<Id> licencesWithEmailAsPreference = retrieveLicencesWithEmailAsPreference(renewedLicences);
        //create a renewal case
        Id taxiAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                            TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        //retrieve contact details of service providers
        Set<Id> serviceProviders = new Set<Id>();
        try{
        for(Authorisation__c auth : licences){
            serviceProviders.add(auth.Service_Provider__c);
        }
        PrimaryContactRetriever contactRetriever = new PrimaryContactRetriever(serviceProviders);
        
        List<Case> renewedCases = new List<Case>();
        for(Authorisation__c licence : licences){
            
            licence.TaxiLicence10YearsExpiry__c= true;
            updateAuthorisationList.add(licence);
            Case renewalApplication = new Case(); 
            renewalApplication.AccountId = licence.Service_Provider__c;
            renewalApplication.ContactId = contactRetriever.identifyPrimaryContact(licence.Service_Provider__c);
            renewalApplication.Authorisation__c = licence.Id;
            renewalApplication.RecordTypeId = taxiAdminRecordType;
            renewalApplication.Subject = GlobalConstants.NONRENEWAL_TAXI_APPLICATION_SUBJECT;
            renewalApplication.Description = GlobalConstants.NONRENEWAL_TAXI_APPLICATION_SUBJECT;               
            renewalApplication.Type = GlobalConstants.TAXI_CASE_TYPE;                 
            renewalApplication.Sub_Type__c = GlobalConstants.NONRENEWAL_TAXI_APPLICATION_SUBJECT;
            renewalApplication.Status = GlobalConstants.CASE_DRAFT;
            renewalApplication.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
            renewalApplication.Licence_Fee_Due__c = licence.Licence_Fee__c;
            renewalApplication.Licence_Class__c = licence.Licence_Class__c;
            renewalApplication.Operating_Locations__c  =licence.Operating_Locations__c;
            renewalApplication.Operation_Area__c = licence.Operation_Area__c;  
            renewalApplication.SNSW_Plate_Pickup_Location__c = null;
            //renewalApplication.Agent__c = licence.Agency__c;
            
            renewedCases.add(renewalApplication);
        }
        
        if(renewedCases.Size() > 0 ) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        Database.insert(renewedCases, dmo);
        update updateAuthorisationList;
        }
        
    }
catch (Exception ex) {
            ApplicationLogUtility.logMessage(ERROR,'TaxiLicenceRenewalCountZeroBatch','execute',ex.getMessage(),ex);
        }    
                
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}