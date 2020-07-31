/*
 * Description: Batch class to process due payment for recurring direct debit and credit card for taxi licence
 */
public with sharing class DDCCPendingPaymentProcessorBatch implements Database.Batchable<SObject>, Database.AllowsCallouts  {

	private List<Date> startDateToProcess;
    private static final String PAYMENT_DUE = GlobalConstants.PAYMENT_DUE_STATUS;
    private static final String DIRECT_DEBIT = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
    private static final String CREDIT_CARD = GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD;
    private static final String GRANTED_AUTHORISATION = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String MONTHLY_PAYMENT = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;

    public DDCCPendingPaymentProcessorBatch(List<Date> startDate){
        startDateToProcess = startDate;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        //retrieve qualified payment records for processing
        String receivedDateStr = '(';
        for(Integer index = 0; index < startDateToProcess.size(); index++){
            receivedDateStr += 'Processing_Date__c = ' + startDateToProcess[index].year() 
                    + '-' + (startDateToProcess[index].month() > 9? '' + startDateToProcess[index].month(): '0' + startDateToProcess[index].month())  
                    + '-' + (startDateToProcess[index].day() > 9? '' + startDateToProcess[index].day(): '0' + startDateToProcess[index].day()) + '';
            if(index < (startDateToProcess.size() - 1)){
                receivedDateStr += ' OR ';
            }
        }
        receivedDateStr += ') ';
        
        String query = 'SELECT Id, Received_Date__c, TotalAmount, Authorisation__r.Authorisation_Name__c, Authorisation__r.Payment_Token__c, ' 
                + 'Payment_Cleared_Date__c, Status, Authorisation__c, Authorisation__r.Authorisation_Number__c,Processing_Date__c,' 
                + '   Payment_Reference__c, Payment_Method__c '
                + 'FROM Order WHERE ' + receivedDateStr  
                + ' AND Status = :PAYMENT_DUE AND ( Payment_Method__c = :DIRECT_DEBIT OR Payment_Method__c = :CREDIT_CARD) '
                + ' AND Authorisation__r.Status__c = :GRANTED_AUTHORISATION '
                + ' AND Authorisation__r.Payment_Frequency__c = :MONTHLY_PAYMENT '
            	+ ' AND TotalAmount > 0';
        System.debug(LoggingLevel.INFO, 'Generated query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> payments){
        List<Order> paymentsToProcess = new List<Order>();
        
        for(Order payment : (List<Order>) payments){
            //filter out payment records without bank details
            if(String.isBlank(payment.Authorisation__r.Payment_Token__c)){
                continue;
            }
            //update payment records with status as payment uncleared and received date as current date
            payment.Status = GlobalConstants.PAYMENT_PAID_UNCLEARED_STATUS;
            payment.Received_Date__c = System.today();
            payment.Payment_Summary_Code__c = '';
            payment.Payment_Response_Code__c = '';
            payment.Payment_Response_Description__c = '';
            paymentsToProcess.add(payment);
        }
        
        if(!paymentsToProcess.isEmpty()){
            System.debug(LoggingLevel.INFO, 'Payments to process for direct debit: ' + paymentsToProcess.size());
            //send payment request to westpac quick batch
            QBRequestFileGenerator fileGenerator = new QBRequestFileGenerator();
            fileGenerator.execute(paymentsToProcess);
            //update payment records
            update paymentsToProcess;
        }
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}