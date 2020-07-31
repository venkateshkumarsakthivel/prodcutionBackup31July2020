/**
* @name PaymentStatus.cls
* @description this class is responsible to update order status based on the response summarycode to 
* Pain in Full or Payment Rejected or Payment Cancelled
* separate methods are implemented to update status as per the rules stated above.  Wrapper class will invoke appropriate
* methods to update status.
*/

public without sharing class PaymentStatus {
    
    /**
    * @name updateToPainInFull
    * @description this will update following Order attributes
    * Status = 'Paid In Full', Previous_Payment_Status__c = existing Order.Status [ before update ]
    * Receipt_Number__c = payment gateway receipt Number [ received from response paramters ]
    * Amount_Paid__c = paymentAmount including surcharge or GST if applicable [ received from response paramters ]
    * Payment_Cleared_Date__c = settlementDate [ received from response paramters ]
    */
    public static void updateToPaidInFull(String paymentType, String referenceNumber, String receiptNumber, String settlementDate, Decimal amount, Decimal surcharge) {
    		Order order = [SELECT Id, Payment_Reference__c, Status, Payment_Method__c, Previous_Payment_Status__c, Received_Date__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :referenceNumber];
	    	order.Previous_Payment_Status__c = order.Status;
    		order.Status = GlobalConstants.ORDER_STATUS.get('SUCCESS');
	    	if(paymentType.equalsIgnoreCase(GlobalConstants.PAYMENT_METHOD_FACADE_MAPPING.get('Direct Debit')))  {
		    	order.Status = GlobalConstants.ORDER_STATUS.get('UNCLEARED');	    		
	    	}
	    	order.Receipt_Number__c = receiptNumber;
	    	order.Amount_Paid__c = amount;
	    	order.Surcharge_Amount__c = surcharge;
        	order.Payment_Method__c = GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD;
	    	order.Received_Date__c = Date.today();
	    	order.Payment_Cleared_Date__c = Date.today();

	    	update order;
    }
    
    /**
    * @name updateToPainInFull
    * @description this will update following Order attributes
    * Status = 'Payment Rejected', Previous_Payment_Status__c = existing Order.Status [ before update ]
    */
    public static void updateToPaymentRejected(String referenceNumber) {
	    	Order order = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Received_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :referenceNumber];
	    	order.Previous_Payment_Status__c = order.Status;
	    	order.Status = GlobalConstants.ORDER_STATUS.get('REJECTED');
	    	update order;
    }
    
    /**
    * @name updateToPainInFull
    * @description this will update following Order attributes
    * Status = 'Payment Cancelled', Previous_Payment_Status__c = existing Order.Status [ before update ]
    */
    public static void updateToPaymentCancelled(String referenceNumber) {
	    	Order order = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Received_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :referenceNumber];
	    	order.Previous_Payment_Status__c = order.Status;
	    	order.Status = GlobalConstants.ORDER_STATUS.get('CANCELLED');
	    	update order;
    }
}