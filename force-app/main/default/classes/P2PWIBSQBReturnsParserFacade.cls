public with sharing class P2PWIBSQBReturnsParserFacade extends P2PWIBSParserFacadeBase  {
	
	/**
	* this private process method will switch between processing of transactions related to QB Returns file.
	*/
    private final String SUMMARY_CODE = '1';
    private final String STATUS_REJECTED = 'Payment Rejected';
	
    
    private void process() {
		
        this.orders = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Received_Date__c,
                       Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c 
                       FROM ORDER 
                       WHERE  Payment_Reference__c= :this.tokens.get(P2PWIBSParserFacadeBase.QB_RETURNS_REFERENCE_NUMBER).trim()
                       LIMIT 1];
        if(this.orders.size() == 1)  {
            
            Order order = this.orders[0];
            order.Previous_Payment_Status__c = order.Status;
            order.Status = STATUS_REJECTED;
            order.Payment_Summary_Code__c = SUMMARY_CODE ; // the returns file does not contain this column and hence the default vaule is set as '1' which implies that the txn is declined.
            order.Payment_Response_Code__c = this.tokens.get(P2PWIBSParserFacadeBase.QB_RETURNS_TXN_CODE).trim();
            order.Payment_Response_Description__c = this.tokens.get(P2PWIBSParserFacadeBase.QB_RETURNS_TXN_DESC).trim();
            this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.QB_RETURNS_REFERENCE_NUMBER).trim(), order);
            System.debug('Orders to be updated:>> '+ordersTobeUpdated);
        }	
	}
	
	public P2PWIBSQBReturnsParserFacade () {
        this.ordersToBeUpdated = new Map<String,Order>(); 
    }
	
	public override void execute(List<String> tokens)  {
		this.tokens = tokens;
		this.process();
	}    
}