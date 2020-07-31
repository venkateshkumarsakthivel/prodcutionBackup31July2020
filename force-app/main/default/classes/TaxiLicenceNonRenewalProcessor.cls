/*
 * @Description: Helper class to process licence expiry for eligible expired taxi licences
 */
public without sharing class TaxiLicenceNonRenewalProcessor {
    private static Id taxiAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();
    private static Id taxiLicAdminRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalConstants.TAXI_LICENSE_ADMINISTRATION_CASE_RECORD_TYPE_NAME).getRecordTypeId();

    public static void process(Map<Id, Authorisation__c> pLicencesMap){
        //Filter out licences for which renewal application has been lodged already
        filterRenewalInitiatedLicences(pLicencesMap);
        
        //Old licences should be marked as Lapsed
        updateOldLicencesToLapsed(pLicencesMap.values());
        
        //Update Expiry cases
         updateOpenExpiryCases(pLicencesMap.keySet());

        //New Taxi Licence (which is currently in Draft Status) : should be discarded 
        updateNewLicencesToBeDiscarded(pLicencesMap.keySet());
        
    }

    private static void updateOldLicencesToLapsed(List<Authorisation__c> pLicencesToLapse){
        try{
            //System.debug('@@@pLicencesToLapse= ' + pLicencesToLapse);
            
            for(Authorisation__c auth : pLicencesToLapse){
                auth.Status__c = GlobalConstants.AUTH_STATUS_LAPSED;
            }
            Database.update(pLicencesToLapse,false);

        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceNonRenewalProcessor','updateOldLicencesToLapsed',ex.getMessage(),ex);
        }
    }
    
    private static void updateOpenExpiryCases(Set<Id> pOldLicenceIds){
        try{
            //Retrieve Expiry cases
            List<Case> openExpiryCases =    [SELECT Sub_Status__c
                                                FROM Case 
                                                WHERE RecordTypeId = :taxiLicAdminRecordType
                                                    AND IsClosed = FALSE
                                                    AND Authorisation__c IN :pOldLicenceIds
                                                    AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                                    AND (Sub_Type__c = :GlobalConstants.EXPIRY_CASE_SUB_TYPE
                                                        OR Sub_Type__c = :GlobalConstants.CASE_SUB_TYPE_EXPIRY_RENEWABLE)];
            //System.debug('@@@openExpiryCases= ' + openExpiryCases);
            if(!openExpiryCases.isEmpty()){
                for(Case c : openExpiryCases){
                    c.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_WAITING_FOR_PLATES;
                }
                Database.update(openExpiryCases,false);
            }

        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceNonRenewalProcessor','closeRenewalCases',ex.getMessage(),ex);
        }
    }

    private static void updateNewLicencesToBeDiscarded(Set<Id> pOldLicenceIds){
        try{
            //Retrieve New licences
            Map<Id, Authorisation__c> mapNewLicences =  new Map<Id, Authorisation__c>([SELECT Id, Status__c FROM Authorisation__c 
                                                        WHERE Is_Renewal_Licence__c = TRUE
                                                            AND Status__c = :GlobalConstants.AUTHORISATION_STATUS_DRAFT
                                                            AND Related_Authorisation__c IN :pOldLicenceIds]);
            //System.debug('@@@mapNewLicences= ' + mapNewLicences);
            if(!mapNewLicences.isEmpty()){
                List<Authorisation__c> lNewLicences = mapNewLicences.values();
                for(Authorisation__c auth : lNewLicences){
                    auth.Status__c = GlobalConstants.AUTHORISATION_STATUS_DISCARDED;
                }
                Database.update(lNewLicences,false);

                //Close Renewal cases
                closeRenewalCases(mapNewLicences.keySet());
            }

        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceNonRenewalProcessor','updateNewLicencesToDiscarded',ex.getMessage(),ex);
        }
    }

    private static void closeRenewalCases(Set<Id> pNewLicenceIds){
        try{
            //Retrieve renewal cases
            List<Case> openRenewalCases =    [SELECT Status,Sub_Status__c
                                                FROM Case 
                                                WHERE RecordTypeId = :taxiAdminRecordType
                                                    AND IsClosed = FALSE
                                                    AND Authorisation__c IN :pNewLicenceIds
                                                    AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                                    AND Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION];
            //System.debug('@@@openRenewalCases= ' + openRenewalCases);
            if(!openRenewalCases.isEmpty()){
                for(Case c : openRenewalCases){
                    c.Status= GlobalConstants.CLOSED_CASE_STATUS;
                    c.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_DID_NOT_PROCEED;
                }
                Database.update(openRenewalCases,false);
            }

        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceNonRenewalProcessor','closeRenewalCases',ex.getMessage(),ex);
        }
    }

    private static void filterRenewalInitiatedLicences(Map<Id,Authorisation__c> pLicencesMap){
        try{
            //Retrieve New licences
            Map<Id, Authorisation__c> mapNewLicences =  new Map<Id, Authorisation__c>([SELECT Id, Related_Authorisation__c FROM Authorisation__c 
                                                                                        WHERE Is_Renewal_Licence__c = TRUE
                                                                                            AND Status__c = :GlobalConstants.AUTHORISATION_STATUS_DRAFT
                                                                                            AND Related_Authorisation__c IN :pLicencesMap.keySet()]);

            List<Case> lodgedRenewalCases =    [SELECT Authorisation__c
                                                FROM Case 
                                                WHERE RecordTypeId = :taxiAdminRecordType
                                                    AND IsClosed = FALSE
                                                    AND Authorisation__c IN :mapNewLicences.keySet()
                                                    AND Status = :GlobalConstants.LODGED_CASE_STATUS
                                                    AND Type = :GlobalConstants.CASE_TAXI_TYPE
                                                    AND Sub_Type__c = :GlobalConstants.CASE_SUBTYPE_RENEW_APPLICATION];

            for(Case c : lodgedRenewalCases){
                pLicencesMap.remove(mapNewLicences.get(c.Authorisation__c).Related_Authorisation__c);
                
            }

        }catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'TaxiLicenceNonRenewalProcessor','filterRenewalInitiatedLicences',ex.getMessage(),ex);
        }
    }
}