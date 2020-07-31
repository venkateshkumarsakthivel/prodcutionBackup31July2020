// This class is written in without sharing mode, 
// as Draft auth linked to ASP Auth Renewal Application and not selected by user for Renewal should be deleted
public without sharing class ASPAuthRenewalLodger {
    
    // For ASP Auth Renewal application -
    // If Renewal Case had 2 Authorisations linked, but user has selected to renew only one licence 
    // then delete other draft authorisation linked to case
    public static void deleteDraftAuthNotSelectedForRenewal(Case application) {
        
        String appServiceType = application.Service_Type__c;
        
        List<Authorisation__c> listDraftAuths = [SELECT Id, Application__c, Authorisation_Type__c 
                                                 FROM Authorisation__c
                                                 WHERE Application__c =: application.Id];
        
        // User has selcted only one authorisation for renewal
        Authorisation__c authToDelete = null;
        if(listDraftAuths.size() == 2 && appServiceType != GlobalConstants.SERVICE_TYPE_TAXI_BOOKING) {
            
            for(Authorisation__c draftAuth : listDraftAuths) {
                
                if(appServiceType == GlobalConstants.SERVICE_TYPE_TAXI && draftAuth.Authorisation_Type__c != GlobalConstants.AUTHORISATION_TYPE_TSP) {
                    
                    authToDelete = draftAuth;
                }
                else if(appServiceType == GlobalConstants.SERVICE_TYPE_BOOKING && draftAuth.Authorisation_Type__c != GlobalConstants.AUTHORISATION_TYPE_BSP) {
                    
                    authToDelete = draftAuth;
                }
            }
        }
        
        if(authToDelete != null) {
            Database.delete(authToDelete, false);
        }
    }
}