//When Surrender/Cancel Case is Closed and Approved - Update Draft Authorisation Status, Associated Renewal Case 
//This is invoked from Process Builder - Surrender/Cancellation Case Closed Approved - Post Processing
public class Surrender_CancelCaseClosePostProcessor {
    @InvocableMethod
    public static void closeRenewalClase(List<Authorisation__C> listAuthorisations) {
        // We get only one Authorisation in List     
        Authorisation__c originalAuthorisation = listAuthorisations.get(0);   
        
        List<Case> listCases = [SELECT Id, CaseNumber, Authorisation__c, Status, Sub_Status__c FROM Case 
                                WHERE Authorisation__r.Related_Authorisation__c =: originalAuthorisation.Id
                                AND (Status =: GlobalConstants.CASE_DRAFT 
                                     OR Status =: GlobalConstants.APPLICATION_STATUS_LODGED)];
        
        Case renewalCaseRecord =  null;
        if(listCases.size() > 0) {
            renewalCaseRecord = listCases.get(0);
        }
        
        //Renewal Case Present
        //Update Renewal case Status: "Cancelled" and Sub Status: "Cancelled"
        //Update Draft Authorisation Status : "Discarded"
        if(renewalCaseRecord != null) {
            renewalCaseRecord.Status = GlobalConstants.CANCELLED_CASE_STATUS;
            renewalCaseRecord.Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_CANCELLED;
            update renewalCaseRecord;
            
            Authorisation__c draftAuthorisationRecord = [SELECT ID, Name, Status__c FROM Authorisation__c 
                                                         WHERE Id =: renewalCaseRecord.Authorisation__c];
            draftAuthorisationRecord.Status__c = GlobalConstants.AUTHORISATION_STATUS_DISCARDED;
            update draftAuthorisationRecord;
        }
        
    }
}