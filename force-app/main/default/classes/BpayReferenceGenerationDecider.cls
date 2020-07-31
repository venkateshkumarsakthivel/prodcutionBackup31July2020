/*
 * Helper class to determine if Bpay reference should be generated or cleared depending
 */
public with sharing class BpayReferenceGenerationDecider {

    private Map<Id, Order> newOrders;
    private Map<Id, Order> oldOrders;
    
    public BpayReferenceGenerationDecider(Map<Id, Order> newOrders, Map<Id, Order> oldOrders){
    
        this.newOrders = newOrders;
        this.oldOrders = oldOrders;
    }
    
    /*
     * Method to determine if Bpay reference should be generated or cleared depending
     * on whether payment method is Bpay or not
     */
    public void validateBpayReferenceGeneration() {
    
     try { 
     
      Set<String> offlinePaymentMethods = new Set<String>();
      offlinePaymentMethods.add(GlobalConstants.PAYMENT_METHOD_BPAY);
      offlinePaymentMethods.add(GlobalConstants.PAYMENT_METHOD_CHEQUE);
      offlinePaymentMethods.add(GlobalConstants.PAYMENT_METHOD_MONEY_ORDER);
      offlinePaymentMethods.add(GlobalConstants.PAYMENT_METHOD_CONTACT_P2P);
       
      for(Order tempPayment : newOrders.values()) {
       
        System.debug('Payment Method: '+tempPayment.Payment_Method__c);
        System.debug('Payment Ref. Number: '+String.isBlank(tempPayment.BPay_Reference__c));
        System.debug('Payment Total Amount: '+tempPayment.TotalAmount);
        
        /*check if payment method is Bpay, Bank Cheque, Money Order or Contact P2P Commission.
          When orderline items are added, order are updated on purpose to trigger
          Bpay reference number regeneration.
        */
        if(offlinePaymentMethods.contains(tempPayment.Payment_Method__c) && tempPayment.Amount_Due__c > 0) {
         
            tempPayment.BPay_Reference__c = BPAYiCRNUtility.generateICRN(tempPayment.Amount_Due__c, tempPayment.Payment_Reference__c);
           
        }
        
        //determine if payment method is not Bpay
        if(!offlinePaymentMethods.contains(tempPayment.Payment_Method__c)) {
            
            tempPayment.BPay_Reference__c = '';
        }
      }
     }
     catch(Exception e) {
     
     System.debug('Exception: '+ e);
     ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'BpayReferenceGenerationDecider', 'validateBpayReferenceGeneration', e.getMessage(), e);
    }
   }    
}