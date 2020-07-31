/*
 * Helper class to detect if application was probably refused in past 12 months
 */
public with sharing class CaseRefusalDetector {

    private Map<Id, Case> newApplications;
    private Map<Id, Case> oldApplications;
    private static final Set<Id> aspRecordTypes;
    
    static {
        aspRecordTypes = GlobalUtility.retrieveASPApplicationRecordTypes();
    }
    
    
    public CaseRefusalDetector(Map<Id, Case> newApplications, Map<Id, Case> oldApplications){
    
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    /*
      Check if organisation/individual has application which was 
      probably refused in past 12 months or they have specified 
      of refusal in the application
    */
    public void detectRefusal() {
      
      Map<String, Integer> refusedMatchingApplicationsCount = new Map<String, Integer>();
      for(case tempMatchingRefusedCase  : [SELECT AccountId, Probable_Refusal_Criteria__c
                                           FROM Case
                                           WHERE Sub_Status__c = :GlobalConstants.APPLICATION_STATUS_REFUSED
                                           AND ClosedDate <= THIS_YEAR]) {
      
           Integer refusedCaseCount;
           if(refusedMatchingApplicationsCount.containsKey(tempMatchingRefusedCase.AccountId))
              refusedCaseCount = refusedMatchingApplicationsCount.get(tempMatchingRefusedCase.AccountId);
           else
              refusedCaseCount = 0;
              
           refusedCaseCount++;
           refusedMatchingApplicationsCount.put(tempMatchingRefusedCase.AccountId, refusedCaseCount);                               
      }
                                         
                                         
       
      for(Case caseRec : newApplications.values()) {
       
        
        if(aspRecordTypes.contains(caseRec.RecordTypeId)
            && caseRec.Status == GlobalConstants.APPLICATION_STATUS_LODGED
            && oldApplications.get(caseRec.Id).Status != GlobalConstants.APPLICATION_STATUS_LODGED
            && refusedMatchingApplicationsCount.containsKey(caseRec.AccountId)
            && refusedMatchingApplicationsCount.get(caseRec.AccountId) > 0)
           caseRec.Probably_Refused_In_Past__c = TRUE;
        else if(aspRecordTypes.contains(caseRec.RecordTypeId)
                 && caseRec.Status == GlobalConstants.APPLICATION_STATUS_LODGED
                 && oldApplications.get(caseRec.Id).Status != GlobalConstants.APPLICATION_STATUS_LODGED
                 && refusedMatchingApplicationsCount.containsKey(caseRec.AccountId) == false)
           caseRec.Probably_Refused_In_Past__c = FALSE;
           
           
        /*if individual/corporation confirms that they have been 
          refused authorisation or had an authorisation cancelled within the last 12 months
        */
        if(aspRecordTypes.contains(caseRec.RecordTypeId) 
           && caseRec.Has_had_authorization_refused__c == 'Yes'
           && caseRec.Status == GlobalConstants.APPLICATION_STATUS_LODGED
           && oldApplications.get(caseRec.Id).Status != GlobalConstants.APPLICATION_STATUS_LODGED)
           caseRec.Probably_Refused_In_Past__c = TRUE;
        else if(aspRecordTypes.contains(caseRec.RecordTypeId) == false 
                 && (caseRec.Has_had_authorization_refused__c == 'No' 
                     || String.isBlank(caseRec.Has_had_authorization_refused__c))
                 && ((refusedMatchingApplicationsCount.containsKey(caseRec.AccountId)
                      && refusedMatchingApplicationsCount.get(caseRec.AccountId) == 0)
                      || refusedMatchingApplicationsCount.containsKey(caseRec.AccountId) == false))
           caseRec.Probably_Refused_In_Past__c = FALSE;
      }
      
    }
    
}