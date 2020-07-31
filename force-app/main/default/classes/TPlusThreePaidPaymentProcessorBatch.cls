/*
 * Description: Batch class to process uncleared payment records at T+3 days
 */
public with sharing class TPlusThreePaidPaymentProcessorBatch implements Database.Batchable<SObject>{

    private Date startDateToProcess;
    private static final String UNCLEARED_PAYMENT = GlobalConstants.PAYMENT_PAID_UNCLEARED_STATUS;
    private static final List<String> T_PLUS_3_PAYMENT_METHOD = new List<String>{
                                                                    GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT,
                                                                    GlobalConstants.PAYMENT_METHOD_CHEQUE,
                                                                    GlobalConstants.PAYMENT_METHOD_BPAY};

    public TPlusThreePaidPaymentProcessorBatch(Date startDate){
        startDateToProcess = startDate;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Amount_Paid__c, TotalAmount,Type,Authorisation__r.Payment_Token__c,' 
                + 'Payment_Cleared_Date__c, Status '
                + 'FROM Order WHERE Received_Date__c <= :startDateToProcess' 
                + ' AND Status = :UNCLEARED_PAYMENT AND Payment_Method__c IN :T_PLUS_3_PAYMENT_METHOD';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> payments){
        List<Order> paymentsToProcess = (List<Order>) payments;
        for(Order payment : paymentsToProcess){
            
            if(payment.Type =='Authorisation fee')
             payment.Amount_Paid__c = payment.Amount_Paid__c;   
            else
            payment.Amount_Paid__c = payment.TotalAmount;
            
            payment.Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS;
            payment.Payment_Cleared_Date__c = System.today();
            if(payment.Authorisation__r.Payment_Token__c != NULL) {
                payment.Payment_Summary_Code__c = '0';
                payment.Payment_Response_Code__c = 'G';
                payment.Payment_Response_Description__c = 'WBC Exception Processing released successfully';
            }
        }
        
        //update payment record
        update paymentsToProcess;
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}