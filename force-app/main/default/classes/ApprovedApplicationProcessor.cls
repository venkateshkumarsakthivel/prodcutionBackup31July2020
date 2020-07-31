/*
* Helper class to stamp ASP application status based on authorisation condition type
*/
public with sharing class ApprovedApplicationProcessor {
    
    private Map<Id, Case> newApplications;
    private Map<Id, Case> oldApplications;
    
    private static final Set<Id> qualifiedRecordTypes;
    static {
       
        //populate recordtypeid for qualified applications
        qualifiedRecordTypes = GlobalUtility.retrieveASPApplicationRecordTypes();
    }
    
    public ApprovedApplicationProcessor(Map<Id,Case> newApplications, Map<Id, Case> oldApplications){
        
        this.oldApplications = oldApplications;
        this.newApplications = newApplications;
    }
    
    public void process() {
        
        Set<Id> qualifiedApplications = new Set<Id>();
        for(Case application : newApplications.values()){
        
            if(isQualifiedForClose(application)){
        
                qualifiedApplications.add(application.Id);
            }
        }
        
        Set<Id> pspUsersWithDVDAccess = new Set<Id>();
        Set<Id> pspUsersWithNoDVDAccess = new Set<Id>();
        List<Contact> accessContactsToUpdate = new List<Contact>();
        
        
        //set application status based on authorisation condition type
        for(Id applicationId : qualifiedApplications) {
        
            String recordTypeName = newApplications.get(applicationId).Record_Type_Dev_Name__c;
            if((newApplications.get(applicationId).ContactId) != null
                && newApplications.get(applicationId).DVD_Access_Needed__c == GlobalConstants.YES_VALUE && !recordTypeName.contains('Taxi') && !recordTypeName.contains('Transfer'))
                pspUsersWithDVDAccess.add(newApplications.get(applicationId).ContactId);
                
            if((newApplications.get(applicationId).ContactId) != null
                && newApplications.get(applicationId).DVD_Access_Needed__c != GlobalConstants.YES_VALUE && !recordTypeName.contains('Taxi') && !recordTypeName.contains('Transfer'))
                pspUsersWithNoDVDAccess.add(newApplications.get(applicationId).ContactId);
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.optAllorNone = FALSE;
        dmo.DuplicateRuleHeader.allowSave = true;
        dmo.DuplicateRuleHeader.runAsCurrentUser = false;
        
        //updating access flags on contact records with ASP access indicator
        for(String dvdContactId : pspUsersWithDVDAccess) {
          
          Contact tempCon = new Contact();
          tempCon.Id = dvdContactId;
          tempCon.Is_Access_Level_DVD_Administrator__c = TRUE;
          tempCon.Is_Access_Level_Account_Administrator__c = TRUE;
          tempCon.Is_Access_Level_Levy_Administrator__c = TRUE;
          tempCon.setOptions(dmo);
          accessContactsToUpdate.add(tempCon);
        }
        
        //updating access flags on contact records with Account Manager and Levy access indicator
        for(String dvdContactId : pspUsersWithNoDVDAccess) {
          
          Contact tempCon = new Contact();
          tempCon.Id = dvdContactId;
          tempCon.Is_Access_Level_DVD_Administrator__c = FALSE;
          tempCon.Is_Access_Level_Account_Administrator__c = TRUE;
          tempCon.Is_Access_Level_Levy_Administrator__c = TRUE;
          tempCon.setOptions(dmo);
          accessContactsToUpdate.add(tempCon);
        }
        
        if(accessContactsToUpdate.size() > 0) {
            ContactUpdater updater = new ContactUpdater(accessContactsToUpdate);
            updater.updateContacts();
        }
        
        if(!pspUsersWithDVDAccess.isEmpty() && !(System.isFuture() || System.isBatch())){
        
            System.debug(LoggingLevel.INFO, 'Updating profile for PSP users to ASP');
            PSP2ASPTransformer.transform(pspUsersWithDVDAccess);
        }
        
        if(!pspUsersWithNoDVDAccess.isEmpty()  && !(System.isFuture() || System.isBatch())){
        
            System.debug(LoggingLevel.INFO, 'Updating profile for PSP users to Account Manager');
            PSP2AccountManagerTransformer.transform(pspUsersWithNoDVDAccess);
        }
    }
    
    private Boolean isQualifiedForClose(Case application){
        
        //check if application is approved
        if((qualifiedRecordTypes.contains(application.RecordTypeId) 
            && application.Approval_Status__c == GlobalConstants.CASE_APPROVED 
            && oldApplications.get(application.Id) != null
            && oldApplications.get(application.Id).Approval_Status__c != GlobalConstants.CASE_APPROVED)
           || (application.Sub_Status__c == 'Granted')) {
        
               System.debug(LoggingLevel.INFO, 'Case ' + application.Id + ' is qualified for closure');
               return true;
           }
           
        System.debug(LoggingLevel.INFO, 'Case ' + application.Id + ' is not qualified for closure');
        return false;
    }
    
    
}