/*
 * @Description: Helper class to initiate licence renewal process for eligible taxi licence
 */
public with sharing class TaxiLicenceRenewalInitiator{
    
    private static final List<Consumer_Price_Index_Configuration__mdt> taxiCPIConfig;
    private static final Map<String, Taxi_Class__mdt> classVsConfig;
    private static Map<Id, List<Contact>> actVsContacts;
    static {
        taxiCPIConfig = [SELECT CPI__c
                       FROM Consumer_Price_Index_Configuration__mdt
                       WHERE DeveloperName = :GlobalConstants.CPI_INDEX_METADATA_NAME  
                       LIMIT 1];
        
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
    
    private static Map<Id, Authorisation__c> retrieveLicencesToRenew(Set<String> eligibleClasses, List<Authorisation__c> licencesToProcess){
        //Retrieve licences that are eligible for renewal based on class, status and end date
        Date currentPlus28Days = System.today().addDays(Integer.valueOf(Label.Renewal_Eligible_Period_Before_Expiry_of_Licence));
        Map<Id, Authorisation__c> licencesToRenew = new Map<Id, Authorisation__c>(
                                                            [SELECT Id, End_Date__c, Service_Provider__c, Authorisation_Type__c, 
                                                                    Licence_Class__c, Licence_Type__c, Status__c, Licence_Fee__c,
                                                                    Bank_Account_Number__c, Payment_Card_Number__c
                                                            FROM Authorisation__c 
                                                            WHERE (Status__c = :GlobalConstants.TAXI_LICENCE_GRANTED_STATUS
                                                                    OR Status__c = :GlobalConstants.AUTHORISATION_SUSPENDED ) 
                                                                AND Authorisation_Type__c = :GlobalConstants.AUTHORISATION_TYPE_TAXI_LICENCE 
                                                                AND End_Date__c <= :currentPlus28Days
                                                                AND Renewal_Requested__c = false
                                                                AND Licence_Class__c IN :eligibleClasses
                                                                AND Id IN :licencesToProcess
                                                               ]);
        
        //check if open renewal application exist for a licence
        List<Case> openRenewalRequests = [SELECT CaseNumber, Status, Authorisation__c
                                          FROM Case 
                                          WHERE IsClosed = FALSE
                                              AND Authorisation__c IN :licencesToRenew.keySet()
                                              AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                              AND (Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION
                                                    OR Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_SURRENDER_PAIRED
                                                    OR Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_SURRENDER)];
        for(Case application : openRenewalRequests){
            System.debug(LoggingLevel.INFO, 'Open renewal request exists for the licence ' + application.Authorisation__c);
            licencesToRenew.remove(application.Authorisation__c);
        }
        
        return licencesToRenew;
    }

    private static Map<Id, Double> computeRenewalPrice(List<Authorisation__c> licences){
        Map<Id, Double> licenceVsRenewalPrice = new Map<Id, Double>();
        
        for(Authorisation__c licence : licences){
            System.debug(LoggingLevel.INFO, 'Computing renewal price for ' + licence.Id + ' with base price ' + licence.Licence_Fee__c);
            licenceVsRenewalPrice.put(licence.Id, computePrice(classVsConfig.get(licence.Licence_Class__c), licence.Licence_Fee__c));
        }
        
        return licenceVsRenewalPrice;
    }
    
    private static Double computePrice(Taxi_Class__mdt config, Decimal licenceFee){
        String renewFormula = config.Renew_Formula__c;
        Double renewalPrice = 0.0;
        if(renewFormula == GlobalConstants.RENEWAL_PRICE_FORMULA_BASE ){
            renewalPrice = licenceFee;
        } else if(renewFormula == GlobalConstants.RENEWAL_PRICE_FORMULA_BASE_CPI){
            renewalPrice = licenceFee + (licenceFee * taxiCPIConfig[0].CPI__c/100);
        }
        System.debug(LoggingLevel.INFO, 'Computed renewal price: ' + renewalPrice);
        return renewalPrice;
    }
    
    private static List<Authorisation__c> createRenewLicence(List<Authorisation__c> existingLicence, Map<Id, Double> licenceVsRenewalPrice){
        
        //create clone version of licence
        String soql = GlobalUtility.getCreatableFieldsSOQL('Authorisation__c','id IN :existingLicence');
        System.debug(LoggingLevel.INFO, 'Generated soql to clone licences : ' + soql);
        
        List<Authorisation__c> existingLicences = (List<Authorisation__c>) Database.query(soql);
        List<Authorisation__c> renewedLicences = new List<Authorisation__c>();
       
        Map<String, Authorisation_Agent__c> existingLicenceIdVsActiveAgentAssociation = new Map<String, Authorisation_Agent__c>();
        List<Authorisation_Agent__c> newAgentRecords = new List<Authorisation_Agent__c>();
        
        //fetching active agents records for all existing licences
        for(Authorisation_Agent__c tempAuthAgents : [SELECT Authorisation__c, Account__c, Status__c,
                                                      Expiry_Date__c, Approved_Date__c, Agreement_Type__c
                                                      FROM Authorisation_Agent__c
                                                      WHERE Authorisation__c IN :existingLicences
                                                      AND Status__c = :GlobalConstants.STATUS_ACTIVE
                                                      ORDER BY CreatedDate DESC]) {
             
           existingLicenceIdVsActiveAgentAssociation.put(tempAuthAgents.Authorisation__c, tempAuthAgents);
        }
        
        for(Authorisation__c licence : existingLicences) {
        
            System.debug(LoggingLevel.INFO, 'Existing licence: ' + licence);
            
            Authorisation__c renewalLicenceAuth = licence.clone(false, true, false, false);
            renewalLicenceAuth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;  
            renewalLicenceAuth.Support_Process_Approval_Status__c = '';
            renewalLicenceAuth.Auto_Generate_Number__c = false;
            renewalLicenceAuth.Decision_Date__c = NULL;
            renewalLicenceAuth.Decision_Made_By__c = NULL;
            renewalLicenceAuth.Decision_Reason__c = '';
            renewalLicenceAuth.Start_Date__c = licence.End_Date__c.addDays(1);
            renewalLicenceAuth.End_Date__c = renewalLicenceAuth.Start_Date__c.addMonths(
                                                Integer.valueOf(classVsConfig.get(licence.Licence_Class__c).Renew_Months__c)).addDays(-1);
            renewalLicenceAuth.Is_Renewal_Licence__c = TRUE;
            renewalLicenceAuth.Related_Authorisation__c = licence.Id;
            renewalLicenceAuth.Licence_Fee__c = licenceVsRenewalPrice.get(licence.Id);
            renewalLicenceAuth.Variation_Auth_Id__c = licence.Id;
            renewalLicenceAuth.SNSW_Plate_Pickup_Location__c = null;
            renewalLicenceAuth.OwnerId = UserInfo.getUserId();
            renewedLicences.add(renewalLicenceAuth);
        }
        
        insert renewedLicences;
        
        for(Authorisation__c licence : renewedLicences) {
           
            //check if earlier related licence had active agent record against it
            if(existingLicenceIdVsActiveAgentAssociation.containsKey(licence.Related_Authorisation__c)) {
              
               Authorisation_Agent__c oldAuthAgent = existingLicenceIdVsActiveAgentAssociation.get(licence.Related_Authorisation__c);
               Authorisation_Agent__c newAuthAgent = new Authorisation_Agent__c();
               newAuthAgent.Account__c = oldAuthAgent.Account__c;
               newAuthAgent.Authorisation__c = licence.Id;
               newAuthAgent.Agreement_Type__c = oldAuthAgent.Agreement_Type__c;
               newAuthAgent.Expiry_Date__c = oldAuthAgent.Expiry_Date__c;
               newAuthAgent.Approved_Date__c = System.Today();
               newAuthAgent.Status__c = GlobalConstants.STATUS_ACTIVE;
               
               newAgentRecords.add(newAuthAgent);
            }
        }
        
        if(newAgentRecords.size() > 0) {
          
          Database.saveResult[] sr = Database.insert(newAgentRecords, FALSE);
          System.debug('Auth. Agent Records For Renewed Licences: '+sr);
        }
        
        return renewedLicences;
    }
    
    private static Set<Id> retrieveLicencesWithEmailAsPreference(List<Authorisation__c> licences){
        return new Map<Id, Authorisation__c>([SELECT Id, Service_Provider__c FROM Authorisation__c 
        WHERE Service_Provider__r.Document_Delivery_Preference__c = :GlobalConstants.DOCUMENT_DELIVERY_PREFERENCE_EMAIL ]).keySet();
        
    }
    
    private static List<Case> createRenewalCases(List<Authorisation__c> renewedLicences){
        Set<Id> licencesWithEmailAsPreference = retrieveLicencesWithEmailAsPreference(renewedLicences);
        //create a renewal case
        Id taxiAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                            GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        
        //retrieve contact details of service providers
        Set<Id> serviceProviders = new Set<Id>();
        for(Authorisation__c auth : renewedLicences){
            serviceProviders.add(auth.Service_Provider__c);
        }
        PrimaryContactRetriever contactRetriever = new PrimaryContactRetriever(serviceProviders);
        
        List<Case> renewedCases = new List<Case>();
        for(Authorisation__c licence : renewedLicences){
            
            Case renewalApplication = new Case(); 
            renewalApplication.AccountId = licence.Service_Provider__c;
            renewalApplication.ContactId = contactRetriever.identifyPrimaryContact(licence.Service_Provider__c);
            renewalApplication.Authorisation__c = licence.Id;
            renewalApplication.RecordTypeId = taxiAdminRecordType;
            renewalApplication.Subject = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;
            renewalApplication.Description = GlobalConstants.RENEWAL_TAXI_APPLICATION_SUBJECT;               
            renewalApplication.Type = GlobalConstants.TAXI_CASE_TYPE;                 
            renewalApplication.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION;
            renewalApplication.Status = licencesWithEmailAsPreference.contains(licence.Id) ? GlobalConstants.CASE_DRAFT : GlobalConstants.CASE_NEW ;
            renewalApplication.Sub_Status__c =  GlobalConstants.CASE_SUB_STATUS_DRAFT;
            renewalApplication.Licence_Fee_Due__c = licence.Licence_Fee__c;
            renewalApplication.Licence_Class__c = licence.Licence_Class__c;
            renewalApplication.Operating_Locations__c  =licence.Operating_Locations__c;
            renewalApplication.Operation_Area__c = licence.Operation_Area__c;  
            renewalApplication.SNSW_Plate_Pickup_Location__c = null;
            renewalApplication.Agent__c = licence.Agency__c;
            
            renewedCases.add(renewalApplication);
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        Database.insert(renewedCases, dmo);
        
        return renewedCases;
    }
    
    public static void initiate(List<Authorisation__c> licencesToProcess){      
        
        //Retrieve licences that are eligible for renewal based on class, status and end date
        System.debug(LoggingLevel.INFO, 'Retrieving licences eligible for renewal');
        Map<Id, Authorisation__c> licencesToRenew = retrieveLicencesToRenew(classVsConfig.keySet(), licencesToProcess);
       
        if(licencesToRenew.isEmpty()){
            return;
        }
        
        if(taxiCPIConfig.isEmpty()){
            System.debug(LoggingLevel.ERROR, 'CPI config details not available for licence renewal calculation');
            throw new InvalidDataException('CPI details not available. Cannot calculate licence renewal price.');
        }
        
        //calculate renewal price
        System.debug(LoggingLevel.INFO, 'Calculating renewal price for licences');
        Map<Id, Double> licenceVsRenewalPrice = computeRenewalPrice(licencesToRenew.values());
        
        //create new cloned version of licences
        System.debug(LoggingLevel.INFO, 'Creating cloned version of existing licences');
        List<Authorisation__c> renewedLicences = createRenewLicence(licencesToRenew.values(), licenceVsRenewalPrice);
        Map<Id, Authorisation__c> licenceMap = new Map<Id, Authorisation__c>();
        for(Authorisation__c licence : renewedLicences){
            licenceMap.put(licence.Id, licence);
        }
        
        //create renewal applications
        List<Case> applications = createRenewalCases(renewedLicences);
        Map<Id, Authorisation__c> appVsLicence = new Map<Id, Authorisation__c>();
        for(Case app : applications){
            appVsLicence.put(app.Id, licenceMap.get(app.Authorisation__c));
        }
        
        //create payment and line items for renewal licences.
        LicenceRenewalPaymentCreator paymentCreator = new LicenceRenewalPaymentCreator(appVsLicence);
        paymentCreator.create();
        
        //update renewal requested flag on existing licence.
        for(Authorisation__c licence: licencesToRenew.values()){
            licence.Renewal_Requested__c = true;
        } 
        update licencesToRenew.values();
    }
    
    public class InvalidDataException extends Exception {}
}