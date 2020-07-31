/*
 * Description: Batch class to process due payment for recurring direct debit for taxi licence
 */
public with sharing class DDPendingPaymentProcessorBatch implements Database.Batchable<SObject>, Database.AllowsCallouts  {

    private List<Date> startDateToProcess;
    private static final String PAYMENT_DUE = GlobalConstants.PAYMENT_DUE_STATUS;
    private static final String DIRECT_DEBIT = GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT;
    private static final String GRANTED_AUTHORISATION = GlobalConstants.TAXI_LICENCE_GRANTED_STATUS;
    private static final String MONTHLY_PAYMENT = GlobalConstants.MONTHLY_PAYMENT_FREQUENCY;

    public DDPendingPaymentProcessorBatch(List<Date> startDate){
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
        
        String query = 'SELECT Id, Received_Date__c, TotalAmount, Authorisation__r.Authorisation_Name__c,' 
                + 'Payment_Cleared_Date__c, Status, Authorisation__c, Authorisation__r.BSB_Number__c,Processing_Date__c,' 
                + ' Authorisation__r.Bank_Account_Number__c, Authorisation__r.Bank_Account_Name__c, Payment_Reference__c '
                + 'FROM Order WHERE ' + receivedDateStr  
                + ' AND Status = :PAYMENT_DUE AND Payment_Method__c = :DIRECT_DEBIT '
                + ' AND Authorisation__r.Status__c = :GRANTED_AUTHORISATION '
                + ' AND Authorisation__r.Payment_Frequency__c = :MONTHLY_PAYMENT ';
        System.debug(LoggingLevel.INFO, 'Generated query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> payments){
        List<Order> paymentsToProcess = new List<Order>();
        
        for(Order payment : (List<Order>) payments){
            //filter out payment records without bank details
            if(String.isBlank(payment.Authorisation__r.BSB_Number__c) 
                    || String.isBlank(payment.Authorisation__r.Bank_Account_Name__c)
                    || String.isBlank(payment.Authorisation__r.Bank_Account_Number__c)){
                continue;
            }
            paymentsToProcess.add(payment);
            
            //update payment records with status as payment uncleared and received date as current date
            payment.Status = GlobalConstants.PAYMENT_PAID_UNCLEARED_STATUS;
            payment.Received_Date__c = System.today();
        }
        
        if(!paymentsToProcess.isEmpty()){
            System.debug(LoggingLevel.INFO, 'Payments to process for direct debit: ' + paymentsToProcess.size());
            //send payment request to westpac
            ABAFileGenerator fileGenerator = new ABAFileGenerator();
            fileGenerator.execute(GlobalConstants.NUMBER_OF_DIRECT_DEBIT_PAYMENTS_TO_PROCESS, paymentsToProcess);
            
            //update payment records
            update paymentsToProcess;
        }
    }

    public void finish(Database.BatchableContext BC){
        //
    }
}