/*
 * @Description: Helper class to process rejected recurring payments
 */
public with sharing class RejectedPaymentProcessor {
    
    private Map<Id, Order> newPaymentMap;
    private Map<Id, Order> oldPaymentMap;
    private static Map<Id, Order> rejectedPayment = new Map<Id, Order>();
    private Map<Id, Authorisation__c> licences;
    
    public RejectedPaymentProcessor(Map<Id, Order> newPayments, Map<Id, Order> oldPayments){
        //validate the input maps
        if(newPayments == null || oldPayments == null 
                || newPayments.isEmpty() || oldPayments.isEmpty()){
            throw new InvalidDataException('Failed to process rejected payments. Payment details missing');
        }
        this.newPaymentMap = newPayments;
        this.oldPaymentMap = oldPayments;
        this.licences = new Map<Id, Authorisation__c>();
    }
    
    public void process(){
        System.debug(LoggingLevel.INFO, 'Initiating process to identify rejected recurring payments.');
        Set<Id> licenceIds = new Set<Id>();
        for(Order payment : newPaymentMap.values()){
            licenceIds.add(payment.Authorisation__c);
        }
        
        //retrieve licence details associated with payments to identify if the licence is linked with recurring payment schedule
        licences = new Map<Id, Authorisation__c>([SELECT Id, Payment_Frequency__c
                                                FROM Authorisation__c
                                                WHERE Id IN :licenceIds]);
        
        List<Order> qualifiedPayments = new List<Order>();
        //identify the payments qualified for processing.
        for(Order payment : newPaymentMap.values()){
            if(isQualifiedForProcessing(payment)){
                qualifiedPayments.add(payment);
            }
        }
        
        if(!qualifiedPayments.isEmpty()){
            System.debug(LoggingLevel.INFO, 'Number of rejected recurring payments: ' + qualifiedPayments.size());
            //create a case for qualified rejected payments
            CaseCreatorForRejectedPayment caseCreator = new CaseCreatorForRejectedPayment(qualifiedPayments);
            caseCreator.create();
        }
    }
    
    //criteria for rejected payment processing is as below
    //Payment Status = 'Payment Rejected' & Payment Method = 'Direct Debit' & Payment Frequency on licence = 'Monthly'
    private Boolean isQualifiedForProcessing(Order newPayment){
        if(newPayment.Status == GlobalConstants.PAYMENT_REJECTED_STATUS 
                && newPayment.Payment_Method__c == GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT 
                && oldPaymentMap.get(newPayment.Id) != null
                && oldPaymentMap.get(newPayment.Id).Status != GlobalConstants.PAYMENT_REJECTED_STATUS
                && !rejectedPayment.containsKey(newPayment.Id)
                && licences.containsKey(newPayment.Authorisation__c)
                && licences.get(newPayment.Authorisation__c).Payment_Frequency__c 
                        == GlobalConstants.MONTHLY_PAYMENT_FREQUENCY ){
            System.debug(LoggingLevel.INFO, 'Payment ' + newPayment.Id + ' is qualified rejected recurring payment.');
            return true;
        }
        System.debug(LoggingLevel.INFO, 'Payment ' + newPayment.Id + ' is not qualified rejected recurring payment.');
        return false;
    }
    
    public class InvalidDataException extends Exception {}
}