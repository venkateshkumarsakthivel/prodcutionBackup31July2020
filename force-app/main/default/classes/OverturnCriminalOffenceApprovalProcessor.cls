/*
 * Helper class responsible for identifying target classes and triggering criminal charge callout to RMS for them.
 */
public with sharing class OverturnCriminalOffenceApprovalProcessor {
  
  private Map<Id, Case> newCases;
  private Map<Id, Case> oldCases;
  
  public OverturnCriminalOffenceApprovalProcessor(Map<Id, Case> newCases, Map<Id, Case> oldCases){
    
    this.newCases = newCases;
    this.oldCases = oldCases;
  }
  
  public void processCriminalOffenceCases() {
    
    Set<Id> targetCaseIds = new Set<Id>();
    
    for(Case tempCase : newCases.values()) {
       
       //identify cases that were approved with decision as overturn
       if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.Criminal_Offence_CASE_RECORD_TYPE_DEV_NAME
           && tempCase.Sub_Status__c == GlobalConstants.DECISION_COMPLETE_SUB_STATUS
           && oldCases.get(tempCase.Id).Sub_Status__c != tempCase.Sub_Status__c
           && tempCase.Decision__c == GlobalConstants.CHARGE_CORRECTED) {
           
           targetCaseIds.add(tempCase.Id);
       }
    }
    
    if(targetCaseIds.size() == 0)
      return;
      
      
    updateCriminalChargeInRMS(targetCaseIds);
  }
  
  @future(callout=true)
  private static void updateCriminalChargeInRMS(Set<Id> targetCaseIds) {
    
    List<Case> targetCases = [SELECT CaseNumber, ParentId, Australian_Driver_Licence_Number_Formula__c, Charge_Code_Identifier_Formula__c,
                              Offence_Code__c, Law_Part_Code__r.Name ,Law_Part_Code_Name__c
                              FROM Case 
                              WHERE Id IN :targetCaseIds];
                        
     for(Case tempTargetCase : targetCases) {
     
      P2PRMSClient client=new P2PRMSClient();
      P2PRMSOvtResponseParserVisitor visitor=new P2PRMSOvtResponseParserVisitor();
      client.call(P2PRMSClient.RMS_REQUEST_TYPE.OVERTURN_CRIMINAL_OFFENCE, visitor, tempTargetCase);
      visitor.updateResponses();
     } 
  }
}