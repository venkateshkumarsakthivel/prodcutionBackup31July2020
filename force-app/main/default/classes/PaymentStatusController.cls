/**
* @name PaymentStatusController.cls
* @description this is the controller @AuraEnabled actions are called from lightning component
* independent actions are written to update specific status of Order
*/
public without sharing class PaymentStatusController {
	
    /**
    * @name paid
    * @description this actions updates status to "Paid in Full" by executing PaymentStatus.updateToPaidInFull and will be called from lightning component event
    * this action has @AuraEnabled annotation, this will make action to be executed from lightning component event
    * in this example initialize event. 
    */
	@AuraEnabled
    public static void paid(String paymentType, String referenceNumber, String receiptNumber, String settlementDate, String amount, String surcharge)  {
    		PaymentStatus.updateToPaidInFull(paymentType, referenceNumber, receiptNumber, settlementDate, Decimal.valueOf(amount), Decimal.valueOf(surcharge));
    }
    
	
    /**
    * @name reject
    * @description this actions updates status to "Payment Rejected" by executing PaymentStatus.updateToPaymentRejected and will be called from lightning component event
    * this action has @AuraEnabled annotation, this will make action to be executed from lightning component event
    * in this example initialize event. 
    */
	@AuraEnabled
    public static void reject(String referenceNumber)  {
    		PaymentStatus.updateToPaymentRejected(referenceNumber);
    }
    
	
    /**
    * @name cancel
    * @description this actions updates status to "Payment Cancelled" by executing PaymentStatus.updateToPaymentCancelled and will be called from lightning component event
    * this action has @AuraEnabled annotation, this will make action to be executed from lightning component event
    * in this example initialize event.
    */ 
	@AuraEnabled
    public static void cancel(String referenceNumber)  {
    		PaymentStatus.updateToPaymentCancelled(referenceNumber);
    }
}