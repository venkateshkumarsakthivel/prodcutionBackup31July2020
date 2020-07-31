/*
 * Helper class to populate acuthorisation and assessment details
 * on Account when an audit case is created
 */
public without sharing class AuditCaseCreationHandler {

  private Map<Id, Case> newCases;
  
  public AuditCaseCreationHandler(Map<Id, Case> newCases){
    
        this.newCases = newCases;
  }
    
  public void postAuditCaseCreationAutomation() {    
       
     try {
       
        Map<String, List<Condition__c>> targetAuthIdVsActiveConditionsMap = new Map<String, List<Condition__c>>();
        
        List<Account> targetAccountsToUpdate = new List<Account>();
        
        Set<String> targetAccountIds = new Set<String>();
        Set<String> grantedStatusValueSet = new Set<String>();
        grantedStatusValueSet.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
        grantedStatusValueSet.add(GlobalConstants.GRANTED_CONDITIONALLY);
        grantedStatusValueSet.add(GlobalConstants.AUTHORISATION_SUSPENDED);
         
        Set<String> aspAuthorisationTypes = new Set<String>();
        aspAuthorisationTypes.add(GlobalConstants.AUTHORISATION_TYPE_TSP);
        aspAuthorisationTypes.add(GlobalConstants.AUTHORISATION_TYPE_BSP);
        
        Set<String> issuedAssessmentsValueSet = new Set<String>();
        issuedAssessmentsValueSet.add(GlobalConstants.ASSESSMENT_STATUS_ISSUED);
        issuedAssessmentsValueSet.add(GlobalConstants.Assessment_STATUS_SUBMITTED);
        issuedAssessmentsValueSet.add(GlobalConstants.Assessment_STATUS_OUTSTANDING);
        issuedAssessmentsValueSet.add(GlobalConstants.Assessment_STATUS_Closed);
        
        for(Case tempCase : newCases.values()) {
           
            if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT
                && tempCase.AccountId != NULL)
                targetAccountIds.add(tempCase.AccountId);
        }
        
        for(Condition__c tempCondition : [SELECT Authority__c, Authority__r.Service_Provider__c, Name, Status__c, Condition_Details__c
                                           FROM Condition__c
                                           WHERE Authority__r.Service_Provider__c IN :targetAccountIds
                                           AND Status__c = :GlobalConstants.MASTER_CONDITION_ACTIVE]) {
               
           List<Condition__c> activeConditions = new List<Condition__c>();
          
           if(targetAuthIdVsActiveConditionsMap.containsKey(tempCondition.Authority__c))
              activeConditions = targetAuthIdVsActiveConditionsMap.get(tempCondition.Authority__c);  
           
           activeConditions.add(tempCondition);
           targetAuthIdVsActiveConditionsMap.put(tempCondition.Authority__c, activeConditions);                          
        }
        
        for(Account tempAcc : [SELECT Name, (SELECT Name, End_Date__c, Start_Date__c, Status__c,
                                             Authorisation_Type__c 
                                             FROM Authorities__r
                                             WHERE Status__c IN :grantedStatusValueSet
                                             AND Authorisation_Type__c IN : aspAuthorisationTypes
                                             ORDER By Start_Date__c DESC), 
                                            (SELECT Period_Start_Date__c, Period_End_Date__c, Status__c, BSP_Transaction_Count__c,
                                              TSP_Transaction_Count__c, Issue_Date__c, Assessment_Type__c, Levy_Calculation_Method__c
                                              FROM Assessments__r
                                              WHERE Status__c != :GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED
                                              AND Status__c IN :issuedAssessmentsValueSet
                                              ORDER BY Period_End_Date__c DESC),
                               Authorisation_Details__c
                               FROM Account
                               WHERE Id IN :targetAccountIds]) {
              
              tempAcc.Authorisation_Details__c = '';
              tempAcc.Authorisation_Numbers_for_Audit__c = '';
              
              if(tempAcc.Authorities__r.size() > 0) {
                
                String tempAuthDetails = '';
                String tempAuthNumbers = '';
                  
                Set<String> authNames = new Set<String>();  
                
               for(Authorisation__c tempAuth : tempAcc.Authorities__r) {
                      
                      if(!authNames.contains(tempAuth.Name)) {
                          
                          authNames.add(tempAuth.Name);
                          
                          String authStartDate = tempAuth.Start_Date__c != NULL ? DateTime.newInstance(tempAuth.Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') : '';
                          String authEndDate = tempAuth.End_Date__c!= NULL ? DateTime.newInstance(tempAuth.End_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') : '';
                          
                          if(String.isNotBlank(tempAuth.Name)) {
                              tempAuthDetails += 'Type & Number: '+tempAuth.Name+'; ';
                              tempAuthNumbers += tempAuth.Name+'; ';
                          }
                          
                          if(authStartDate != NULL)
                              tempAuthDetails += 'Start: '+authStartDate+'; ';
                          
                          if(authEndDate != NULL)
                              tempAuthDetails += 'End: '+authEndDate+'; ';
                          
                          if(String.isNotBlank(tempAuth.Status__c))
                              tempAuthDetails += 'Status: '+tempAuth.Status__c+'; ';
                          
                          tempAuthDetails += '\r\n'; 
                          
                          
                          if(targetAuthIdVsActiveConditionsMap.containsKey(tempAuth.Id)) {
                              
                              /*
                                tempAuthDetails += 'Conditions:\r\n';
                                Integer conditionIndex = 1;
                                */
                              
                              for(Condition__c tempActiveCondition : targetAuthIdVsActiveConditionsMap.get(tempAuth.Id)) {
                                  
                                  tempAuthDetails += ' Condition: '+tempActiveCondition.Condition_Details__c;
                                  tempAuthDetails += '\r\n';
                                  //conditionIndex++;
                              }
                          }
                          
                      }
                  }
                  
                  tempAcc.Authorisation_Details__c = tempAuthDetails;
                  tempAcc.Authorisation_Numbers_for_Audit__c = tempAuthNumbers;
              }
              
              if(tempAcc.Assessments__r.size() > 0) {
                
                String tempAssessmentDetails = '';
                
                for(Assessment__c tempAssessment : tempAcc.Assessments__r) {
                   
                   String periodStartDate = tempAssessment.Period_Start_Date__c != NULL ? DateTime.newInstance(tempAssessment.Period_Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') : '';
                   String periodEndDate = tempAssessment.Period_End_Date__c != NULL ? DateTime.newInstance(tempAssessment.Period_End_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') : '';
                   String issuedDate = tempAssessment.Issue_Date__c != NULL ? DateTime.newInstance(tempAssessment.Issue_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') : '';
                   
                   if(periodStartDate != '' && periodEndDate != '')
                    tempAssessmentDetails += 'Period: '+periodStartDate+' to '+periodEndDate+'; ';
                   
                   if(issuedDate != '')
                    tempAssessmentDetails += 'Issued: '+issuedDate+'; ';
                   
                   tempAssessmentDetails += '\r\n'; 
                   
                   if(tempAssessment.Assessment_Type__c != NULL)
                    tempAssessmentDetails += ' Type: '+tempAssessment.Assessment_Type__c+'; ';
                    
                   if(tempAssessment.Levy_Calculation_Method__c != '')
                    tempAssessmentDetails += ' Method: '+tempAssessment.Levy_Calculation_Method__c+'; ';
                   
                   tempAssessmentDetails += '\r\n'; 
                   
                   if(tempAssessment.BSP_Transaction_Count__c != NULL)
                    tempAssessmentDetails += ' BSP Count: '+tempAssessment.BSP_Transaction_Count__c.format()+'; ';
                   
                   if(tempAssessment.TSP_Transaction_Count__c != NULL)
                    tempAssessmentDetails += 'TSP Count: '+tempAssessment.TSP_Transaction_Count__c.format()+'; ';
                   
                   tempAssessmentDetails += '\r\n'; 
                }
                
              }
              
              targetAccountsToUpdate.add(tempAcc);                           
        }
        
        List<Database.SaveResult> accountUpdationResult = Database.update(targetAccountsToUpdate, FALSE);
        System.debug('Account Update Result: '+accountUpdationResult);
     }
     catch(Exception ex) {
        
       ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditCaseCreationHandler','postAuditCaseCreationAutomation',ex.getMessage(),ex);                        
     }
  } 
}