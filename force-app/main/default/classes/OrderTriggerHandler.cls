/**
 *  Description: Order trigger handler class
 */
public with sharing class OrderTriggerHandler {
 
  //after update handler
  public static void afterUpdate(Map<Id, Order> newOrders, Map<Id, Order> oldOrders) {
    
    //process post payment related updates
    PostPaymentProcessor paymentProcessor = new PostPaymentProcessor(newOrders, oldOrders);
    paymentProcessor.validateSuccessfullPayments();
    
    //process rejected recurring payment to create a case for P2P staff.
    RejectedPaymentProcessor rejectedPaymentProcessor = new RejectedPaymentProcessor(newOrders, oldOrders);
    rejectedPaymentProcessor.process();
  }
  
  //before update handler
  public static void beforeUpdate(Map<Id, Order> newOrders, Map<Id, Order> oldOrders) {
    
    //process Bpay number generation/clearance automation
    BpayReferenceGenerationDecider bpayRefProcessor = new BpayReferenceGenerationDecider(newOrders, oldOrders);
    bpayRefProcessor.validateBpayReferenceGeneration();
  }
    
    //after insert handler
    public static void beforeInsert(List<Order> newOrders) {
        System.debug('orderrsss>' + newOrders);
        //stamp payment type on the order
        AuthFeePaymentUpdator authFeePaymentUpdator = new AuthFeePaymentUpdator();
        authFeePaymentUpdator.updatePaymentType(newOrders);   
        
    }
    
}