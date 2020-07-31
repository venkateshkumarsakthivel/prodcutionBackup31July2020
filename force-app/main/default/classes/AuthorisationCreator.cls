/**
*  Description: Helper class for creating authorisation record for every application lodged
*/
public with sharing class AuthorisationCreator {
    private List<Case> applications;
    private static final Map<String, List<String>> serviceVsAuthorisationType;
    
    //holds set of applications for which authorisation is created.
    private static final Set<Id> authorisationsCreated;
    private static Map<String, Set<Id>> serviceTypeVsApplications;
    
    static {
        //create mapping of service type vs authorisation type
        serviceVsAuthorisationType = new Map<String, List<String>>();
        serviceVsAuthorisationType.put(GlobalConstants.SERVICE_TYPE_TAXI, 
                                       new List<String>{GlobalConstants.AUTHORISATION_TYPE_TSP});
        serviceVsAuthorisationType.put(GlobalConstants.SERVICE_TYPE_BOOKING, 
                                       new List<String>{GlobalConstants.AUTHORISATION_TYPE_BSP});
        serviceVsAuthorisationType.put(GlobalConstants.SERVICE_TYPE_TAXI_BOOKING, 
                                       new List<String>{GlobalConstants.AUTHORISATION_TYPE_TSP, GlobalConstants.AUTHORISATION_TYPE_BSP});
        
        authorisationsCreated = new Set<Id>();
        serviceTypeVsApplications = new Map<String, Set<Id>>();
        serviceTypeVsApplications.put(GlobalConstants.AUTHORISATION_TYPE_TSP , new Set<Id>());
        serviceTypeVsApplications.put(GlobalConstants.AUTHORISATION_TYPE_BSP , new Set<Id>());
    }
    
    public AuthorisationCreator(List<Case> newApplications){
        if(newApplications == null || newApplications.isEmpty()){
            throw new InvalidApplicationDataException('Failed to create authorisation. ' 
                                                      + 'Application details not provided');
        }
        this.applications = newApplications;
    }
    
    public void create(){        
        List<Authorisation__c> authorisations = new List<Authorisation__c>();
        system.debug('applications: '+applications);
        //retrieve authorisations that are already created for an application
        for(Authorisation__c authorisation : [SELECT Id, Application__c, Authorisation_Type__c
                                              FROM Authorisation__c
                                              WHERE Application__c IN :applications]){
                                                  serviceTypeVsApplications.get(authorisation.Authorisation_Type__c).add(authorisation.Application__c);
                                                  
                                              }
        
        for(Case application : applications){
            if(serviceVsAuthorisationType.containsKey(application.Service_Type__c) 
               && !authorisationsCreated.contains(application.Id)){
                   for(String serviceType : serviceVsAuthorisationType.get(application.Service_Type__c)){
                       if(!serviceTypeVsApplications.get(serviceType).contains(application.Id)){
                           authorisations.add(createAuthorisation(application, serviceType));
                           authorisationsCreated.add(application.Id);
                       }                    
                   }
               }
        }
        insert authorisations;
    }
    
    //create authorisation record for application
    private Authorisation__c createAuthorisation(Case application, String authorisationType){
        
        Id defaultRecTypeId = Schema.SObjectType.Authorisation__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        
        Authorisation__c authorisation = new Authorisation__c();
        authorisation.Application__c = application.Id;
        authorisation.Authorisation_Type__c = authorisationType;
        authorisation.Contact__c = application.ContactId;
        authorisation.Service_Provider__c = application.AccountId;
        authorisation.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        //authorisation.Start_Date__c = System.today();
        Integer termPeriod = 0;
        termPeriod = (authorisationType == GlobalConstants.AUTHORISATION_TYPE_BSP 
                      || authorisationType == GlobalConstants.AUTHORISATION_TYPE_TSP )? Integer.valueOf(Label.Default_ASP_Term_period) : Integer.valueOf(Label.Default_Taxi_Term_period);
        //authorisation.End_Date__c = System.today().addYears(termPeriod );
        authorisation.Term_in_Years__c = Integer.valueOf(Label.Default_ASP_Term_period);
        authorisation.Service_Provider_Notice_Email__c = application.Notice_Email__c;
        authorisation.RecordTypeId = defaultRecTypeId;
        
        
        return authorisation;
    }
    
    public class InvalidApplicationDataException extends Exception {}
}