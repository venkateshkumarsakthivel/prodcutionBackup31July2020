public with sharing class P2PWIBSCAFParserFacade extends P2PWIBSParserFacadeBase  {
    
    /**
    * this private process method will switch between processing of transactions related to CAF report.
    * conditions to update order status to PAYMENT UNCLEARED
    *  existing status must be Payment Due. additionally Payment method must DIRECT DEBIT / DIRECT_DEBIT, if condition satified update order(s) to Payment Uncleared
    */
    private void process() {
        String cardtype = this.tokens.get(P2PWIBSParserFacadeBase.CAF_CARD_TYPE).trim();
        System.debug ('Card Type :XXX' + cardType + 'XXX:');
        String status = this.tokens.get(P2PWIBSParserFacadeBase.CAF_PAYMENT_STATUS).trim();
        
        Integer paymentReference = this.tokens.size() == 13 ? P2PWIBSParserFacadeBase.CAF_CUSTOMER_REFERENCE_NUMBER : P2PWIBSParserFacadeBase.RETURNS_CAF_CUSTOMER_REFERENCE_NUMBER;
        if(String.isEmpty(cardType))  {
            this.orders = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Received_Date__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Method__c = :GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT AND Status IN :GlobalConstants.PAYMENT_DUE_STATUS_VALUES AND Payment_Reference__c = :this.tokens.get(paymentReference).trim() LIMIT 1];
            System.debug('Order.Payment_Reference__c = ' + this.tokens.get(paymentReference).trim() + ' Orders.found : ' + this.orders.size() + ' for status ' +  status);
            if(this.orders.size() == 1)  {
                Order order = this.orders[0];
                order.Previous_Payment_Status__c = order.Status;
                order.Status = status.equalsIgnoreCase('G') ? GlobalConstants.ORDER_STATUS.get('UNCLEARED') : GlobalConstants.ORDER_STATUS.get('REJECTED');
                order.Amount_Paid__c = Decimal.valueOf(this.tokens.get(P2PWIBSParserFacadeBase.CAF_PAYMENT_AMOUNT));
                order.Receipt_Number__c = this.tokens.get(P2PWIBSParserFacadeBase.CAF_RECEIPT_NUMBER);
                if(status.equalsIgnoreCase('G'))  {
                    /** previously Received_Date__c is being populated when Order is created, current changes does not populate Received_Date__c on Order Creation hence
                    * enhancing CAF procssing to update Received_Date__c with today's date (date on which CAF file being processed) 
                    */
                    order.Received_Date__c = Date.today();
                    order.Payment_Cleared_Date__c = P2PWIBSParserFacadeBase.calculateT3(Date.today());
                }
                
                System.debug('Order to be updated : ' + order);
                this.ordersTobeUpdated.put(this.tokens.get(paymentReference).trim(), order);
            }   
        }
    }
    
    public P2PWIBSCAFParserFacade () { this.ordersToBeUpdated = new Map<String,Order>(); }
    
    public override void execute(List<String> tokens)  {
        System.debug(LoggingLevel.INFO, 'Generated tokens: ' + tokens);
        this.tokens = tokens;
        this.process();
    }    
}