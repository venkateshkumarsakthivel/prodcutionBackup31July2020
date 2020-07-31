/*
 * @Description: Helper class to create case record for P2P staff to work on for rejected recurring payment.
 */
public with sharing class CaseCreatorForRejectedPayment {

    private List<Order> rejectedPayments;
    
    public CaseCreatorForRejectedPayment(List<Order> payments){
        //validate the input payment records
        if(payments == null || payments.isEmpty()){
            throw new InvalidDataException('Payment records not available for case creation.');
        }
        this.rejectedPayments = payments;
    }
    
    public void create(){
        List<Case> casesToCreate = new List<Case>();
        
        //retrieve account details for rejected payments
        Set<Id> actIds = new Set<Id>();        
        for(Order payment : rejectedPayments){
            actIds.add(payment.AccountId);
        }
        
        Map<Id, Account> actIdVsAccount = new Map<Id, Account>([SELECT Id, Notice_Email__c FROM Account WHERE Id IN :actIds]);
        
        //identify the case record type id for record type name 'Taxi Administration'
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(
                GlobalConstants.TAXI_ADMINISTRATION_CASE_RECORD_TYPE_NAME ).getRecordTypeId();
        
        //for each payment record, create a case record and associate with account and payment
        for(Order payment : rejectedPayments){
            Case caseRec = new Case();
            caseRec.Type = GlobalConstants.TAXI_CASE_TYPE;
            caseRec.Sub_Type__c = GlobalConstants.CASE_SUBTYPE_REJECTED_PAYMENT;
            caseRec.Sub_Status__c = GlobalConstants.CASE_STATUS_REVIEW_PENDING;
            caseRec.Status = GlobalConstants.LODGED_CASE_STATUS;
            caseRec.Subject = GlobalConstants.CASE_SUBJECT_RECURRING_PAYMENT_REJECTED;
            caseRec.RecordTypeId = caseRecordTypeId;
            caseRec.AccountId = payment.AccountId;
            caseRec.Notice_Email__c = actIdVsAccount.get(payment.AccountId).Notice_Email__c;
            caseRec.Payment__c = payment.Id;
            caseRec.Authorisation__c = payment.Authorisation__c;
            caseRec.Description = GlobalConstants.CASE_SUBJECT_RECURRING_PAYMENT_REJECTED;
            
            casesToCreate.add(caseRec);
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        Database.insert(casesToCreate, dmo);
    }
    
    public class InvalidDataException extends Exception {}
}