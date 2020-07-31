/**
 *  Description: Helper class for identify qualified applications for authorisation creation
 */
public with sharing class AuthorisationApplicationQualifier {
    private static final Set<Id> qualifiedRecordTypes;
    
    private List<Case> newApplications;
    private Map<Id, Case> oldApplications;
    
    static {
        //populate recordtypeid for qualified applications
        qualifiedRecordTypes = GlobalUtility.retrieveASPApplicationRecordTypes();
    }
    
    public AuthorisationApplicationQualifier(List<Case> newApplications, Map<Id, Case> oldApplications){
        if(newApplications == null || oldApplications == null){
            throw new InvalidDataException('Failed to qualify application. Application details missing');
        }
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    public List<Case> retrieveQualifiedApplication(){
        return identifyQualifiedApplications(newApplications);
    }
    
    //qualify application for authorisation creation
    private List<Case> identifyQualifiedApplications(List<Case> applications){
        List<Case> qualifiedApplications = new List<Case>();
        for(Case application : applications){
            if(qualifiedRecordTypes.contains(application.RecordTypeId)
                    && application.Status == GlobalConstants.APPLICATION_STATUS_LODGED
                    && oldApplications.get(application.Id) != null
                    && oldApplications.get(application.Id).Status != GlobalConstants.APPLICATION_STATUS_LODGED){
                qualifiedApplications.add(application);
            }
        }
        return qualifiedApplications;
    }
    
    public class InvalidDataException extends Exception {}
}