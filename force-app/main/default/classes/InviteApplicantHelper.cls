/*
 * @Description:    Helper class to invite taxi applicant on portal to complete the application.
 *                  This class is responsible for creating a new portal user for inactive/new accounts 
 *                  and upgrading portal access for existing accounts.
 */
public with sharing class InviteApplicantHelper {
    
    private List<Case> applications;
    
    public InviteApplicantHelper(List<Case> taxiApplications){
        if(taxiApplications== null){
            throw new InvalidDataException('Failed to invite taxi applicants. Application details missing.');
        }
        this.applications = taxiApplications;       
    }
    
    public void invite(){
        Map<Id, List<Case>> actVsApplication = new Map<Id, List<Case>>();
        for(Case application : applications){
            if(!actVsApplication.containsKey(application.AccountId)){
                actVsApplication.put(application.AccountId, new List<Case>());
            }
            actVsApplication.get(application.AccountId).add(application);
        }

        //identify active portal accounts.
        ActiveCommunityAccountIdentifier identifier = new ActiveCommunityAccountIdentifier(new List<Id>(actVsApplication.keySet()));
        List<User> activePortalUsers = identifier.retrievePortalUsers();

        //for all active portal accounts, upgrade portal user profiles.
        CommunityProfileUpgrader profileUpgrader = new CommunityProfileUpgrader(activePortalUsers);
        profileUpgrader.upgradeToTaxi();

        //for all inactive portal accounts, create portal users
        Set<Id> inactiveAccounts = identifier.retrieveInactiveAccounts();
        Set<Id> portalContacts = new Set<Id>();
        for(Id actId : inactiveAccounts){
            List<Case> taxiApplications = actVsApplication.get(actId);
            for(Case app: taxiApplications){
                if(app.ContactId != null) portalContacts.add(app.ContactId);
            }
        }
        String profileId = GlobalUtility.getTaxiLicenceUserProfile().Id;
        CommunityUserCreator.create(new List<Id>(portalContacts), profileId);
    }
    
    public class InvalidDataException extends Exception {}
}